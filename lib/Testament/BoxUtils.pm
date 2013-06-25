package Testament::BoxUtils;
use strict;
use warnings;
use File::Spec;
use Testament::OSList;

sub box_identity {
    my $class = shift;
    if (scalar(grep {defined($_)} @_) >= 3) {
        return join('__', @_[0..2]);
    }
    else {
        return $_[0];
    }
}

sub parse_box_identity {
    my ($class, $str) = @_;
    if ($str =~ /^[0-9]+$/) {
        $str = Testament::OSList->box_by_key($str);
    }
    my ($os_text, $os_version, $arch) = split('__', $str, 3);
    return ($os_text, $os_version, $arch);
}

sub vmdir {
    my ($class, $identify_str) = @_;
    File::Spec->rel2abs(File::Spec->catdir($Testament::OSList::VMDIR, $identify_str));
}

sub running_boxes {
    my $class = shift;
    grep {$_->{cmd} =~ /^Testament::Virt / }
    map {
        my $str = $_;
        $str =~ s/^\s+//;
        my ($pid, $tty, $stat, $time, $cmd) = split(/\s+/, $str, 5);
        $cmd =~ s/\n//;
        +{
            pid  => $pid,
            tty  => $tty,
            stat => $stat,
            time => $time,
            cmd  => $cmd,
        };
    } `ps ax | grep 'Testament::Virt'`;
}

sub is_box_running {
    my ($class, $id) = @_;
    grep {$_->{cmd} =~ /$id/} $class->running_boxes;
}

1;
