package Testament::Git;
use strict;
use warnings;
use Testament::Util;

sub new {
    my ($class) = @_;
    Testament::Util->verify_required_commands( ['git'] );
    return $class;
}

sub clone {
    my ( $self, $repository, $target ) = @_;
    system( sprintf( "git clone %s %s", $repository, $target ) );
}

sub pull {
    my ( $self, $path, $branch ) = @_;

    my $guard = Testament::Util->will_be_right_back($path);
    system( sprintf( "git pull origin %s", $branch ) );
}

sub checkout {
    my ( $self, $path, $branch ) = @_;

    my $guard = Testament::Util->will_be_right_back($path);
    system( sprintf( "git checkout %s", $branch ) );
}
1;
