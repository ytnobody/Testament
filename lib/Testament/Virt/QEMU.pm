package Testament::Virt::QEMU;
use strict;
use warnings;
use File::Which 'which';
use Log::Minimal;

sub boot {
    my ($class, $virt) = @_;
    my $bin = which('qemu-system-'.$virt->arch);
    my %options = (
        '-hda'   => $virt->hda,
        '-redir' => sprintf('tcp:%d::22', $virt->ssh_port),
    );
    if ( $virt->cdrom ) {
        $options{'-cdrom'} = $virt->cdrom;
        $options{'-boot'}  = 'd';
    }
    my $cmd = join(' ', $bin, map {($_ => $options{$_})} keys %options);
    `$cmd`;
}

sub create_image {
    my ($class, $path, $size) = @_;
    my $bin = which('qemu-img');
    my @options = (qw(create -f qcow2), $path, $size);
    my $cmd = sprintf('%s %s', $bin, join(' ', @options));
    `$cmd`;
}

1;

