package Testament::Setup::GNU_Linux;
use strict;
use warnings;
use parent 'Testament::Setup::Interface';
use Testament::URLFetcher;

# This module supports for centos6.

use constant RELEASE => 6.4;

sub mirrors {
    my ($clss, $setup) = @_;
    ($setup->{arch_short}, $setup->{arch_opt}) = $setup->arch =~ qr/^(.*)-linux(?:-(.*))?/;
    my $mirror_list = sprintf('http://mirrorlist.centos.org/?release=%s&arch=%s&repo=os', RELEASE, $setup->arch_short);
    my $res   = Testament::URLFetcher->get($mirror_list);
    return (map {my $str = $_; $str =~ s/\n//g; $str} split(/\n/, $res));
}

sub prepare_install {
    my ( $class, $setup ) = @_;

    $setup->digest_file_name('sha256sum.txt');
    $setup->digest_sha_type('256');
    $setup->digest_matcher(sub {
        my ($line, $results) = @_;
        ($results->{sha2}, $results->{filename}) = $line =~ /^([0-9a-f]+)\s+(.+)/;
        return $results;
    });

    $setup->iso_file(sprintf('CentOS-%s-%s-minimal.iso', RELEASE, $setup->arch_short));

    $setup->remote_url_builder(sub {
        my ($setup, $filename) = @_;
        (my $mirror = $setup->mirror) =~ s/\/os\//\/isos\//;
        sprintf("%s/%s", $mirror, $filename);
    });
}
1;
