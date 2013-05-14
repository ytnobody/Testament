package Testament::Util;
use strict;
use warnings;
use Log::Minimal;
use File::Spec;
use Testament::Config;

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

sub box_identity {
    my ($class, $os_text, $os_version, $arch) = @_;
    return join('-', $os_text, $os_version, $arch);
}

sub vmdir {
    my ($class, $identify_str) = @_;
    File::Spec->rel2abs(File::Spec->catdir($Testament::Config::VMDIR, $identify_str));
}

1;
