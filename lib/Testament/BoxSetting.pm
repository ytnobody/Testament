package Testament::BoxSetting;

use strict;
use warnings;
use Carp;
use Furl;
use JSON;
use List::Util qw/first/;

use constant SUCCESS_CODE => 200;
use constant SUPPORTED_OS => ( 'OpenBSD', 'FreeBSD', 'NetBSD', 'GNU/Linux' );    # TODO

sub fetch_failed_boxes {
    my ( $distro, $version ) = @_;

    # TODO consider messages.
    $distro or croak "fetch_failed_boxes requires module name.";

    my $json =
      _download_json_test_report( _construct_report_json_url($distro) );
    $json = JSON::decode_json($json);

    my @fail_boxes = grep { $_->{status} eq 'FAIL' } @$json;
    @fail_boxes = _filter_by_supported_os(@fail_boxes);
    @fail_boxes = sort { $a->{version} <=> $b->{version} } @fail_boxes; # sort by version

    $version or return @fail_boxes;
    @fail_boxes = grep { $_->{version} == $version } @fail_boxes;
    return @fail_boxes;
}

sub _download_json_test_report {
    my ($url) = @_;

    my $error_count             = 0;
    my $permissible_error_count = 3;    # <= TODO consider!

    my $download;
    $download = sub {
        my $response = Furl->new()->get($url);    # TODO configurable timeout?
             # TODO add handling when it returns 404
        if ( $response->{code} != SUCCESS_CODE ) {
            if ( ++$error_count > $permissible_error_count ) {
                croak "Connection timeout "
                  . "(Attempt $permissible_error_count times)." # TODO consider!
            }
            return $download->();
        }
        return $response->{content};
    };

    return $download->();
}

sub _construct_report_json_url {
    my ($distro) = @_;

    my $base_url = 'http://www.cpantesters.org/distro';
    my $first_letter = substr( $distro, 0, 1 );
    $distro =~ s/::/-/g;

    return "$base_url/$first_letter/$distro.json";
}

sub _filter_by_supported_os {
    my (@boxes) = @_;

    @boxes = grep {
        my $fail_box = $_;
        grep { $_ eq $fail_box->{ostext} } SUPPORTED_OS;
    } @boxes;

    # For Linux (GNU/Linux -> GNU_Linux)
    @boxes = map { $_->{ostext} =~ s!/!_!; $_; } @boxes;
}

1;
