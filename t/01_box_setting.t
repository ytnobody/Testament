#!perl

use strict;
use warnings;
use FindBin;

use Ament::BoxSetting;

use t::Util;
use Test::More;

subtest 'Fetch all of failed box settings' => sub {
    # my $guard = $setup->();
    my $guard = t::Util::setup_mock_downloader();

    my @fail_boxes =
      Ament::BoxSetting::fetch_box_setting("Ament::Test::Sandbox");

    is scalar(@fail_boxes), 2;

    my $i = 1;
    foreach my $box (@fail_boxes) {
        is $box->{status}, 'FAIL';

        is $box->{version}, '0.0' . $i;
        $i++;
    }
};

subtest 'Fetch failed box settings that match for specified version' => sub {
    # my $guard = $setup->();
    my $guard = t::Util::setup_mock_downloader();

    my @fail_boxes =
      Ament::BoxSetting::fetch_box_setting("Ament::Test::Sandbox", '0.02');

    is scalar(@fail_boxes), 1;

    my $box = shift @fail_boxes;
    is $box->{status}, 'FAIL';
    is $box->{id}, '3';
    is $box->{version}, '0.02';
};

subtest 'Exceptional handlings of fetching faild box settings' => sub {
    subtest 'When not specified module name' => sub {
        eval { Ament::BoxSetting::fetch_box_setting() };
        like( $@, qr/fetch_box_setting requires module name\./ );
    };

    subtest 'When remote server returns status code that is not 200 a few times' => sub {
        my $original_furl_get = *Furl::get{CODE};
        undef *Furl::get;
        *Furl::get = sub {return {code => '500'}};

        eval {Ament::BoxSetting::fetch_box_setting('Ament::Test::Sandbox')};
        like( $@, qr/Connection timeout \(Attempt 3 times\)\./ );

        undef *Furl::get;
        *Furl::get = $original_furl_get;
    };
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
