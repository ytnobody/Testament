#!perl

use strict;
use warnings;

use Test::More;

subtest 'Die when any required commands does not exist' => sub {
    my $original_path = $ENV{PATH};
    $ENV{PATH} = undef;

    eval { Testament::Util->verify_required_commands( ['git'] ) };
    ok($@);

    $ENV{PATH} = $original_path;
};

done_testing;
