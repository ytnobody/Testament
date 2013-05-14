package Testament::Virt;
use strict;
use warnings;
use Class::Load qw[load_class is_class_loaded];
use Class::Accessor::Lite (
    new => 1,
    rw => [qw[ subclass arch cdrom hda ]],
);

sub boot {
    my $self = shift;
    my $subclass = $self->load_subclass;
    $subclass->boot($self);
}

sub create_image {
    my ($self, $path, $size) = @_;
    $size ||= '4G';
    my $subclass = $self->load_subclass;
    $subclass->create_image($path, $size);
}

sub load_subclass {
    my $self = shift;
    my $subclass = ref($self). '::'. do{$self->subclass || 'QEMU'};
    load_class($subclass) unless is_class_loaded($subclass);
    return $subclass;
}

1;
