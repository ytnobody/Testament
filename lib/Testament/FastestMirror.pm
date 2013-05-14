package Testament::FastestMirror;
use strict;
use warnings;
use utf8;
use JSON;
use URI;
use Testament::URLFetcher;

our @IPCHECKER_URL_LIST = (
    'http://ipsefact.ytnobody.net/api/json',
);

sub ip_checker_url {
    my $class = shift;
    return $IPCHECKER_URL_LIST[int(rand($#IPCHECKER_URL_LIST + 1))];
}

sub pickup {
    my ($class, @urllist) = @_;
    my $ipinfo = JSON->new->utf8->decode(Testament::URLFetcher->get($class->ip_checker_url));
    my $my_country = uc($ipinfo->{country});
    my @near_url = grep {uc($_->host) =~ /\.$my_country$/} map {URI->new($_)} @urllist;
    return $near_url[int(rand($#near_url + 1))];
}

1;
