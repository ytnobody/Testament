package Testament;
use 5.008005;
use strict;
use warnings;
use Testament::Setup;
use Testament::Config;
use Testament::Virt;
use Testament::Util;

our $VERSION = "0.01";
my $config = Testament::Config->load;

sub setup {
    my ( $class, $os_text, $os_version, $arch ) = @_;
    my $virt = Testament::Setup->setup( $os_text, $os_version, $arch );
    die sprintf('could not setup %s', $os_text) unless $virt;
    my $identify_str = Testament::Util->box_identity($os_text, $os_version, $arch);
    $config->{$identify_str} = $virt->as_hashref;
    Testament::Config->save($config);
    return 1;
}

sub boot {
    my ( $class, $os_text, $os_version, $arch ) = @_;
    my $identify_str = Testament::Util->box_identity($os_text, $os_version, $arch);
    my $box_conf = $config->{$identify_str};
    my $virt = Testament::Virt->new(%$box_conf);
    $virt->boot();
}

1;
__END__

=encoding utf-8

=head1 NAME

Testament - TEST AssignMENT

=head1 SYNOPSIS

To show failure report for your module,

    $ testament failures Your::Module
    0.05 perl-5.12.1 OpenBSD 5.1 OpenBSD.amd64-openbsd-thread-multi
    0.05 perl-5.10.0 OpenBSD 5.1 OpenBSD.i386-openbsd
    0.05 perl-5.14.4 FreeBSD 9.1-release amd64-freebsd-thread-multi

And, you can create virtual environment

    $ testament create OpenBSD 5.1 OpenBSD.i386-openbsd

=head1 DESCRIPTION

Testament is a testing environment builder tool.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>E<gt>

=cut

