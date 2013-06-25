package Testament::Virt::QEMU;
use strict;
use warnings;
use Net::EmptyPort 'empty_port';
use File::Which 'which';
use Log::Minimal;
use File::Spec;
use Class::Accessor::Lite (
    new => 1,
    ro => [qw[virt]],
    rw => [qw[handler]],
);
use Time::HiRes;
use File::Copy;

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
        '-serial'  => 'null',
        '-monitor' => 'null',
    );
    if ( $virt->cdrom ) {
        push @options, ('-cdrom' => $virt->cdrom);
        push @options, ('-boot'  => 'once=d');
    }
    return ($bin, @options);   
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

sub backup {
    my ($self, $subname) = @_;
    $subname ||= Time::HiRes::time();
    my $hda = File::Spec->catfile( $self->virt->vmdir, 'hda.img' );
    my $dst = File::Spec->catfile( $self->virt->vmdir, "backup_$subname.img" );
    infof('copying %s to %s', $hda, $dst);
    copy($hda, $dst);
}

sub backup_list {
    my ($self) = @_;
    my $glob = File::Spec->catfile( $self->virt->vmdir, 'backup_*.img' );
    (my $pattern = $glob) =~ s/\//\\\//g;
    $pattern =~ s/\*\./(.+)./;
    print join("", (map {my($name) = $_ =~ m/$pattern/; $name."\n"} glob($glob)));
}

sub purge_backup {
    my ($self, $subname) = @_;
    unless ($subname) {
        critf('must specify backup name');
        die;
    }
    my $dst = File::Spec->catfile( $self->virt->vmdir, "backup_$subname.img" );
    infof('purge backup image %s', $dst);
    unlink($dst);
}

sub restore {
    my ($self, $subname) = @_;
    $subname ||= Time::HiRes::time();
    my $backup = File::Spec->catfile( $self->virt->vmdir, "backup_$subname.img" );
    my $hda = File::Spec->catfile( $self->virt->vmdir, 'hda.img' );
    infof('copying %s to %s', $backup, $hda);
    copy($backup, $hda);
}

1;

