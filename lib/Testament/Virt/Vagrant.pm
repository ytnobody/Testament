package Testament::Virt::Vagrant;
use strict;
use warnings;
use Testament::Util;
use Testament::Vagrant::Veewee;

sub new {
    my ($class, $os) = @_;

    Testament::Util->verify_required_commands( [ 'vagrant' ] );

    bless {
        os => $os,
    }, $class;
}

sub install_box {
    my ($self) = @_;
    my $os = $self->{os};

    my $veewee = Testament::Vagrant::Veewee->new($os);
    $veewee->create_box();

    my $guard = Testament::Util->will_be_right_back( $veewee->{veewee_dir} );

    # export box as Virtual Box style.
    mkdir('boxes');
    my $target = sprintf('boxes/%s.box', $os);
    unless ( -e $target ) {
        system(sprintf( 'vagrant package --base %s --output %s', $os, $target ));
    }

    # add box
    system(sprintf( 'vagrant box add %s %s', $os, $target ));
}
1;
