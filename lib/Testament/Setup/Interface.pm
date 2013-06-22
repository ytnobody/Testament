package Testament::Setup::Interface;
use strict;
use warnings;
use Carp;

sub mirrors {
    ### XXX implement mirrors method in subclass
    my ($class, $setup) = @_;
    croak(sprintf('mirrors method is not implemented in %s', $class));

    ### implement example
    # return (
    #     'http://example.com/',
    #     'ftp://example.com/'
    # );
}

sub prepare_install {
    ### XXX implement prepare_install method in subclass
    my ($class, $setup) = @_;
    croak(sprintf('prepare_install method is not implemented in %s', $class));

    ### implement example

    ### set arch_short and arch_opt
    ### arch_short: e.g. "i386", "amd64", etc...
    ### arch_opt:   e.g. "thread-multi", "int64", etc...
    # ($setup->{arch_short}, $setup->{arch_opt}) = $setup->arch =~ qr[^OpenBSD^.(.+)-openbsd(?:-(.+))?]);

    ### set iso_file
    # $setup->iso_file( sprintf('install%s.iso', (($setup->os_version) =~s/\.//)) );

    ### set digest_file
    # $setup->digest_file('SHA256');

    ### specify logic that resolves full url for specific file
    # $setup->remote_url_builder(sub {
    #     my ($setup, $filename) = @_;
    #     return sprintf("%s/%s/%s/%s", $setup->mirror, $setup->os_version, $setup->arch_short, $filename);
    # });
}

1;
