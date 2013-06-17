package Testament::Virt::Vagrant::OS;
use strict;
use warnings;
use File::Spec;

sub argument_builder {
    my ($class, $vagrant) = @_;

    my $submodule = $class . '__' . $vagrant->{os_text};
    eval { require File::Spec->catfile( split( '__', $submodule . '.pm' ) ) };
    if ($@) {
        die "[ERROR] Unsupported OS: $vagrant->{os_text}";
    }

    return $submodule->argument_builder($vagrant);
}

1;
