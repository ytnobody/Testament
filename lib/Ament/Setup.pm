package Ament::Setup;
use strict;
use warnings;
use File::Spec;
use Ament::Config;
use Ament::Util;

sub setup {
    my ($class, $os) = @_;
    my $vmdir = File::Spec->rel2abs(File::Spec->catdir($Ament::Config::VMDIR, $os));
    Ament::Util->mkdir($vmdir);
    if (my($dist, $version, $arch) = $os =~ /^(.+)\-(.+)\-(.+)?/) {
        my $submod = $class->submodule($dist);
        return $submod->install($version, $arch, $vmdir);
    }
    die 'invalid os identifier '.$os;
}

sub submodule {
    my ($class, $subclass) = @_;
    my $submod = $class.'::'.$subclass;
    my $submod_path = File::Spec->catfile(split('::', $submod .'.pm'));
    require $submod_path;
    $submod;
}

1;
