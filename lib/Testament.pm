package Testament;
use 5.008005;
use strict;
use warnings;
use Testament::Setup;
use Testament::Config;
use Testament::Virt;
use Testament::Virt::Vagrant;
use Testament::Util;
use Testament::URLFetcher;
use Testament::Git;
use Testament::Constants qw(
    CHEF_INSTALLER_URL
    RBENV_REPO
    RUBYBUILDER_REPO
    SPAWN_TIMEOUT
);
use File::Spec;
use Expect;

our $VERSION = "0.01";

my $config = Testament::Config->load;

sub setup {
    my ( $class, $os_text, $os_version, $arch ) = @_;

    if ($os_text eq 'GNU_Linux') {
        # TODO It's all right?
        ($os_version) = $os_version =~ m/(.*?-.+?)(?:-.*)?/;
    }

    if ($Testament::Config::VM_BACKEND =~ /^vagrant$/) {
        my $vagrant = Testament::Virt::Vagrant->new( os_text => $os_text, os_version => $os_version, arch => $arch );
        $vagrant->install_box();
        return 1;
    }

    my $setup = Testament::Setup->new( os_text => $os_text, os_version => $os_version, arch => $arch );
    my $virt = $setup->do_setup;
    die sprintf('could not setup %s', $os_text) unless $virt;
    my $identify_str = Testament::Util->box_identity($os_text, $os_version, $arch);
    $config->{$identify_str} = $virt->as_hashref;
    Testament::Config->save($config);
    return 1;
}

sub boot {
    my ( $class, $os_text, $os_version, $arch ) = @_;
    my $identify_str = Testament::Util->box_identity($os_text, $os_version, $arch);
    my $box_conf = $config->{$identify_str};
    $box_conf->{id} = $identify_str;
    my $virt = Testament::Virt->new(%$box_conf);
    $virt->boot();
}

sub list {
    my ( $class ) = @_;
    my @running = Testament::Util->running_boxes;
    my $max_l = (sort {$b <=> $a} map {length($_)} keys %$config)[0];
    printf "% ".$max_l."s % 8s % 8s % 8s\n", 'BOX-ID', 'STATUS', 'RAM', 'SSH-PORT';
    for my $id (keys %$config) {
        my $vm = $config->{$id};
        my $status = scalar(grep { $_->{cmd} =~ /$id/ } @running) > 0 ? 'RUNNING' : '---';
        printf "% ".$max_l."s % 8s % 6sMB % 8s\n", $id, $status, $vm->{ram}, $vm->{ssh_port};
    }
}

sub exec {
    my ( $class, $os_text, $os_version, $arch, $cmd ) = @_;
    my $identify_str = Testament::Util->box_identity($os_text, $os_version, $arch);
    die sprintf("%s is not running", $identify_str) unless Testament::Util->is_box_running($identify_str);
    my $box_conf = $config->{$identify_str};
    $box_conf->{id} = $identify_str;
    my @cmdlist = ('ssh', '-p', $box_conf->{ssh_port}, 'root@127.0.0.1');
    push @cmdlist, $cmd if defined $cmd;
    my $spawn = Expect->spawn(@cmdlist);
    $spawn->expect(SPAWN_TIMEOUT,
        ["(yes/no)?" => sub {
            shift->send("yes\n");
        } ],
    );
    $spawn->expect(SPAWN_TIMEOUT,
        [qr/sword/ => sub {
            shift->send("testament\n");
        } ],
    );
    $spawn->interact;
    $spawn->soft_close;
}

sub enter {
    my ( $class, $os_text, $os_version, $arch ) = @_;
    $class->exec($os_text, $os_version, $arch);
}

sub kill {
    my ( $class, $os_text, $os_version, $arch ) = @_;
    my $identify_str = Testament::Util->box_identity($os_text, $os_version, $arch);
    my ( $proc ) = Testament::Util->is_box_running($identify_str);
    die sprintf("%s is not running", $identify_str) unless $proc;
    kill(15, $proc->{pid}); ### SIGTERM
}

sub delete {
    my ( $class, $os_text, $os_version, $arch ) = @_;
    my $identify_str = Testament::Util->box_identity($os_text, $os_version, $arch);
    my ( $proc ) = Testament::Util->is_box_running($identify_str);
    $class->kill($os_text, $os_version, $arch) if $proc;
    my $vmdir = Testament::Util->vmdir($identify_str);
    system("rm -rfv $vmdir");
    delete $config->{$identify_str};
    Testament::Config->save($config);
}

