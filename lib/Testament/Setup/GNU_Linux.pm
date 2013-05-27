package Testament::Setup::GNU_Linux;
use strict;
use warnings;

# This module supports for Ubuntu-server.

use constant UBUNTU_VERSION => '13.04';
sub mirror_list_url { 'https://launchpad.net/ubuntu/+cdmirrors' }

sub install {
    my ( $class, $setup ) = @_;

    my $arch_matcher     = qr/^(.*)-linux(?:-(.*))?/;
    my $digest_file_name = 'SHA256SUMS';

    my $iso_file_builder = sub {
        my ($setup) = @_;

        my $arch_short = $setup->arch_short;
        $arch_short = 'amd64' if $arch_short eq 'x86_64';
        my $iso_file =
          'ubuntu-' . UBUNTU_VERSION . '-server-' . $arch_short . '.iso';
        return $iso_file;
    };

    my $remote_url_builder = sub {
        my ( $setup, $filename ) = @_;
        my $country_matcher = sub {
            my $country = shift;
            qr!^.*?\.$country!;
        };

        ( my $os_version = $setup->os_version ) =~ s/-.*//;

        return sprintf( "%s/%s/%s",
            $setup->mirror($country_matcher),
            UBUNTU_VERSION, $filename );
    };

    $setup->install(
        $arch_matcher,     $iso_file_builder,
        $digest_file_name, $remote_url_builder
    );
}
1;
