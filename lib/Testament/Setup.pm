package Testament::Setup;
use strict;
use warnings;
use File::Spec;
use Testament::Config;
use Testament::Util;

sub setup {
    my ( $class, $os_text, $os_version, $arch ) = @_;
    my $vmdir = File::Spec->rel2abs(File::Spec->catdir($Testament::Config::VMDIR, $os_text));
    Testament::Util->mkdir($vmdir);
    if ( $os_text && $os_version && $arch ) {
        my $submod = $class->submodule($os_text);
        return $submod->install( $os_version, $arch, $vmdir );
    }
    die 'invalid os identifier ' . $os_text;
}

sub submodule {
    my ($class, $subclass) = @_;
    my $submod = $class.'::'.$subclass;
    my $submod_path = File::Spec->catfile(split('::', $submod .'.pm'));
    require $submod_path;
    $submod;
}

1;
