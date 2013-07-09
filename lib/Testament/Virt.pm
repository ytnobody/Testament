package Testament::Virt;
use strict;
use warnings;
use Class::Load qw[load_class is_class_loaded];
use Class::Accessor::Lite (
    new => 1,
    rw => [qw[ id subclass arch cdrom hda ssh_port ram core ]],
);
use Net::EmptyPort 'empty_port';
use Log::Minimal;
use Proc::Simple;
use Testament::Util;
use Testament::BoxUtils;
use Module::Pluggable::Object;

sub boot {
    my ($self, $boot_opt, $boot_wait) = @_;
    $boot_wait ||= 1;
    my $subclass = $self->load_subclass;
    $self->ssh_port(empty_port()) unless $self->ssh_port;
    unless ($self->ram) {
        my ($ram) = (Testament::Util->confirm(
            'Specify RAM size that allocates to this box', 
            $ENV{TESTAMENT_VM_RAM} || 512
        )) =~ m/^([0-9]+)/;
        $ram ||= $ENV{TESTAMENT_VM_RAM} || 512;
        $self->ram($ram);
    }
    unless ($self->core) {
        my ($core) = Testament::Util->confirm('Specify core numbers that allocates to this box', 1) =~ m/^([0-9]+)/;
        $core ||= 1;
        $self->core($core);
    }

    infof('BOOT hda:%s core:%s ram:%sMBytes ssh_port:%d', $self->hda, $self->core, $self->ram, $self->ssh_port);
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

sub backup {
    my ($self, $subname) = @_;
    my $subclass = $self->load_subclass;
    my $virt = $subclass->new(virt => $self);
    $virt->backup($subname);
}

sub backup_list {
    my ($self) = @_;
    my $subclass = $self->load_subclass;
    my $virt = $subclass->new(virt => $self);
    $virt->backup_list;
}

sub purge_backup {
    my ($self, $subname) = @_;
    my $subclass = $self->load_subclass;
    my $virt = $subclass->new(virt => $self);
    $virt->purge_backup($subname);
}

sub restore {
    my ($self, $subname) = @_;
    my $subclass = $self->load_subclass;
    my $virt = $subclass->new(virt => $self);
    $virt->restore($subname);
}

sub vmdir {
    my $self = shift;
    return Testament::BoxUtils->vmdir($self->id);
}

sub available_subclasses {
    my $class = shift;
    my $finder = Module::Pluggable::Object->new(search_path => $class, require => 0);
    my $manager_re = qr/^Testament::Virt::([A-Za-z_]+)$/;
    map {my($man) = $_ =~ m[$manager_re]; $man } grep {m[$manager_re]} $finder->plugins;
}

1;
