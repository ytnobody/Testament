package Ament::Script;

use strict;
use warnings;
use utf8;
use Carp;
use Ament;
use Ament::BoxSetting;

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

sub execute {
    my ($self) = @_;

    my $code = $self->can("_CMD_$self->{cmd}");
    $code or croak "! Unknown command: '$self->{cmd}'";
    $self->$code();
}

# Create environment
sub _CMD_create {
    my ($self) = @_;

    my @args = @{ $self->{args} };
    unless (@args) {

        # TODO implement!
        # interaction mode
        ...;
    }

    my ( $os_text, $os_version, $arch ) = @{ $self->{args} };
    Ament->setup( $os_text, $os_version, $arch );
}

# TODO Is it really necessary?
# Alias of `create`
sub _CMD_install {
    my ($self) = @_;
    $self->_CMD_create();
}

# Fetch and show boxes that failures testing.
sub _CMD_failures {
    my ($self) = @_;

    my @args    = @{ $self->{args} };
    my $distro  = shift @args;
    my $version = shift @args;

    my @failed_boxes = Ament::BoxSetting::fetch_box_setting($distro, $version);
    foreach my $box (@failed_boxes) {
        # TODO consider layout
        print "$box->{version} perl-$box->{perl} $box->{ostext} $box->{osvers} $box->{platform}\n";
    }
}

# Show version
sub _CMD_version {
    print "$Ament::VERSION\n";
}

# Show help tips
sub _CMD_help {
    # TODO implement!!!!
    my $help = << 'EOH';
Usage: ament COMMAND [...]
EOH

    print "$help";
}

1;
