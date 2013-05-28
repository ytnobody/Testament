package Testament::Virt::QEMU;
use strict;
use warnings;
use Net::EmptyPort 'empty_port';
use File::Which 'which';
use Log::Minimal;
use Class::Accessor::Lite (
    new => 1,
    ro => [qw[virt]],
    rw => [qw[handler]],
);

sub boot {
    my ($self, %opts) = @_; 

    my $boot_opt = $opts{boot_opt} || 'set tty com0';
    my $boot_wait = $opts{boot_wait};
    my $virt = $self->virt;
    my $arch = $virt->arch;
    $arch =~ s/amd64/x86_64/;

    my $monitor_port = $self->new_port($virt->ssh_port);
    my $console_port = $self->new_port($virt->ssh_port, $monitor_port);

    my $bin = which('qemu-system-'.$arch);
    my @options = (
        '-m'       => $virt->ram,
        '-hda'     => $virt->hda,
        '-redir'   => sprintf('tcp:%d::22', $virt->ssh_port),
        '-serial'  => 'stdio',
    );
    if ( $virt->cdrom ) {
        push @options, ('-cdrom' => $virt->cdrom);
        push @options, ('-boot'  => 'once=d');
    }
    system($bin, @options);   
}

sub new_port {
    my ($self, @ignore) = @_;
    my $port;
    while (1) {
        $port = empty_port();
        return $port unless grep {$_ == $port} @ignore;
    }
}

sub create_image {
    my ($class, $path, $size) = @_;
    my $bin = which('qemu-img');
    my @options = (qw(create -f qcow2), $path, $size);
    my $cmd = sprintf('%s %s', $bin, join(' ', @options));
    `$cmd`;
}

1;

