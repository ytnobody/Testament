package t::Util;

use strict;
use warnings;

use FindBin;
use Scope::Guard;
use Ament::BoxSetting;

my $original_download_function = *Ament::BoxSetting::_download_json_test_report{CODE};
my $mock_download_function = sub {
    my $mock_json_file = "$FindBin::Bin/resource/box-setting.json";

    open my $fh, '<', $mock_json_file;
    my $json = '';
    $json .= $_ foreach (<$fh>);
    close $fh;

    return $json;
};

sub setup_mock_downloader {
    undef *Ament::BoxSetting::_download_json_test_report;
    *Ament::BoxSetting::_download_json_test_report = $mock_download_function;

    return Scope::Guard->new(
        sub {
            undef *Ament::BoxSetting::_download_json_test_report;
            *Ament::BoxSetting::_download_json_test_report = $original_download_function;
        }
    );
}
1;
