package Testament::Setup::FreeBSD;
use strict;
use warnings;
use parent 'Testament::Setup::Interface';

our $MIRROR_LIST = 'http://www.freebsd.org/handbook/mirrors-ftp.html';

sub mirrors {
    my $class = shift;
    my $res   = Testament::URLFetcher->get($MIRROR_LIST);
    return ( $res =~ /href\=\"(ftp:\/\/.+?)\"/g );
};

sub prepare_install {
    my ( $class, $setup ) = @_;

    ($setup->{arch_short}, $setup->{arch_opt}) = $setup->arch =~ qr/^(.*)-freebsd(?:-(.*))?/;

    $setup->digest_file_name('CHECKSUM.SHA256');

    $setup->iso_file(
        sprintf('FreeBSD-%s-%s-disc1.iso', uc($setup->os_version), $setup->arch_short)
    );

    $setup->remote_url_builder(sub {
        my ($setup, $filename) = @_;
        my $country_matcher = sub {
            my $country = shift;
            qr!^FTP\d*\.$country!;
        };

        (my $os_version = $setup->os_version) =~ s/-release//;
        return sprintf(
            "%s/releases/%s/ISO-IMAGES/%s/%s",
            $setup->mirror($country_matcher),
            $setup->arch_short, $os_version, $filename
        );
    });
}
1;
