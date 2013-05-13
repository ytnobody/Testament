package Ament::Config;
use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';
use Data::Dumper;

our $CONF_FILE    = $ENV{AMENT_CONF_FILE}    || File::Spec->catfile($ENV{HOME}, qw(.ament oslist.pl));
our $WORKDIR      = $ENV{AMENT_WORKDIR}      || dirname($CONF_FILE);
our $VMDIR        = $ENV{AMENT_VMDIR}        || File::Spec->catdir($WORKDIR,'vm');

__PACKAGE__->create unless -e $CONF_FILE;

sub create {
    my $class = shift;
    $class->create_workdir;
    $class->create_vmdir;
    $class->create_conf_file;
}

sub create_workdir {
    unless (-e $WORKDIR) {
        mkdir $WORKDIR or die 'could not create directory '.$WORKDIR;
    }
}

sub create_vmdir {
    unless (-e $VMDIR) {
        mkdir $VMDIR or die 'could not create directory '.$VMDIR;
    }
}

sub create_conf_file {
    unless (-e $CONF_FILE) {
        my @data = <DATA>;
        open my $fh, '>', $CONF_FILE or die 'could not create file '.$CONF_FILE;
        print $fh join('',@data);
        close $fh;
    }
}

sub load {
    do $CONF_FILE;
}

sub save {
    my ($class, $var) = @_;
    unless ($var) {
        warn 'do not save without config value';
        return;
    }
    open my $fh, '>', $CONF_FILE or die 'could not write to '.$CONF_FILE;
    local $Data::Dumper::Terse = 1;
    print $fh Dumper($var);
    close $fh;
}

1;
__DATA__
+{};
