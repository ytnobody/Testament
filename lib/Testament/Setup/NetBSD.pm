package Testament::Setup::NetBSD;
use strict;
use warnings;

sub mirror_list_url { 'http://www.netbsd.org/mirrors/' }

sub install {
    my ( $class, $setup ) = @_;

    my $arch_matcher     = qr/^(.*)-netbsd(?:-(.*))?/;
    my $digest_file_name = 'SHA512';

    my $iso_file_builder = sub {
        my ($setup) = @_;

        my $iso_file =
            'NetBSD-'
          . $setup->os_version . '-'
          . $setup->arch_short
          . '.iso';
        return $iso_file;
    };

    my $remote_url_builder = sub {
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
    };

    $setup->install(
        $arch_matcher,     $iso_file_builder,
        $digest_file_name, $remote_url_builder
    );
}
1;
