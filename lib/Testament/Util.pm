package Testament::Util;
use strict;
use warnings;
use Cwd;
use Log::Minimal;
use File::Spec;
use Scope::Guard;
use Testament::Config;

sub mkdir {
    my ($class, $path) = @_;
    return 1 if -e $path;
    infof('mkdir %s', $path);
    unless( mkdir $path ) {
        critf('failed to mkdir %s', $path);
        die;
    }
}

sub file_slurp {
    my ($class, $path) = @_;
    my $fh;
    unless (open $fh, '<', $path) {
        critf('could not read file : %s', $path);
        return;
    }
    my $data = join('', map {$_} <$fh>);
    close $fh;
    return $data;
}

sub box_identity {
    my ($class, $os_text, $os_version, $arch) = @_;
    return join('-', $os_text, $os_version, $arch);
}

sub vmdir {
    my ($class, $identify_str) = @_;
    File::Spec->rel2abs(File::Spec->catdir($Testament::Config::VMDIR, $identify_str));
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
    grep {$_->{cmd} =~ /$id/} Testament::Util->running_boxes;
}

sub will_be_right_back {
    my ($class, $destination) = @_;

    my $cwd = getcwd();
    chdir $destination;

    return Scope::Guard->new(sub {
        chdir $cwd;
    });
}
1;
