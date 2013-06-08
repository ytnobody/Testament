#!perl

use strict;
use warnings;
use t::FileUtil;
use FindBin;

use Test::More;

my $guard       = pushd( tempdir( 'Testament-Temp-XXXX', CLEANUP => 1 ) );
my $current_dir = getcwd();

$ENV{TESTAMENT_CONF_FILE} = catfile( $current_dir, 'conffile' );
require( catfile( dirname( dirname($FindBin::Bin) ), 'lib', 'Testament', 'OSList.pm' ) );
Testament::OSList::create_conf_file();

subtest 'create conf file and load successfully' => sub {
    my $expected = {
        foo => 'bar'
    };
    Testament::OSList->save($expected);

    my $got = Testament::OSList::load();
    is_deeply $got, $expected;
};

subtest 'save without config value' => sub {
    my $got = Testament::OSList->save();
    is $got, undef;
};

done_testing;
