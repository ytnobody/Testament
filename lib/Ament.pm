package Ament;
use 5.008005;
use strict;
use warnings;
use Ament::Setup;
use Ament::Config;
use Ament::Util;

our $VERSION = "0.01";
my $config = Ament::Config->load;

sub up {
    my ($class, $os) = @_;
    $class->setup($os) unless $config->{$os};
    die 'missing configuration for '.$os unless $config->{$os};
    my @options = @{$config->{$os}};
    Ament::Util->qemu(@options);
}

sub setup {
    my ($class, $os) = @_;
    my @options = Ament::Setup->setup($os) or die 'could not setup '.$os;
    $config->{$os} = \@options;
    Ament::Config->save($config);
    return 1;
}

1;
__END__

=encoding utf-8

=head1 NAME

Ament - A testing environment builder tool

=head1 SYNOPSIS

    $ ament Your::Module --perl 5.14.2 --os openbsd-5.2-i386

=head1 DESCRIPTION

Ament is a testing environment builder tool.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>E<gt>

=cut

