#!perl

use strict;
use warnings;
use utf8;
use Capture::Tiny qw/capture/;
use File::Spec;
use Scope::Guard;
use t::FileUtil;
use Testament;
use Testament::Virt::QEMU;

use Test::More;

my $virt = Testament->load_virt( 'OpenBSD', '5.3', 'OpenBSD.i386-openbsd' );

subtest 'backup' => sub {
    my $tempdir     = pushd( tempdir( 'Testament-Temp-XXXX', CLEANUP => 1 ) );
    my $current_dir = getcwd();

    open my $fh, '>', 'hda.img';
    print $fh 'master';
    close $fh;

    my $guard = setup_mock_vmdir($current_dir);

    subtest 'not specify subname' => sub {
        $virt->backup();
        my @files = grep { $_ ne 'hda.img' } glob "*";
        my $file = shift @files;
        open $fh, '<', $file;
        is <$fh>, 'master', 'copy correctly';
        close $fh;
        like $file, qr/\Abackup_\d*\.\d*.img\Z/, 'Filename should be time stamp';
    };

    subtest 'specify subname' => sub {
        my $subname = 'awesome';
        my $cloned  = "backup_$subname.img";
        $virt->backup($subname);
        open $fh, '<', $cloned;
        is <$fh>, 'master', 'copy correctly';
        close $fh;
        ok -e File::Spec->catfile($current_dir, 'backup_awesome.img'), 'Filename should be specified string';
    };
};

subtest 'backup_list' => sub {
    my $tempdir     = pushd( tempdir( 'Testament-Temp-XXXX', CLEANUP => 1 ) );
    my $current_dir = getcwd();

    my $fh;
    open $fh, '>', 'hda.img';
    close $fh;
    open $fh, '>', 'backup_alpha.img';
    close $fh;
    open $fh, '>', 'backup_bravo.img';
    close $fh;

    my $guard = setup_mock_vmdir($current_dir);

    my ($got) = capture { $virt->backup_list() };

    is $got, <<EOS;
alpha
bravo
EOS
};

subtest 'purge_backup' => sub {
    my $tempdir     = pushd( tempdir( 'Testament-Temp-XXXX', CLEANUP => 1 ) );
    my $current_dir = getcwd();

    my $backup_img = 'backup_awesome.img';
    open my $fh, '>', $backup_img;
    close $fh;

    ok -e File::Spec->catfile($current_dir, $backup_img);

    my $guard = setup_mock_vmdir($current_dir);
    $virt->purge_backup('awesome');

    my @files = glob '*';
    is scalar @files, 0, 'Remove img file correctly';
};

subtest 'restore' => sub {
    my $tempdir     = pushd( tempdir( 'Testament-Temp-XXXX', CLEANUP => 1 ) );
    my $current_dir = getcwd();

    my $hda_img = 'hda.img';

    my $fh;
    open $fh, '>', $hda_img;
    print $fh 'master';
    close $fh;

    open $fh, '>', 'backup_awesome.img';
    print $fh 'awesome!';
    close $fh;

    open $fh, '<', $hda_img;
    is <$fh>, 'master';
    close $fh;

    my $guard = setup_mock_vmdir($current_dir);
    $virt->restore('awesome');

    open $fh, '<', $hda_img;
    is <$fh>, 'awesome!', 'restore correctly';
    close $fh;
};

done_testing;

sub setup_mock_vmdir {
    my $dir = shift;

    my $original = *Testament::Virt::vmdir{CODE};
    my $mock = sub {
        return $dir;
    };

    undef *Testament::Virt::vmdir;
    *Testament::Virt::vmdir = $mock;

    return Scope::Guard->new(
        sub {
            undef *Testament::Virt::vmdir;
            *Testament::Virt::vmdir = $original;
        }
    );
}
