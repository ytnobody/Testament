package Testament::Setup::OpenBSD;
use strict;
use warnings;

sub mirror_list_url { 'http://www.openbsd.org/ftp.html' }

sub install {
    my ( $class, $setup ) = @_;

    my $arch_matcher     = qr/^OpenBSD\.(.*)-openbsd(?:-(.*))?/;
    my $digest_file_name = 'SHA256';

    my $iso_file_builder = sub {
        my ($setup) = @_;

        ( my $iso_file = 'install' . $setup->os_version . '.iso' ) =~ s/\.//;
        return $iso_file;
    };

    my $remote_url_builder = sub {
        my ( $setup, $filename ) = @_;

        my $country_matcher = sub {
            my $country = shift;
            qr/\.$country$/;
        };
        return sprintf( "%s/%s/%s/%s",
            $setup->mirror($country_matcher),
            $setup->os_version, $setup->arch_short, $filename );
    };

    $setup->install(
        $arch_matcher,     $iso_file_builder,
        $digest_file_name, $remote_url_builder,
        'set tty com0', 5
    );
}
1;
