package Testament::Git;
use strict;
use warnings;
use Testament::Util;

sub clone {
    my ( $repository, $target ) = @_;
    system( sprintf( "git clone %s %s", $repository, $target ) );
}

sub pull {
    my ( $path, $branch ) = @_;

    my $guard = Testament::Util->will_be_right_back($path);
    system( sprintf( "git pull origin %s", $branch ) );
}

sub checkout {
    my ( $path, $branch ) = @_;

    my $guard = Testament::Util->will_be_right_back($path);
    system( sprintf( "git checkout %s", $branch ) );
}
1;
