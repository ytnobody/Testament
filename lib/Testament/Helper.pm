package Testament::Helper;
use strict;
use warnings;
use utf8;
use Testament::Util;
use Testament::Virt;
use Testament::Setup;

my $MANGLE = {
    OpenBSD => sub { 'OpenBSD.'.$_[0] },
};

sub create {
    my $class = shift;
    my ($virt_manager, $os_type, $version, $arch);
    while (! $virt_manager) {
        my @managers = Testament::Virt->available_subclasses;
        $virt_manager = Testament::Util->confirm(sprintf("Choose virtual machine manager \n(%s)\n", join(', ', @managers)),'QEMU');
    }
    $Testament::OSList::VM_BACKEND = $virt_manager;
    while (! $os_type) {
        my @os_list = Testament::Setup->available_subclasses;
        $os_type = Testament::Util->confirm(sprintf("Choose OS Type \n(%s)\n", join(', ', @os_list)),'OpenBSD');
    }
    while (! $version) {
        $version = Testament::Util->confirm('Specify OS Version');
    }
    while (! $arch) {
        $arch = Testament::Util->confirm('Specify architecture for this box', 'i386-'.lc($os_type));
    }
    return ($os_type, $version, $class->mangle_arch($os_type, $arch));
};

sub mangle_arch {
    my ($class, $os_type, $arch) = @_;
    my $code = $MANGLE->{$os_type} || sub {$_[0]};
    $code->($arch);
}

1;
