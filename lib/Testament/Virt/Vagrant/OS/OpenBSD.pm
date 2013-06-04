package Testament::Virt::Vagrant::OS::OpenBSD;
use strict;
use warnings;

sub argument_builder {
    my ( $class, $vagrant ) = @_;

    my $os_version = $vagrant->{os_version};
    $os_version =~ s/\.//g;
    my ( $arch, $opt ) = $vagrant->{arch} =~ /^OpenBSD\.(.*)-openbsd(?:-(.*))?/;
    my $os = lc( $vagrant->{os_text} ) . $os_version . '_' . $arch;

    return { os => $os, opt => $opt };
}

1;
