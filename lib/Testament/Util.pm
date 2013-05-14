package Testament::Util;
use strict;
use warnings;
use Log::Minimal;

sub mkdir {
    my ($class, $path) = @_;
    return 1 if -e $path;
    infof('mkdir %s', $path);
    unless( mkdir $path ) {
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

1;
