#!perl

use strict;
use warnings;
use Testament::Virt::Vagrant::OS::OpenBSD;

use Test::More;

subtest 'Not any extend options' => sub {
    my $os_descriptions = {
        os_text    => 'OpenBSD',
        os_version => '5.2',
        arch       => 'OpenBSD.i386-openbsd',
    };
    my $got =
      Testament::Virt::Vagrant::OS::OpenBSD->argument_builder($os_descriptions);
    is $got->{os},  'openbsd52_i386';
    is $got->{opt}, undef;
};

subtest 'With extend options' => sub {
    my $os_descriptions = {
        os_text    => 'OpenBSD',
        os_version => '5.2',
        arch       => 'OpenBSD.amd64-openbsd-thread-multi',
    };
    my $got =
      Testament::Virt::Vagrant::OS::OpenBSD->argument_builder($os_descriptions);
    is $got->{os},  'openbsd52_amd64';
    is $got->{opt}, 'thread-multi';
};

done_testing;
