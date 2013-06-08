package Testament::OSList;
use strict;
use warnings;
use File::Spec;
use File::Basename 'dirname';
use Data::Dumper;

our $CONF_FILE    = $ENV{TESTAMENT_CONF_FILE}    || File::Spec->catfile($ENV{HOME}, qw(.testament oslist.pl));
our $WORKDIR      = $ENV{TESTAMENT_WORKDIR}      || dirname($CONF_FILE);
our $VMDIR        = $ENV{TESTAMENT_VMDIR}        || File::Spec->catdir($WORKDIR,'vm');
our $VM_BACKEND   = $ENV{TESTAMENT_VM_BACKEND};
our $CONF;

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
    $CONF ||= do $CONF_FILE;
    return $CONF;
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

sub boxes {
    my $class = shift;
    return sort keys %{$class->load};
}

sub box_by_key {
    my ($class, $key) = @_;
    return unless $key > 0;
    my @boxes = $class->boxes;
    return $boxes[$key - 1];
}

1;
__DATA__
+{};
