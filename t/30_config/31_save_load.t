#!perl

use strict;
use warnings;
use Cwd;
use File::Basename;
use File::pushd;
use File::Temp qw/tempdir/;
use File::Spec;
use FindBin;

use Test::More;

my $guard       = pushd( tempdir( 'Testament-Temp-XXXX', CLEANUP => 1 ) );
my $current_dir = Cwd::getcwd();

$ENV{TESTAMENT_CONF_FILE} = File::Spec->catfile( $current_dir, 'conffile' );
require File::Spec->catfile( dirname( dirname($FindBin::Bin) ), 'lib', 'Testament', 'Config.pm' );
Testament::Config::create_conf_file();

subtest 'create conf file and load successfully' => sub {
    my $expected = {
        foo => 'bar'
    };
    Testament::Config->save($expected);

    my $got = Testament::Config::load();
    is_deeply $got, $expected;
};

subtest 'save without config value' => sub {
    my $got = Testament::Config->save();
    is $got, undef;
};

done_testing;
