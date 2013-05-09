#!perl

use strict;
use warnings;
use JSON;

use Ament::BoxSetting;

use Test::More;

subtest 'Download JSON report from remote (CPAN Testers Report)' => sub {
    my $url  = Ament::BoxSetting::_construct_report_json_url('perl');
    my $json = Ament::BoxSetting::_download_json_test_report($url);
    $json = JSON::decode_json($json);
    my $json_elem = shift @$json;

    is ref $json_elem, 'HASH';
};

done_testing;
