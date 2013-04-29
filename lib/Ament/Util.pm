package Ament::Util;
use strict;
use warnings;
use Ament::Config;
use File::Spec;
use Log::Minimal;
use Net::EmptyPort 'empty_port';

sub qemu {
    my $class = shift;
    my $options = join(' ', @_);
    my $port = empty_port();
    my $cmd = sprintf('%s %s --redir tcp:%s::22', $Ament::Config::QEMU_BIN, $options, $port);
    infof($cmd);
    `$cmd`;
}

sub qemu_img {
    my $class = shift;
    my $options = join(' ', @_);
    my $cmd = sprintf('%s %s', $Ament::Config::QEMU_IMG_BIN, $options);
    infof($cmd);
    `$cmd`;
}

sub create_hda {
    my ($class, $dir, $size) = @_;
    $size ||= '4G';
    my $path = File::Spec->rel2abs(File::Spec->catfile($dir, 'hda.img'));
    return $path if -e $path;
    $class->qemu_img(qw(create -f qcow2), $path, $size);
    return $path;
}

sub mkdir {
    my ($class, $path) = @_;
    return 1 if -e $path;
    infof('mkdir %s', $path);
    unless( mkdir $path ) {
        critf('failed to mkdir %s', $path);
        die;
    }
}

1;
