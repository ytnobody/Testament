#!perl

use strict;
use warnings;
use Cwd;
use FindBin;
use t::FileUtil;
use Testament::Git;

use Test::More;

subtest 'git' => sub {
    my $git         = Testament::Git->new();
    my $guard       = pushd(tempdir('Testament-Temp-Git-XXXX', CLEANUP => 1));
    my $cwd         = Cwd::getcwd();
    my $repos       = 'test_repos';
    my $repos_path  = catfile( $FindBin::Bin, 'resource', 'test_repos' );
    my $branch_file = catfile( $cwd, 'branch.pl' );
    my $test_contents = sub {
        my $branch = shift;
        my $expected = shift;
        $expected ||= $branch;

        $git->checkout( $cwd, $branch );
        my $contents = do $branch_file;
        is_deeply $contents, { name => $expected };
    };


    subtest 'clone' => sub {
        $git->clone( $repos_path, catfile($cwd) );
        ok (-e $branch_file);
    };

    subtest 'checkout' => sub {
        subtest 'test branch' => sub {
            $test_contents->('test_branch');
        };

        subtest 'master branch' => sub {
            $test_contents->('master');
        };
    };

    subtest 'pull' => sub {
        my $branch = 'master';
        my $ahead_repos = catfile( $FindBin::Bin, 'resource', 'test_repos_ahead' );

        $git->pull( $cwd, $ahead_repos, $branch );
        $test_contents->($branch, 'master_ahead');
    };
};

done_testing;
