package Net::Appliance::Frontpanel::Component::Module;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';
use Net::Appliance::Frontpanel::Component::Port;

has spec => (
    is => 'ro',
    isa => 'HashRef[Any]',
    required => 1,
);

sub BUILD {
    my ($self, $params) = @_;

    $self->image->read(file => $self->config->image_loc($self->spec->{image}));

    foreach my $item (@{$self->spec->{modules}}) {
        my $module = Net::Appliance::Frontpanel::Component::Module->new({
            config => $self->config,
            spec => { %$item, ports_data => $self->spec->{ports_data}, ip => $self->spec->{ip} },
        });

        # rotate imagemap and image
        if (my $rotate = $item->{rotate} % 360) {
            $module->rotate_map_by($rotate);
            $module->image( $module->image->rotate(right => $rotate) );
        }

        # transpose and append imagemap
        $module->transpose_map(x => $item->{x}, y => $item->{y});
        $self->imagemap( $self->imagemap . $module->imagemap );

        # transpose and copy image
        $self->paste_into_self(
            child => $module->image,
            x     => $item->{x},
            y     => $item->{y},
        );
    }

    foreach my $item (@{$self->spec->{ports}}) {
        my $port = Net::Appliance::Frontpanel::Component::Port->new({
            config => $self->config,
            spec => { %$item, ports_data => $self->spec->{ports_data}, ip => $self->spec->{ip} },
        });

        # rotate imagemap and image
        if (my $rotate = $item->{rotate} % 360) {
            $port->rotate_map_by($rotate);
            $port->image( $port->image->rotate(right => $rotate) );
        }

        # transpose and append imagemap
        $port->transpose_map(x => $item->{x}, y => $item->{y});
        $self->imagemap( $self->imagemap . $port->imagemap );

        # transpose and copy image
        $self->paste_into_self(
            child => $port->image,
            x     => $item->{x},
            y     => $item->{y},
        );
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
