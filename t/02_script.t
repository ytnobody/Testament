#!perl

use strict;
use warnings;
use utf8;
use Testament;
use Testament::Script;
use Capture::Tiny qw/capture/;

use t::Util;
use Test::More;

subtest 'Show version' => sub {
    my $test_showing_version = sub {
        my @args  = @_;
        my $testament = Testament::Script->new(@args);
        my ($got) = capture { $testament->execute() };
        chomp $got;
        is $got, $Testament::VERSION;
    };

    subtest 'by `-v`' => sub {
        $test_showing_version->( ('-v') );
    };
    subtest 'by `--version`' => sub {
        $test_showing_version->( ('--version') );
    };
};

subtest 'Show help' => sub {
    my $help_message      = join('', (<DATA>));
    my $test_showing_help = sub {
        my (@args) = @_;

        my $data_origin = tell Testament::Script::DATA; # To rewind DATA file handler
        my $testament   = Testament::Script->new(@args);
        my ($got)       = capture { $testament->execute() };
        seek Testament::Script::DATA, $data_origin, 0; # To rewind DATA file handler

        is $got, $help_message;
    };

    subtest 'by empty' => sub {
        $test_showing_help->();
    };
    subtest 'by `help`' => sub {
        $test_showing_help->('help');
    };
};

subtest 'Fetch and show boxes that failure testing' => sub {
    my $guard = t::Util::setup_mock_downloader();

    my $fetch_failures = sub {
        my @args  = @_;
        my $testament = Testament::Script->new(@args);
        my ($got) = capture { $testament->execute() };
        return $got;
    };

    subtest 'not specify version' => sub {
        my $got = $fetch_failures->(('failures', 'Testament::Test::Sandbox'));
        like $got, qr!0\.01 perl-5\.8\.9 OpenBSD 5\.3 OpenBSD.i386-openbsd-thread-multi\n0\.02 perl-5\.10\.0 GNU_Linux 3\.2\.0-4-amd64 x86_64-linux-thread-multi!;
    };

    subtest 'specify version by v0.01' => sub {
        my $got = $fetch_failures->(('failures', 'Testament::Test::Sandbox', '0.01'));
        like $got, qr/0\.01 perl-5\.8\.9 OpenBSD 5\.3 OpenBSD.i386-openbsd-thread-multi/;
    };
};

subtest 'Detect illegal command' => sub {
    my $testament = Testament::Script->new(('ILLEGAL_COMMAND'));
    eval { $testament->execute() };
    like $@, qr/! Unknown command: 'ILLEGAL_COMMAND'/;
};

done_testing;

__DATA__
Usage: testament subcommand [arguments]

* subcommand
  boot [os-test os-version architecture] :  boot-up specified box
  create [os-test os-version architecture] : create environment
  put [os-test os-version architecture source-file dest-path] : put file into specified box
  help [(no arguments)] : show this help
  failures [cpan-module-name] : fetch and show boxes that failures testing
  get [os-test os-version architecture source-file dest-path] : get file from specified box
  kill [os-test os-version architecture] : kill specified box
  setup_chef [os-test os-version architecture] : setup chef-solo into specified box
  list [(no arguments)] : show boxes in your machine
  install [os-test os-version architecture] : alias for create
  enter [os-test os-version architecture] : enter into box
  version [(no arguments)] : show testament version
  delete [os-test os-version architecture] : delete specified box
  exec [os-test os-version architecture commands...] : execute command into box


