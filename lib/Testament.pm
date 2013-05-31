package Testament;
use 5.008005;
use strict;
use warnings;
use Testament::Setup;
use Testament::Config;
use Testament::Virt;
use Testament::Util;
use Expect;

our $VERSION = "0.01";
my $config = Testament::Config->load;

sub setup {
    my ( $class, $os_text, $os_version, $arch ) = @_;

    if ($os_text eq 'GNU_Linux') {
        # TODO It's all right?
        ($os_version) = $os_version =~ m/(.*?-.+?)(?:-.*)?/;
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
    $spawn->expect(1,
        ["(yes/no)?" => sub {
            shift->send("yes\n");
        } ],
    );
    $spawn->expect(1,
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

1;
__END__

=encoding utf-8

=head1 NAME

Testament - TEST AssignMENT

=head1 SYNOPSIS

To show failure report for your module,

    $ testament failures Your::Module
    0.05 perl-5.12.1 OpenBSD 5.1 OpenBSD.amd64-openbsd-thread-multi
    0.05 perl-5.10.0 OpenBSD 5.1 OpenBSD.i386-openbsd
    0.05 perl-5.14.4 FreeBSD 9.1-release amd64-freebsd-thread-multi

And, you can create virtual environment

    $ testament create OpenBSD 5.1 OpenBSD.i386-openbsd

=head1 DESCRIPTION

Testament is a testing environment builder tool.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody aaaaatttttt gmailE<gt>

moznion

=cut

