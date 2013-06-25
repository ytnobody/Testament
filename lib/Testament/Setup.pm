package Testament::Setup;
use strict;
use warnings;
use File::Basename qw(basename);
use Log::Minimal;
use Digest::SHA2;
use Testament::BoxUtils;
use Testament::Util;
use Testament::URLFetcher;
use Testament::FastestMirror;
use Testament::Virt;
use Class::Accessor::Lite (
    new => 0,
    ro  => [
        qw[os_text os_version arch],             # required
        qw[vmdir identity submodule mirrors],    # non-required
    ],
    rw => [
        qw[iso_file digest_file_name remote_url_builder arch_short arch_opt digest_sha_type digest_matcher],
    ],
);
use Module::Pluggable::Object;

sub new {
    my ( $class, %params ) = @_;
    for my $key (qw/os_text os_version arch/) {
        die "not allowed empty value for $key" unless $params{$key};
    }
    $params{identity} =
      Testament::BoxUtils->box_identity( @params{qw/os_text os_version arch/} );
    $params{vmdir}     = Testament::BoxUtils->vmdir( $params{identity} );
    $params{submodule} = $class . '::' . $params{os_text};

    require File::Spec->catfile( split( '::', $params{submodule} . '.pm' ) );

    my $self = bless {%params}, $class;
    $self->{mirrors} = [ $params{submodule}->mirrors($self) ];
    return $self;
}

sub do_setup {
    my $self = shift;
    Testament::Util->mkdir( $self->vmdir );
    $self->submodule->prepare_install($self);
    $self->install;
}

sub install {
    my $self = shift;

    my $virt = Testament::Virt->new( id => $self->identity, arch => $self->arch_short );
    my $install_image = $self->_fetch_install_image();
    if ($install_image) {
        my $hda = File::Spec->catfile( $self->vmdir, 'hda.img' );
        $virt->create_image($hda);
        $virt->hda($hda);
        $virt->cdrom($install_image);
        $virt->boot();
        $virt->{cdrom} = undef;
        return $virt;
    }
    else {
        critf('install image file is illegal');
        die;
    }
}

sub mirror {
    my ( $self, $country_matcher, $mirror_regexp ) = @_;

    my @mirrors =
      $mirror_regexp
      ? grep { $_ =~ $mirror_regexp } @{ $self->mirrors }
      : @{ $self->mirrors };
    return Testament::FastestMirror->pickup( \@mirrors, $country_matcher );
}

sub _fetch_install_image {
    my ($self) = @_;

    my $install_image = File::Spec->catfile( $self->vmdir, $self->iso_file );
    unless ( $self->_validate_install_image() ) {
        my $url = &{ $self->remote_url_builder }( $self, $self->iso_file );
        Testament::URLFetcher->wget( $url, $install_image );
        return unless $self->_validate_install_image();
    }
    return $install_image;
}

sub _validate_install_image {
    my ($self) = @_;

    my $digest_file = File::Spec->catfile( $self->vmdir, $self->digest_file_name );
    my $url = &{ $self->remote_url_builder }( $self, $self->digest_file_name );
    Testament::URLFetcher->wget( $url, $digest_file ) unless -e $digest_file;
    my $install_image = $self->_get_downloaded_img_path();

    return unless $install_image;
    return $self->_validate_img_file_by_SHA2( $install_image, $digest_file );
}

sub _validate_img_file_by_SHA2 {
    my ( $self, $install_image, $digest_file ) = @_;

    my $results;
    my $digest_matcher = $self->digest_matcher || sub {
        my ($line, $results) = @_;
        ($results->{sha_type}, $results->{filename}, $results->{sha2}) = $line =~ qr/^SHA(\d\d\d) \((.+)\) = ([0-9a-f]+)$/;
        return $results;
    };

    for my $line ( split /\n/, Testament::Util->file_slurp($digest_file) ) {
        chomp $line;
        $results = $digest_matcher->($line, $results);
        last if $results->{filename} eq $self->iso_file;
    }
    my $sha_type = $self->digest_sha_type || $results->{sha_type};
    my $sha2     = $results->{sha2};
    my $filename = $results->{filename};
    unless ( $sha2 eq $self->_calculate_SHA2_of_file($install_image, $sha_type) ) {
        critf( 'sha%s digest is not match : wants = %s', $sha_type, $sha2 );
        return;
    }
    return $install_image;
}

sub _calculate_SHA2_of_file {
    my ( $self, $path, $sha_type ) = @_;

    infof( 'checking sha%s digest for file %s', $sha_type, $path );
    my $fh;
    unless ( open $fh, '<', $path ) {
        critf( 'could not open file %s', $path );
    }
    my $sha2obj = Digest::SHA2->new($sha_type);
    $sha2obj->addfile($fh);
    my $sha2 = $sha2obj->hexdigest;
    infof( 'sha%s = %s', $sha_type, $sha2 );
    close $fh;

    return $sha2;
}

sub _get_downloaded_img_path {
    my ($self) = @_;
    my $install_image = File::Spec->catfile( $self->vmdir, $self->iso_file );
    unless ( -e $install_image ) {
        warnf( 'install image file %s is not found', $install_image );
        return;
    }

    return $install_image;
}

sub available_subclasses {
    my $class = shift;
    my $finder = Module::Pluggable::Object->new(search_path => $class, require => 0);
    my $os_re = qr/^Testament::Setup::([A-Za-z_]+)$/;
    grep {$_ ne 'Interface'} map {my($man) = $_ =~ m[$os_re]; $man } grep {m[$os_re]} $finder->plugins;
}

1;
