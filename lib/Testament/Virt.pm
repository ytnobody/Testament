package Testament::Virt;
use strict;
use warnings;
use Class::Load qw[load_class is_class_loaded];
use Class::Accessor::Lite (
    new => 1,
    rw => [qw[ id subclass arch cdrom hda ssh_port ram ]],
);
use Net::EmptyPort 'empty_port';
use Log::Minimal;
use Proc::Simple;
use Testament::Util;

sub boot {
    my ($self, $boot_opt, $boot_wait) = @_;
    $boot_wait ||= 1;
    my $subclass = $self->load_subclass;
    $self->ssh_port(empty_port()) unless $self->ssh_port;
    unless ($self->ram) {
        my $ram = Testament::Util->confirm('Specify RAM size that allocates to this box', $ENV{TESTAMENT_VM_RAM} || 512);
        $ram =~ s/(\r|\n)//g;
        $self->ram($ram);
    }

    infof('BOOT hda:%s ram:%sMBytes ssh_port:%d', $self->hda, $self->ram, $self->ssh_port);
    $0 = sprintf( '%s [%s] %s ssh=%s ram=%s', __PACKAGE__, $self->subclass || 'QEMU', $self->id, $self->ssh_port, $self->ram );

    my $vm = $subclass->new(virt => $self);

    my $master_proc = Proc::Simple->new;
    my $slave_proc = Proc::Simple->new;
    $master_proc->redirect_output('/dev/null', undef);
    # XXX visible slave error
    # $slave_proc->redirect_output('/dev/null', '/dev/null');
    $master_proc->start(sub {
        $SIG{TERM} = $SIG{INT} = $SIG{KILL} = sub {
            $slave_proc->kill;
            exit;
        };
        $slave_proc->start( $vm->boot(boot_opt => $boot_opt, boot_wait => $boot_wait) );
        $slave_proc->wait;
    });
}

sub create_image {
    my ($self, $path, $size) = @_;
    $size ||= '20G';
    my $subclass = $self->load_subclass;
    $subclass->create_image($path, $size);
}

sub load_subclass {
    my $self = shift;
    my $subclass = ref($self). '::'. do{$self->subclass || 'QEMU'};
    load_class($subclass) unless is_class_loaded($subclass);
    return $subclass;
}

sub as_hashref {
    my $self = shift;
    return +{
        map {($_ => $self->$_)} keys %$self
    };
}

1;
