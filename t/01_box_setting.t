#!perl

use strict;
use warnings;
use FindBin;
use Scope::Guard;

use Ament::BoxSetting;

use Test::More;

my $original_download_function = *Ament::BoxSetting::_download_json_test_report{CODE};
my $mock_download_function = sub {
    my $mock_json_file = "$FindBin::Bin/resource/box-setting.json";

    open my $fh, '<', $mock_json_file;
    my $json = '';
    $json .= $_ foreach (<$fh>);
    close $fh;

    return $json;
};
my $setup = sub {
    undef *Ament::BoxSetting::_download_json_test_report;
    *Ament::BoxSetting::_download_json_test_report = $mock_download_function;

    return Scope::Guard->new(
        sub {
            undef *Ament::BoxSetting::_download_json_test_report;
            *Ament::BoxSetting::_download_json_test_report = $original_download_function;
        }
    );
};

subtest 'Fetch all of failed box settings' => sub {
    my $guard = $setup->();

    my @fail_boxes =
      Ament::BoxSetting::fetch_box_setting("Ament::Test::Sandbox");

    is scalar(@fail_boxes), 2;
    foreach my $box (@fail_boxes) {
        is $box->{status}, 'FAIL';
        if ($box->{id} eq '2') {
            is $box->{version}, '0.01';
            next;
        }
        if ($box->{id} eq '3') {
            is $box->{version}, '0.02';
            next;
        }
        fail 'Detect unexpected box setting.';
    }
};

subtest 'Fetch failed box settings that match for specified version' => sub {
    my $guard = $setup->();

    my @fail_boxes =
      Ament::BoxSetting::fetch_box_setting("Ament::Test::Sandbox", '0.02');

    is scalar(@fail_boxes), 1;

    my $box = shift @fail_boxes;
    is $box->{status}, 'FAIL';
    is $box->{id}, '3';
    is $box->{version}, '0.02';
};

subtest 'Exceptional handlings of fetching faild box settings' => sub {
    eval { Ament::BoxSetting::fetch_box_setting() };
    like( $@, qr/fetch_box_setting requires module name\./ );
};

subtest 'Construct JSON url' => sub {
    my $base_url = 'http://www.cpantesters.org/distro';
    my $expected = "$base_url/A/Ament-Test-Sandbox.json";

    my $got = Ament::BoxSetting::_construct_report_json_url('Ament-Test-Sandbox');
    is $got, $expected, 'Hyphen separated';

    $got = Ament::BoxSetting::_construct_report_json_url('Ament::Test::Sandbox');
    is $got, $expected, 'Double colon separated';
};

done_testing;
