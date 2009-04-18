package Net::Appliance::Frontpanel::Component::Port;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';

has spec => (
    is => 'ro',
    isa => 'HashRef[Any]',
    required => 1,
);

sub BUILD {
    my ($self, $params) = @_;

    my $status = ($self->spec->{dummy} ? 'empty' : 'up'); # FIXME
    my $file = $self->config->port_db->{ $self->spec->{type} }->{ $status };
    return unless $file;

    $self->image->read(file => $self->config->image_loc($file));
    # FIXME
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
