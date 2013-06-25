package Testament::Script;

use strict;
use warnings;
use utf8;
use Carp;
use Testament;
use Testament::BoxSetting;
use Testament::Util;
use Data::Dumper::Concise ();

sub new {
    my ( $class, @args ) = @_;
    my $cmd = shift @args;

    $cmd or $cmd = 'help';
    if ( $cmd eq '-v' || $cmd eq '--version' ) {
        $cmd = 'version';
    }

    bless {
        cmd  => $cmd,
        args => \@args,
    }, $class;
}

sub mangle_args {
    my $self = shift;
    my $args = $self->{args};
    return scalar(@$args) < 3 ? 
        (Testament::BoxUtils->parse_box_identity(shift(@$args)), @$args) :
        (shift(@$args), shift(@$args), shift(@$args))
    ;
}

sub execute {
    my ($self) = @_;

    my $code = $self->can("_CMD_$self->{cmd}");
    $code or croak "! Unknown command: '$self->{cmd}'";
    $self->$code();
}

sub _CMD_create {
    doc_note('create environment');
    doc_args('os-test os-version architecture');
    my ($self) = @_;

    unless ( @{ $self->{args} }) {

        # TODO implement!
        # interaction mode
        die 'Interaction mode has not implemented yet.'
    }

    my ( $os_text, $os_version, $arch ) = @{ $self->{args} };
    Testament->setup( $os_text, $os_version, $arch );
}

# TODO Is it really necessary?
sub _CMD_install {
    doc_note('alias for create');
    doc_args('os-test os-version architecture');
    my ($self) = @_;
    $self->_CMD_create();
}

sub _CMD_failures {
    doc_note('fetch and show boxes that failures testing');
    doc_args('cpan-module-name');
    my ($self) = @_;

    my @args    = @{ $self->{args} };
    my $distro  = shift @args;
    my $version = shift @args;

    my @failed_boxes = Testament::BoxSetting::fetch_failed_boxes($distro, $version);
    foreach my $box (@failed_boxes) {
        # TODO consider layout
        print "$box->{version} perl-$box->{perl} $box->{ostext} $box->{osvers} $box->{platform}\n";
    }
}

sub _CMD_boot {
    doc_note('boot-up specified box');
    doc_args('os-test os-version architecture');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch ) = $self->mangle_args;
    Testament->boot( $os_text, $os_version, $arch );
}

sub _CMD_version {
    doc_note('show testament version');
    doc_args('(no arguments)');
    print "$Testament::VERSION\n";
}

sub _CMD_list {
    doc_note('show boxes in your machine');
    doc_args('(no arguments)');
    Testament->list;
}

sub _CMD_enter {
    doc_note('enter into box');
    doc_args('os-test os-version architecture');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch ) = $self->mangle_args;
    Testament->enter( $os_text, $os_version, $arch );
}

sub _CMD_exec {
    doc_note('execute command into box');
    doc_args('os-test os-version architecture commands...');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch, @cmdlist ) = $self->mangle_args;
    my $cmd = join(' ', @cmdlist);
    Testament->exec( $os_text, $os_version, $arch, $cmd );
}

sub _CMD_kill {
    doc_note('kill specified box');
    doc_args('os-test os-version architecture');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch ) = $self->mangle_args;
    Testament->kill( $os_text, $os_version, $arch);
}

sub _CMD_delete {
    doc_note('delete specified box');
    doc_args('os-test os-version architecture');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch ) = $self->mangle_args;
    Testament->delete( $os_text, $os_version, $arch);
}

sub _CMD_put {
    doc_note('put file into specified box');
    doc_args('os-test os-version architecture source-file dest-path');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch, $src, $dst ) = $self->mangle_args;
    Testament->put( $os_text, $os_version, $arch, $src, $dst );
}

sub _CMD_get {
    doc_note('get file from specified box');
    doc_args('os-test os-version architecture source-file dest-path');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch, $src, $dst ) = $self->mangle_args;
    Testament->get( $os_text, $os_version, $arch, $src, $dst );
}

sub _CMD_install_perl {
    doc_note('setup specified version perl into specified box');
    doc_args('os-test os-version architecture version');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch, $version ) = $self->mangle_args;
    Testament->install_perl( $os_text, $os_version, $arch, $version );
}

sub _CMD_box_config {
    doc_note('config parameter of specified box');
    doc_args('os-test os-version architecture key=value');
    my ($self) = @_;
    my ( $os_text, $os_version, $arch, $keyval ) = $self->mangle_args;
    my ($key, $val) = split '=', $keyval, 2;
    Testament->box_config( $os_text, $os_version, $arch, $key, $val );
}

# document generator (please better thing!)
sub _gen_doc {
    no strict 'refs';
    my ($self, $method) = @_;
    my ($subcmd) = $method =~ m[^_CMD_(.+)];
    my $code = Data::Dumper::Concise::Dumper(\&{$method});
    my ($args) = $code =~ m[doc_args\(\'(.+)\'\)];
    my ($note) = $code =~ m[doc_note\(\'(.+)\'\)];
    return sprintf('%s [%s] : %s', $subcmd, $args, $note);
}

# Show help tips
sub _CMD_help {
    doc_note('show this help');
    doc_args('(no arguments)');
    no strict 'refs';
    my ($self) = shift;
    my @subcommands = map {$self->_gen_doc($_);} grep {/^_CMD_/} keys %{'Testament::Script::'};
    my $subcmd_note = join("\n  ", @subcommands);
    my $help = join('', (<DATA>));
    $help =~ s/__subcommands__/$subcmd_note/;
    print "$help";
}

sub doc_args {} # dummy stuff
sub doc_note {} # dummy stuff

1;
__DATA__
Usage: testament subcommand [arguments]

* subcommand
  __subcommands__


