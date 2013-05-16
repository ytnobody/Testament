package Testament::Setup;
use strict;
use warnings;
use Testament::Util;
use Testament::URLFetcher;
use Testament::FastestMirror;
use Class::Accessor::Lite (
    new => 0,
    ro => [
        qw[os_text os_version arch],          # required
        qw[vmdir identity submodule mirrors], # non-required
    ],
);

sub new {
    my ($class, %params) = @_;
    for my $key (qw/os_text os_version arch/) {
        die "not allowed empty value for $key" unless $params{$key};
    }
    $params{identity}  = Testament::Util->box_identity(@params{qw/os_text os_version arch/});
    $params{vmdir}     = Testament::Util->vmdir($params{identity});
    $params{submodule} = $class.'::'.$params{os_text};

    require File::Spec->catfile(split('::', $params{submodule}. '.pm'));

    $params{mirrors} = [ _fetch_mirrors($params{submodule}->mirror_list_url) ];
    bless {%params}, $class; 
}

sub do_setup {
    my $self = shift;
    Testament::Util->mkdir($self->vmdir);
    return $self->submodule->install( $self );
}

sub mirror {
    my $self = shift;
    return Testament::FastestMirror->pickup(@{$self->mirrors});
}

sub _fetch_mirrors {
    my $mirrors_list_url = shift;
    my $res = Testament::URLFetcher->get($mirrors_list_url);
    ( my @mirrors ) = $res =~ /href\=\"(ftp:\/\/.+?)\"/g;
    return @mirrors;
}

1;
