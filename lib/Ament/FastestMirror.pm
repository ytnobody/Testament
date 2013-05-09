package Ament::FastestMirror;
use strict;
use warnings;
use utf8;
use JSON;
use URI;
use Ament::URLFetcher;
use IP::Country::Medium;

our $IPCHECKER_URL = 'http://ipsefact.ytnobody.net/api/json';
my $ipc = IP::Country::Medium->new;

sub pickup {
    my ($class, @urllist) = @_;
    my $ipinfo = JSON->new->utf8->decode(Ament::URLFetcher->get($IPCHECKER_URL));
    my $my_country = $ipinfo->{country};
    my @near_url = grep {$ipc->inet_atocc($_->host) eq $my_country} map {URI->new($_)} @urllist;
    return $near_url[int(rand($#near_url + 1))];
}

1;
