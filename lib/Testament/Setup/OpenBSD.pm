package Testament::Setup::OpenBSD;
use strict;
use warnings;
use parent 'Testament::Setup::Interface';
use Testament::URLFetcher;

our $MIRROR_LIST = 'http://www.openbsd.org/ftp.html';

sub mirrors {
    my $class = shift;
    my $res   = Testament::URLFetcher->get($MIRROR_LIST);
    return ( $res =~ /href\=\"(ftp:\/\/.+?)\"/g );
}

sub prepare_install {
    my ( $class, $setup ) = @_;

    ($setup->{arch_short}, $setup->{arch_opt}) = $setup->arch =~ qr/^OpenBSD\.(.*)-openbsd(?:-(.*))?/;

    $setup->digest_file_name('SHA256');

    $setup->iso_file(do {
        (my $iso_file = 'install' . $setup->os_version . '.iso') =~ s/\.//;
        $iso_file;
    });

    $setup->remote_url_builder(sub {
        my ($setup, $filename) = @_;
        sprintf("%s/%s/%s/%s", $setup->mirror, $setup->os_version, $setup->arch_short, $filename);
    });
}
1;
