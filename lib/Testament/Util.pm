package Testament::Util;
use strict;
use warnings;
use Cwd;
use File::Path ();
use Log::Minimal;
use File::Spec;
use Scope::Guard;
use IO::Handle;

sub mkdir {
    my ($class, $path) = @_;
    return 1 if -e $path;
    infof('mkdir %s', $path);
    unless( File::Path::mkpath $path ) {
        critf('failed to mkdir %s', $path);
        die;
    }
}

sub file_slurp {
    my ($class, $path) = @_;
    my $fh;
    unless (open $fh, '<', $path) {
        critf('could not read file : %s', $path);
        return;
    }
    my $data = join('', map {$_} <$fh>);
    close $fh;
    return $data;
}

sub will_be_right_back {
    my ($class, $destination) = @_;

    my $cwd = getcwd();
    chdir $destination;

    return Scope::Guard->new(sub {
        chdir $cwd;
    });
}

sub verify_required_commands {
    my ($class, $required_commands) = @_;

    foreach my $required_command (@$required_commands) {
        my $which_command = sprintf( "which %s", $required_command );
        my $err = system("$which_command >/dev/null 2>&1");
        if ($err) {
            die "[Error] Please install `$required_command`.";
        }
    }
}

sub confirm {
    my ($class, $message, $default) = @_;
    autoflush STDOUT, 1;
    print $default ? $message. " [$default] " : $message. " ";
    autoflush STDOUT, 0;
    my $res = getline STDIN;
    $res =~ s/\n//;
    return $res || $default;
}

1;
