package Testament::Setup::NetBSD;
use strict;
use warnings;
use parent 'Testament::Setup::Interface';

our $MIRROR_LIST = 'http://www.netbsd.org/mirrors/';

sub mirrors {
    my $class = shift;
    my $res   = Testament::URLFetcher->get($MIRROR_LIST);
    return ( $res =~ /href\=\"(ftp:\/\/.+?)\"/g );
}

sub prepare_install {
    my ($class, $setup) = @_;

    ($setup->{arch_short}, $setup->{arch_opt}) = $setup->arch =~ qr/^(.*)-netbsd(?:-(.*))?/;

    $setup->digest_file_name('SHA512');

    $setup->iso_file(sprintf('NetBSD-%s-%s.iso', $setup->os_version, $setup->arch_short));

    $setup->remote_url_builder(sub {
        my ( $setup, $filename ) = @_;
        my $country_matcher = sub {
            my $country = shift;
            qr!^FTP\d*\.$country.*NetBSD/$!;
        };

        my $ftp_regexp  = qr!NetBSD/$!;
        my $os_fullname = $setup->os_text . '-' . $setup->os_version;
        return sprintf(
            "%s/%s-%s/images/%s",
            $setup->mirror($country_matcher, $ftp_regexp), $setup->os_text, $setup->os_version,
            $filename
        );
    });
}
1;
