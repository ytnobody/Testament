package Testament::Virt::QEMU;
use strict;
use warnings;
use File::Which 'which';
use Log::Minimal;
use Class::Accessor::Lite (
    ro => [qw[virt]],
    rw => [qw[monitor console]],
);
use Testament::Virt::QEMU::Monitor;

sub boot {
    my ($self, $boot_opt) = @_;
    @boot_opt ||= 'set tty com0';
    my $virt = $self->virt;
    my $arch = $virt->arch;
    $arch =~ s/amd64/x86_64/;
    my $bin = which('qemu-system-'.$arch);
    my @options = (
        '-m'       => $virt->ram,
        '-hda'     => $virt->hda,
        '-redir'   => sprintf('tcp:%d::22', $virt->ssh_port),
        '-serial'  => sprintf('telnet:127.0.0.1:%d', $virt->serial_port),
        '-monitor' => 'stdio',
        '-nographic',
    );
    if ( $virt->cdrom ) {
        push @options, ('-cdrom' => $virt->cdrom);
        push @options, ('-boot'  => 'd');
    }
    $self->monitor(Testament::Virt::QEMU::Monitor->new(bootcmd => join(' ', $bin, @options)));
    $self->monitor->boot($boot_opt);
}

sub create_image {
    my ($class, $path, $size) = @_;
    my $bin = which('qemu-img');
    my @options = (qw(create -f qcow2), $path, $size);
    my $cmd = sprintf('%s %s', $bin, join(' ', @options));
    `$cmd`;
}

1;

