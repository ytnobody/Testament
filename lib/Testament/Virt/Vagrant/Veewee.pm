package Testament::Virt::Vagrant::Veewee;
use strict;
use warnings;
use File::Spec;
use Testament::Git;
use Testament::OSList;
use Testament::Util;

use constant VEEWEE_REPO         => 'git://github.com/jedi4ever/veewee.git';
use constant BUNDLE_DIR          => '.bundle/gems';
use constant VEEWEE_BASE_COMMAND => 'bundle exec veewee vbox ';

sub new {
    my ($class, $os) = @_;

    Testament::Util->verify_required_commands( ['bundle'] );

    my $branch     = 'master';
    my $veewee_dir = File::Spec->catfile( $Testament::OSList::WORKDIR, 'veewee' );
    my $git        = Testament::Git->new();
    $git->clone( VEEWEE_REPO, $veewee_dir );
    $git->checkout( $veewee_dir, $branch );
    $git->pull( $veewee_dir, 'origin', $branch );

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

sub create_box {
    my ($self) = @_;

    $self->define_box();
    $self->build_box();
}

sub define_box {
    my ($self) = @_;

    my $os             = $self->{os};
    my $veewee_dir     = $self->{veewee_dir};
    my $guard          = Testament::Util->will_be_right_back($veewee_dir);
    my $define_command = sprintf( "define %s %s --workdir=%s", $os, $os, $veewee_dir );
    system( VEEWEE_BASE_COMMAND . $define_command );

    # TODO Configure User/Password HERE!
}

sub build_box {
    my ($self) = @_;

    my $os            = $self->{os};
    my $veewee_dir    = $self->{veewee_dir};
    my $guard         = Testament::Util->will_be_right_back($veewee_dir);
    my $build_command = sprintf( "build %s --workdir=%s", $os, $veewee_dir );

    # 'echo "yes"' is needed to automatically build.
    system( 'echo "yes" | ' . VEEWEE_BASE_COMMAND . $build_command );
}
1;
