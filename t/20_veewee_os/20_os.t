#!perl

use strict;
use warnings;
use Testament::Virt::Vagrant::OS;

use Test::More;

subtest 'Does general argument_builder work rightly?' => sub {
    my $os_descriptions = {
        os_text    => 'OpenBSD',
        os_version => '5.2',
        arch       => 'OpenBSD.i386-openbsd',
    };
    my $got = Testament::Virt::Vagrant::OS->argument_builder($os_descriptions);
    is $got->{os},  'openbsd52_i386';
};

done_testing;
