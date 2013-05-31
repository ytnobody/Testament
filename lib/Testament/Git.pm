package Testament::Git;
use strict;
use warnings;
use Cwd;
use Scope::Guard;

sub clone {
    my ( $repository, $target ) = @_;
    system( sprintf( "git clone %s %s", $repository, $target ) );
}

sub pull {
    my ( $path, $branch ) = @_;

    my $guard = _will_be_right_back($path);
    system( sprintf( "git pull origin %s", $branch ) );
}

sub checkout {
    my ( $path, $branch ) = @_;

    my $guard = _will_be_right_back($path);
    system( sprintf( "git checkout %s", $branch ) );
}

sub _will_be_right_back {
    my $destination = shift;

    my $cwd = getcwd();
    chdir $destination;

    return Scope::Guard->new(sub {
        chdir $cwd;
    });
}
1;
