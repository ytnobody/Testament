#!perl

use strict;
use warnings;
use utf8;
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
    close $fh;

    my $guard = setup_mock_vmdir($current_dir);

    subtest 'not specify subname' => sub {
        $virt->backup();
        my @files = grep { $_ ne 'hda.img' } glob "*";
        my $file = shift @files;
        like $file, qr/\Abackup_\d*\.\d*.img\Z/;
    };

    subtest 'specify subname' => sub {
        my $subname = 'awesome';
        $virt->backup($subname);
        ok -e File::Spec->catfile($current_dir, 'backup_awesome.img');
    };
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