sub file_transfer {
    my ( $class, $os_text, $os_version, $arch, $src, $dst, $mode, @opts ) = @_;
    my $identify_str = Testament::Util->box_identity($os_text, $os_version, $arch);
    die sprintf("%s is not running", $identify_str) unless Testament::Util->is_box_running($identify_str);
    my $box_conf = $config->{$identify_str};
    my @cmdlist = ('scp', '-P', $box_conf->{ssh_port});
    push @cmdlist, @opts if @opts;
    push @cmdlist, $mode eq 'put' ? ($src, 'root@127.0.0.1:'.$dst) : ('root@127.0.0.1:'.$dst, $src);
    my $spawn = Expect->spawn(@cmdlist);
    $spawn->expect(SPAWN_TIMEOUT,
        ["(yes/no)?" => sub {
            shift->send("yes\n");
        } ],
    );
    $spawn->expect(SPAWN_TIMEOUT,
        [qr/sword/ => sub {
            shift->send("testament\n");
        } ],
    );
    $spawn->interact;
    $spawn->soft_close;
}

sub put {
    my ( $class, $os_text, $os_version, $arch, $src, $dst, @opts ) = @_;
    $class->file_transfer($os_text, $os_version, $arch, $src, $dst, 'put', @opts);
}

sub get {
    my ( $class, $os_text, $os_version, $arch, $src, $dst, @opts ) = @_;
    $class->file_transfer($os_text, $os_version, $arch, $src, $dst, 'get', @opts);
}

sub setup_chef {
    my ( $class, $os_text, $os_version, $arch ) = @_;
    my @osparam = ($os_text, $os_version, $arch);
    my $installer    = File::Spec->catdir($Testament::Config::WORKDIR, 'install-chef-solo.sh');
    my $rbenv        = File::Spec->catdir($Testament::Config::WORKDIR, '.rbenv');
    my $rbenv_plugin = File::Spec->catdir($rbenv, 'plugins');
    my $ruby_builder = File::Spec->catdir($rbenv_plugin, 'ruby-build');
    unless ( -e $installer ) {
        Testament::URLFetcher->wget(CHEF_INSTALLER_URL, $installer);
    }
    if (-e $rbenv) {
        Testament::Git->pull($rbenv, 'origin', 'master');
        Testament::Git->pull($ruby_builder, 'origin', 'master');
    }
    else {
        Testament::Git->clone(RBENV_REPO, $rbenv);
        mkdir($rbenv_plugin);
        Testament::Git->clone(RUBYBUILDER_REPO, $ruby_builder);
    }
    $class->put( @osparam, $rbenv, '/root/', '-r' );
    $class->put( @osparam, $installer, '/root/' );
    $class->exec( @osparam, 'sh /root/install-chef-solo.sh' );
}

1;
__END__

=encoding utf-8

=head1 NAME

Testament - TEST AssignMENT

=begin html

<img src="https://travis-ci.org/ytnobody/Testament.png?branch=master">

=end html

=head1 SYNOPSIS

To show failure report for your module,

    $ testament failures Your::Module
    0.05 perl-5.12.1 OpenBSD 5.1 OpenBSD.amd64-openbsd-thread-multi
    0.05 perl-5.10.0 OpenBSD 5.1 OpenBSD.i386-openbsd
    0.05 perl-5.14.4 FreeBSD 9.1-release amd64-freebsd-thread-multi

And, you can create a new box

    $ testament create OpenBSD 5.1 OpenBSD.i386-openbsd

=head1 DESCRIPTION

Testament is a testing environment builder tool.

=head1 USAGE

  testament subcommand [arguments]

=head2 subcommand

=over 4

=item boot [os-test os-version architecture] : boot-up specified box

=item create [os-test os-version architecture] : create environment

=item put [os-test os-version architecture source-file dest-path] : put file into specified box

=item help [(no arguments)] : show this help

=item failures [cpan-module-name] : fetch and show boxes that failures testing

=item get [os-test os-version architecture source-file dest-path] : get file from specified box

=item kill [os-test os-version architecture] : kill specified box

=item setup_chef [os-test os-version architecture] : setup chef-solo into specified box

=item list [(no arguments)] : show boxes in your machine

=item install [os-test os-version architecture] : alias for create

=item enter [os-test os-version architecture] : enter into box

=item version [(no arguments)] : show testament version

=item delete [os-test os-version architecture] : delete specified box

=item exec [os-test os-version architecture commands...] : execute command into box

=back

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody aaaaatttttt gmailE<gt>

moznion

=cut

