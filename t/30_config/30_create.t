#!perl

# Test Testament::OSList

use strict;
use warnings;
use t::FileUtil;
use FindBin;

use Test::More;

subtest 'create directories and files' => sub {
    my $guard = pushd( tempdir( 'Testament-Temp-XXXX', CLEANUP => 1 ) );

    my $current_dir = getcwd();
    $ENV{TESTAMENT_CONF_FILE} = catfile( $current_dir, 'conffile' );
    $ENV{TESTAMENT_WORKDIR}   = catfile( $current_dir, 'work_dir' );
    $ENV{TESTAMENT_VMDIR}     = catfile( $current_dir, 'vmdir' );

    require( catfile( dirname( dirname($FindBin::Bin) ), 'lib', 'Testament', 'OSList.pm' ) );

    Testament::OSList->create();
    ok( -e $ENV{TESTAMENT_CONF_FILE} );
    ok( -d $ENV{TESTAMENT_WORKDIR} );
    ok( -d $ENV{TESTAMENT_VMDIR} );
};

done_testing;
