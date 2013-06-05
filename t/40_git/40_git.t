#!perl

use strict;
use warnings;
use Archive::Tar;
use Cwd;
use FindBin;
use t::FileUtil;
use Testament::Git;

use Test::More;

subtest 'git' => sub {
    my $git         = Testament::Git->new();
    my $guard       = pushd(tempdir('Testament-Temp-Git-XXXX', CLEANUP => 1));
    my $cwd         = Cwd::getcwd();

    my $tar         = Archive::Tar->new();
    $tar->read(catfile( $FindBin::Bin, 'resource', 'test_repos.tar.gz' ));
    $tar->extract();
    my $repos_path  = catfile( $cwd, 'test_repos_orig' );

    $tar->read(catfile( $FindBin::Bin, 'resource', 'test_repos_ahead.tar.gz' ));
    $tar->extract();
    my $ahead_repos_path  = catfile( $cwd, 'test_repos_ahead' );

    my $branch_file = catfile( $cwd, 'test_repos', 'branch.pl' );
    my $test_contents = sub {
        my $branch = shift;
        my $expected = shift;
        $expected ||= $branch;

        $git->checkout( catfile($cwd, 'test_repos'), $branch );
        my $contents = do $branch_file;
        is_deeply $contents, { name => $expected };
    };

    subtest 'clone' => sub {
        $git->clone( $repos_path, catfile($cwd, 'test_repos') );
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

        $git->pull( catfile($cwd, 'test_repos'), $ahead_repos_path, $branch );
        $test_contents->($branch, 'master_ahead');
    };
};

done_testing;
