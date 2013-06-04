package Testament::Virt::Vagrant;
use strict;
use warnings;
use Testament::Util;
use Testament::Virt::Vagrant::OS;
use Testament::Virt::Vagrant::Veewee;

sub new {
    my ( $class, %args ) = @_;

    Testament::Util->verify_required_commands( [ 'vagrant' ] );

    bless {
        os_text    => $args{os_text},
        os_version => $args{os_version},
        arch       => $args{arch},
    }, $class;
}

sub install_box {
    my ($self) = @_;

    my $box_info = Testament::Virt::Vagrant::OS->argument_builder($self);

    my $veewee = Testament::Virt::Vagrant::Veewee->new( $box_info->{os} );
    $veewee->create_box();

    my $guard = Testament::Util->will_be_right_back( $veewee->{veewee_dir} );

    # export box as Virtual Box style.
    mkdir('boxes');
    my $target = sprintf( 'boxes/%s.box', $box_info->{os} );
    unless ( -e $target ) {
        system(
            sprintf(
                'vagrant package --base %s --output %s',
                $box_info->{os}, $target
            )
        );
    }

    # add box
    system( sprintf( 'vagrant box add %s %s', $box_info->{os}, $target ) );
}
1;
