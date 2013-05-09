package Ament::BoxSetting;

use strict;
use warnings;
use Carp;
use Furl;
use JSON;

use constant SUCCESS_CODE => 200;

sub fetch_box_setting {
    my ( $distro, $version ) = @_;

    # TODO consider messages.
    $distro or croak "fetch_box_setting requires module name.";

    my $json = _download_json_test_report( _construct_report_json_url($distro) );
    $json = JSON::decode_json($json);

    my @fail_boxes = grep { $_->{status} eq 'FAIL' } (@$json);

    $version or return @fail_boxes;
    @fail_boxes = grep { $_->{version} == $version } (@fail_boxes);
    return @fail_boxes;
}

sub _download_json_test_report {
    my ($url) = @_;

    # TODO Should it be configurable time out setting?
    my $response = new Furl()->get($url);
    if ( $response->{code} != SUCCESS_CODE ) {

        # TODO Write exceptional handling
    }

    return $response->{content};
}

sub _construct_report_json_url {
    my ($distro) = @_;

    my $base_url = 'http://www.cpantesters.org/distro';
    my $first_letter = substr( $distro, 0, 1 );
    $distro =~ s/::/-/g;

    return "$base_url/$first_letter/$distro.json";
}
1;
