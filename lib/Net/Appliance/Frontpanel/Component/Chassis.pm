package Net::Appliance::Frontpanel::Component::Module;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';

has spec => (
    is => 'ro',
    isa => 'HashRef[Any]',
    required => 1,
);

sub BUILD {
    my ($self, $params) = @_;

    $self->image->read(file => "/home/oliver/images/". $self->spec->{image});
    # FIXME

    foreach my $device (@{$self->spec->modules}) {
        my $module = Net::Appliance::Frontpanel::Component::Module->new({
            config => $self->config, spec => $device });

        # transpose imagemap and copy
        $module->transpose_map(x => $device->{x}, y => $device->{y});
        $self->imagemap( $self->imagemap . $module->imagemap );

        # rotate, transpose, paste image into self
        if (my $rotate = $module->{rotate} % 360) {
            $module->image( $module->image->rotate(right => $rotate);
        }

        $self->paste_into_self(
            child => $module->image,
            x     => $device->{x},
            y     => $device->{y},
        );
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
