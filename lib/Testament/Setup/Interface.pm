package Testament::Setup::Interface;
use strict;
use warnings;
use Carp;

sub mirrors {
    ### XXX implement mirrors method in subclass
    croak(sprintf('mirrors method is not implemented in %s', $class));

    ### implement example
    # my ($class, $setup_obj) = @_;
    # return (
    #     'http://example.com/',
    #     'ftp://example.com/'
    # );
}

sub prepare_install {
    ### XXX implement prepare_install method in subclass
    croak(sprintf('prepare_install method is not implemented in %s', $class));

    ### implement example
    # my ($class, $setup) = @_;

    ### set arch_short and arch_opt
    # ($setup->{arch_short}, $setup->{arch_opt}) = $setup->arch =~ qr[^OpenBSD^.(.+)-openbsd(?:-(.+))?]);

    ### set iso_file
    # $setup->iso_file( sprintf('install%s.iso', (($setup->os_version) =~s/\.//)) );

    ### set digest_file
    # $setup->digest_file('SHA256');

    ### specify logic that resolves full url for specific file
    # $setup->remote_url_builder(sub {
    #     my $filename = shift;
    #     return sprintf("%s/%s/%s/%s", $setup->mirror, $setup->os_version, $setup->arch_short, $filename);
    # });

    ### run install
    # $setup->install;
}

1;
