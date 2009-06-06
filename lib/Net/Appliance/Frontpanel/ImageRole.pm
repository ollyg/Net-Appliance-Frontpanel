package Net::Appliance::Frontpanel::ImageRole;
use Moose::Role;

use Net::Appliance::Frontpanel::Component::Device;

has 'ip' => (
    is => 'rw',
    isa => 'Str',
    required => 0,
);

sub _mk_device {
    my $self = shift;
    return Net::Appliance::Frontpanel::Component::Device->new(
        config => $self->config, ip => $self->ip);
}

sub image_map {
    my $self = shift;
    return $self->_mk_device->imagemap;
}

sub image_data {
    my $self = shift;
    return $self->_mk_device->image_data;
}

no Moose::Role;
1;
__END__
