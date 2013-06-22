package Testament::Setup;
use strict;
use warnings;
use File::Basename qw(basename);
use Log::Minimal;
use Digest::SHA2;
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
        qw[iso_file digest_file_name remote_url_builder arch_short arch_opt ],
    ],
);

sub new {
    my ( $class, %params ) = @_;
    for my $key (qw/os_text os_version arch/) {
        die "not allowed empty value for $key" unless $params{$key};
    }
    $params{identity} =
      Testament::Util->box_identity( @params{qw/os_text os_version arch/} );
    $params{vmdir}     = Testament::Util->vmdir( $params{identity} );
    $params{submodule} = $class . '::' . $params{os_text};

    require File::Spec->catfile( split( '::', $params{submodule} . '.pm' ) );

    $params{mirrors} =
      [ _fetch_mirrors( $params{submodule}->mirror_list_url ) ];
    bless {%params}, $class;
}

sub do_setup {
    my $self = shift;
    Testament::Util->mkdir( $self->vmdir );
    return $self->submodule->install($self);
}

sub install {
    my ( $self, $arch_matcher, $iso_file_builder, $digest_file_name,
        $remote_url_builder, $boot_opt, $boot_wait ) = @_;

    $boot_opt ||= '';
    $boot_wait ||= 5;

    # arch_short: e.g. "i386", "amd64", etc...
    # arch_opt:   e.g. "thread-multi", "int64", etc...
    my ( $arch_short, $arch_opt ) = $self->arch =~ $arch_matcher;
    $self->arch_short($arch_short);
    $self->arch_opt($arch_opt);
    $self->digest_file_name($digest_file_name);
    $self->remote_url_builder($remote_url_builder);
    $self->iso_file( &$iso_file_builder($self) );
    my $virt = Testament::Virt->new( id => $self->identity, arch => $self->arch_short );
    my $install_image = $self->_fetch_install_image();
    if ($install_image) {
        my $hda = File::Spec->catfile( $self->vmdir, 'hda.img' );
        $virt->create_image($hda);
        $virt->hda($hda);
        $virt->cdrom($install_image);
        $virt->boot($boot_opt, $boot_wait);
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

    my $digest_file =
      File::Spec->catfile( $self->vmdir, $self->digest_file_name );
    my $url = &{ $self->remote_url_builder }( $self, $self->digest_file_name );
    Testament::URLFetcher->wget( $url, $digest_file ) unless -e $digest_file;
    my $install_image = $self->_get_downloaded_img_path();

    return unless $install_image;
    return $self->_validate_img_file_by_SHA2( $install_image, $digest_file );
}

sub _validate_img_file_by_SHA2 {
    my ( $self, $install_image, $digest_file ) = @_;

    my ( $sha_type, $filename, $sha2 );
    for my $line ( split /\n/, Testament::Util->file_slurp($digest_file) ) {
        chomp $line;
        $sha_type = $filename = $sha2 = undef;
        ( $sha_type, $filename, $sha2 ) = $line =~ /^SHA(\d\d\d) \((.+)\) = ([0-9a-f]+)$/;
        unless ($filename) {
            # NOTE For Linux (Ubuntu). I think that this way is a little evil...
            ( $sha2, $filename ) = $line =~ /([0-9a-f]+)\s*\*(.+)/;
            ($sha_type) = basename($digest_file) =~ /(\d\d\d)/;
        }
        last if $filename eq $self->iso_file;
    }
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
1;
