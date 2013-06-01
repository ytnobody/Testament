#!perl

use strict;
use warnings;
use File::Path;
use File::Spec;
use FindBin;
use Scope::Guard;
BEGIN {
    $ENV{TESTAMENT_WORKDIR} = $FindBin::Bin;
}

# Testing Target
use Testament::Vagrant::Veewee;

use Test::More;

subtest 'Clone veewee correctly.' => sub {
    my $veewee_dir = File::Spec->catfile( $FindBin::Bin, 'veewee' );
    Testament::Vagrant::Veewee->new();
    ok( -d $veewee_dir );
};

done_testing;
