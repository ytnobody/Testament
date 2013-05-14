package Testament::FastestMirror;
use strict;
use warnings;
use utf8;
use JSON;
use URI;
use Testament::URLFetcher;

our $IPCHECKER_URL = 'http://ipsefact.ytnobody.net/api/json';

sub pickup {
    my ($class, @urllist) = @_;
    my $ipinfo = JSON->new->utf8->decode(Testament::URLFetcher->get($IPCHECKER_URL));
    my $my_country = uc($ipinfo->{country});
    my @near_url = grep {uc($_->host) =~ /\.$my_country$/} map {URI->new($_)} @urllist;
    return $near_url[int(rand($#near_url + 1))];
}

1;
