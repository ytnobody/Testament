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
use Testament::Virt::Vagrant::Veewee;

use Test::More;
plan skip_all => "Skip test of fetching veewee." unless $ENV{TESTAMENT_DEVELOPMENT};

subtest 'Clone veewee correctly.' => sub {
    my $veewee_dir = File::Spec->catfile( $FindBin::Bin, 'veewee' );
    Testament::Virt::Vagrant::Veewee->new();
    ok( -d $veewee_dir );
};

done_testing;
