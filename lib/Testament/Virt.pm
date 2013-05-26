package Testament::Virt;
use strict;
use warnings;
use Class::Load qw[load_class is_class_loaded];
use Class::Accessor::Lite (
    new => 1,
    rw => [qw[ subclass arch cdrom hda ssh_port ram ]],
);
use Net::EmptyPort 'empty_port';
use Log::Minimal;

sub boot {
    my ($self, $boot_opt, $boot_wait) = @_;
    $boot_wait ||= 1;
    my $subclass = $self->load_subclass;
    $self->ssh_port(empty_port());
    unless ($self->ram) {
        $self->ram($ENV{TESTAMENT_VM_RAM} || 256);
    }
    infof('BOOT hda:%s ram:%sMBytes ssh_port:%d', $self->hda, $self->ram, $self->ssh_port);
    my $vm = $subclass->new(virt => $self);
    $vm->boot(boot_opt => $boot_opt, boot_wait => $boot_wait);
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
