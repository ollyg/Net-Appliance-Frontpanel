package Net::Appliance::Frontpanel::Component::Module;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';
use Net::Appliance::Frontpanel::Component::Port;

has spec => (
    is => 'ro',
    isa => 'HashRef[Any]',
    required => 1,
);

sub process_children {
    my ($self, $type) = @_;

    my $child_class_for = { modules => 'Module', ports => 'Port' };
    my $child_class = 'Net::Appliance::Frontpanel::Component::'. $child_class_for->{$type};

    foreach my $item (@{$self->spec->{$type}}) {
        my $child = $child_class->new({
            config => $self->config,
            spec => { %$item, ports_data => $self->spec->{ports_data}, ip => $self->spec->{ip} },
        });

        # rotate imagemap and image
        if (my $rotate = $item->{rotate} % 360) {
            $child->rotate_map_by($rotate);
            $child->image( $child->image->rotate(right => $rotate) );
        }

        # transpose and append imagemap
        $child->transpose_map(x => $item->{x}, y => $item->{y});
        $self->imagemap( $self->imagemap . $child->imagemap );

        # transpose and copy image
        $self->paste_into_self(
            child => $child->image,
            x     => $item->{x},
            y     => $item->{y},
        );
    }

    return $self;
}


sub BUILD {
    my ($self, $params) = @_;

    $self->load_or_make_image;
    $self->process_children('modules');
    $self->process_children('ports');
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
