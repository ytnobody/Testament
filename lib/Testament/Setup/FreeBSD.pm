package Testament::Setup::FreeBSD;
use strict;
use warnings;
use parent 'Testament::Setup::Base';

sub mirror_list_url { 'http://www.freebsd.org/handbook/mirrors-ftp.html' }

sub install {
    my ( $class, $setup ) = @_;

    my $arch_matcher     = qr/^(.*)-freebsd(?:-(.*))?/;
    my $digest_file_name = 'CHECKSUM.SHA256';

    my $iso_file_builder = sub {
        my ($setup) = @_;

        my $iso_file =
            'FreeBSD-'
          . uc( $setup->os_version ) . '-'
          . $setup->arch_short
          . '-disc1.iso';
        return $iso_file;
    };

    my $remote_url_builder = sub {
        my ( $setup, $filename ) = @_;
        my $country_matcher = sub {
            my $country = shift;
            qr!^FTP\d*\.$country!;
        };

        ( my $os_version = $setup->os_version ) =~ s/-release//;
        return sprintf(
            "%s/releases/%s/ISO-IMAGES/%s/%s",
            $setup->mirror($country_matcher),
            $setup->arch_short, $os_version, $filename
        );
    };

    $setup->install(
        $arch_matcher,     $iso_file_builder,
        $digest_file_name, $remote_url_builder
    );
}
1;
