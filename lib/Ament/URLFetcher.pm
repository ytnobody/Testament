package Ament::URLFetcher;
use strict;
use warnings;
use LWP::UserAgent;
use Log::Minimal;

our $VERSION = 0.01;
our $AGENT ||= LWP::UserAgent->new(
    agent => __PACKAGE__.'/'.$VERSION,
    timeout => 86400*7,
);

sub get {
    my ($class, $url) = @_;
    infof('fetching %s', $url);
    my $res = $AGENT->get($url);
    unless ( $res->is_success ) {
        critf('failed to fetching : remote server said %s', $res->message);
        die;
    }
    return $res->content;
}

sub wget {
    my ($class, $url, $saveto) = @_;
    if( my $code = system("wget $url --output-document=$saveto") ) {
        critf('failed to fetching : exit code = %s', $code);
        die;
    }
}

1;
