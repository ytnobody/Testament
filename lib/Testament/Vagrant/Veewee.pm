package Testament::Vagrant::Veewee;
use strict;
use warnings;
use File::Spec;
use Testament::Git;
use Testament::Config;
use Testament::Util;

use constant VEEWEE_REPO         => 'git://github.com/jedi4ever/veewee.git';
use constant BUNDLE_DIR          => '.bundle/gems';
use constant VEEWEE_BASE_COMMAND => 'bundle exec veewee vbox ';

sub new {
    my ($class, $os) = @_;

    _verify_required_commands();

    my $branch     = 'master';
    my $veewee_dir = File::Spec->catfile( $Testament::Config::WORKDIR, 'veewee' );
    Testament::Git::clone( VEEWEE_REPO, $veewee_dir );
    Testament::Git::checkout( $veewee_dir, $branch );
    Testament::Git::pull( $veewee_dir, $branch );

    my $bundle_install = sub {
        my $guard = Testament::Util->will_be_right_back($veewee_dir);
        system('bundle install --path=' . BUNDLE_DIR);
    };
    $bundle_install->();

    bless {
        veewee_dir => $veewee_dir,
        os         => $os,
    }, $class;
}

sub box_create {
    my ($self) = @_;

    $self->box_define();
    $self->box_build();
}

sub box_define {
    my ($self) = @_;

    my $os             = $self->{os};
    my $veewee_dir     = $self->{veewee_dir};
    my $guard          = Testament::Util->will_be_right_back($veewee_dir);
    my $define_command = sprintf( "define %s %s --workdir=%s", $os, $os, $veewee_dir );
    system( VEEWEE_BASE_COMMAND . $define_command );

    # TODO Configure User/Password HERE!
}

sub box_build {
    my ($self) = @_;

    my $os            = $self->{os};
    my $veewee_dir    = $self->{veewee_dir};
    my $guard         = Testament::Util->will_be_right_back($veewee_dir);
    my $build_command = sprintf( "build %s --workdir=%s", $os, $veewee_dir );

    # 'echo "yes"' is needed to automatically build.
    system( 'echo "yes" | ' . VEEWEE_BASE_COMMAND . $build_command );
}

sub _verify_required_commands {
    my @required_commands = ( 'git', 'bundle' );

    foreach my $required_command (@required_commands) {
        my $which_command = sprintf( "which %s", $required_command );
        my $err = system("$which_command >/dev/null 2>&1");
        if ($err) {
            die "[Error] Please install `$required_command`.";
        }
    }
}
1;
