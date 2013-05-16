package Testament::Setup::OpenBSD;
use strict;
use warnings;
use Testament::URLFetcher;
use Testament::Util;
use Testament::FastestMirror;
use Testament::Virt;
use Testament::Setup;
use File::Spec;
use Log::Minimal;
use Digest::SHA2;

my @MIRRORS;

sub opt_mirror {
    my $class           = shift;
    my $mirror_list_url = 'http://www.openbsd.org/ftp.html';
    @MIRRORS or @MIRRORS = Testament::Setup->fetch_mirrors($mirror_list_url);
    return Testament::FastestMirror->pickup(@MIRRORS);
}

sub install {
    my ( $class, $version, $arch, $vmdir ) = @_;

    # arch_opt: e.g. "thread-multi", "int64", etc...
    my $arch_opt;
    ( $arch, $arch_opt ) = $arch =~ /^OpenBSD\.(.*)-openbsd(?:-(.*))?/;
    my $virt = Testament::Virt->new( arch => $arch );
    my $install_image = $class->get_install_image( $version, $arch, $vmdir );
    if ($install_image) {
        my $hda = File::Spec->catfile( $vmdir, 'hda.img' );
        $virt->create_image($hda);
        $virt->hda($hda);
        $virt->cdrom($install_image);
        $virt->boot('d');
        $virt->{cdrom} = undef;
        return $virt;
    }
    else {
        critf('install image file is illegal');
        die;
    }
}

sub get_install_image {
    my ($class, $version, $arch, $vmdir) = @_;
    (my $isofile = 'install'. $version . '.iso') =~ s/\.//;
    my $install_image = File::Spec->catfile($vmdir, $isofile);
    unless( $class->check_install_image($version, $arch, $vmdir, $isofile) ) {
        my $mirror = $class->opt_mirror;
        my $url = sprintf("%s/%s/%s/%s", $mirror, $version, $arch, $isofile);
        Testament::URLFetcher->wget($url, $install_image);
        return unless $class->check_install_image($version, $arch, $vmdir, $isofile);
    }
    return $install_image;
}

sub check_install_image {
    my ($class, $version, $arch, $vmdir, $isofile) = @_;
    my $digest_file = File::Spec->catfile($vmdir, 'SHA256');
    my $install_image = File::Spec->catfile($vmdir, $isofile);
    unless ( -e $install_image ) {
        warnf('install image file %s is not found', $install_image);
        return;
    }
    my $mirror = $class->opt_mirror;
    my $url = sprintf("%s/%s/%s/%s", $mirror, $version, $arch, 'SHA256');
    Testament::URLFetcher->wget($url, $digest_file);
    my $filename = my $sha256 = undef;
    for my $line (split /\n/, Testament::Util->file_slurp($digest_file)) {
        chomp $line;
        ($filename, $sha256) = $line =~ /^SHA256 \((.+)\) = ([0-9a-f]+)$/;
        last if $filename eq $isofile;
    }
    unless($sha256 eq $class->file_sha256($install_image)) {
        critf('sha256 digest is not match : wants = %s', $sha256);
        return;
    }
    return $install_image;
}

sub file_sha256 {
    my ($class, $path) = @_;
    infof('checking sha256 digest for file %s', $path);
    my $fh;
    unless ( open $fh, '<', $path ) {
        critf('could not open file %s', $path);
    }
    my $sha2obj = Digest::SHA2->new;
    $sha2obj->addfile($fh);
    my $rtn = $sha2obj->hexdigest;
    infof('sha256 = %s', $rtn);
    close $fh;
    return $rtn;
}

1;
