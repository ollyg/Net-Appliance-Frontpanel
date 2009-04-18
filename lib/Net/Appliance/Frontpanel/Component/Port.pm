package Net::Appliance::Frontpanel::Component::Port;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';

has ports => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    auto_deref => 1,
    lazy_build => 1,
);

sub _build_ports {
    my $self = shift;
    return do ("/home/oliver/data/port_db.pl");
    # FIXME
    # return $self->config->load_spec($self->ip);
}

has spec => (
    is => 'ro',
    isa => 'HashRef[Any]',
    required => 1,
);

sub BUILD {
    my ($self, $params) = @_;

    my $status = ($self->spec->{dummy} ? 'empty' : 'up'); # FIXME
    my $file = $self->ports->{ $self->spec->{type} }->{ $status };
    return unless $file;

    $self->image->read(file => "/home/oliver/images/". $file);
    # FIXME
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
