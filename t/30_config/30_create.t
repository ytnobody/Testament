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

subtest 'create directories and files' => sub {
    my $guard = pushd( tempdir( 'Testament-Temp-XXXX', CLEANUP => 1 ) );

    my $current_dir = Cwd::getcwd();
    $ENV{TESTAMENT_CONF_FILE} = File::Spec->catfile( $current_dir, 'conffile' );
    $ENV{TESTAMENT_WORKDIR}   = File::Spec->catfile( $current_dir, 'work_dir' );
    $ENV{TESTAMENT_VMDIR}     = File::Spec->catfile( $current_dir, 'vmdir' );

    require File::Spec->catfile( dirname( dirname($FindBin::Bin) ), 'lib', 'Testament', 'Config.pm' );

    Testament::Config->create();
    ok( -e $ENV{TESTAMENT_CONF_FILE} );
    ok( -d $ENV{TESTAMENT_WORKDIR} );
    ok( -d $ENV{TESTAMENT_VMDIR} );
};

done_testing;
