package Ament::Setup::openbsd;
use strict;
use warnings;
use Ament::URLFetcher;
use Ament::Util;
use Ament::FastestMirror;
use File::Spec;

our @MIRRORS;

sub mirrors {
    my $class = shift;
    return @MIRRORS if @MIRRORS;
    my $res = Ament::URLFetcher->get('http://www.openbsd.org/ftp.html');
    @MIRRORS = $res =~ /href\=\"(ftp:\/\/.+?)\"/g;
    return @MIRRORS;
}

sub opt_mirror {
    my $class = shift;
    my @mirrors = $class->mirrors;
    return Ament::FastestMirror->pickup(@mirrors);
}

sub install {
    my ($class, $version, $arch, $vmdir) = @_;
    my $install_image = $class->get_install_image($version, $arch, $vmdir);
    my $hda = Ament::Util->create_hda($vmdir);
    my @opts = ('-hda' => $hda, '-cdrom' => $install_image);
    Ament::Util->qemu(@opts, '-boot' => 'd');
    return @opts;
}

sub get_install_image {
    my ($class, $version, $arch, $vmdir) = @_;
    (my $isofile = 'install'. $version . '.iso') =~ s/\.//;
    my $install_image = File::Spec->catfile($vmdir, $isofile);
    return $install_image if -e $install_image;
    my $mirror = $class->opt_mirror;
    my $url = sprintf("%s/%s/%s/%s", $mirror, $version, $arch, $isofile);
    Ament::URLFetcher->wget($url, $install_image);
    return $install_image;
}

1;
