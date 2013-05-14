#!perl

use strict;
use warnings;
use JSON;

use Testament::BoxSetting;

use Test::More;

subtest 'Download JSON report from remote (CPAN Testers Report)' => sub {
    my $url  = Testament::BoxSetting::_construct_report_json_url('perl');
    my $json = Testament::BoxSetting::_download_json_test_report($url);
    $json = JSON::decode_json($json);
    my $json_elem = shift @$json;

    is ref $json_elem, 'HASH';
};

done_testing;
