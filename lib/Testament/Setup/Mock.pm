package Testament::Setup::Mock;
use strict;
use warnings;
use parent 'Testament::Setup::Base';

sub mirror_list_url { 'https://raw.github.com/ytnobody/Testament/master/misc/mock_mirrors.html' }

sub url_capture_rule { qr/href=\"(.*)\"/ }

sub install {
    my ( $class, $setup ) = @_;

    my $arch_matcher     = qr/^\.(.*)(?:-(.*))?/;
    my $digest_file_name = 'mock_SHA256';
    my $iso_file = 'mock_img.iso';

    my $iso_file_builder = sub { $iso_file };

    my $remote_url_builder = sub {
        my ( $setup, $filename ) = @_;

        my $country_matcher = sub {
            my $country = shift;
            qr/\.$country$/;
        };
        my $url = $setup->mirror($country_matcher);
        $url =~ s/$iso_file/$digest_file_name/;
        warn $url;
        return $url;
    };

    $setup->install(
        $arch_matcher,     $iso_file_builder,
        $digest_file_name, $remote_url_builder,
        'set tty com0', 5
    );
}
1;
