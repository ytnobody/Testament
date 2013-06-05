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

    my $extract_archive = sub {
        my ($repos) = @_;
        my $archive = catfile( $FindBin::Bin, 'resource', "$repos.tar.gz" );
        my $tar = Archive::Tar->new();
        $tar->read($archive);
        $tar->extract();
        my $repos_path = catfile( $cwd, $repos );
        return $repos_path;
    };
    my $repos_path        = $extract_archive->('test_repos_orig');
    my $ahead_repos_path  = $extract_archive->('test_repos_ahead');
    my $cloned_repos_path = catfile( $cwd, 'test_repos' );

    my $branch_file       = catfile( $cwd, 'test_repos', 'branch.pl' );
    my $test_contents = sub {
        my ($branch, $expected) = @_;
        $expected ||= $branch;

        $git->checkout( catfile( $cwd, 'test_repos' ), $branch );
        my $contents = do $branch_file;
        is_deeply $contents, { name => $expected };
    };

    subtest 'clone' => sub {
        $git->clone( $repos_path, $cloned_repos_path );
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

        $git->pull( $cloned_repos_path, $ahead_repos_path, $branch );
        $test_contents->($branch, 'master_ahead');
    };
};

done_testing;
