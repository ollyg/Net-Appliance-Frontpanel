package Net::Appliance::Frontpanel;
use Moose;

use Net::Appliance::Frontpanel::Config;
use Net::Appliance::Frontpanel::Component::Device;

has 'config' => (
    is => 'rw',
    isa => 'Net::Appliance::Frontpanel::Config',
);

has 'ip' => (
    is => 'rw',
    isa => 'Str',
    required => 0,
);

sub BUILD {
    my ($self, $params) = @_;
    $self->config(
        Net::Appliance::Frontpanel::Config->new($params));
}

sub _mk_device {
    my $self = shift;
    return Net::Appliance::Frontpanel::Component::Device->new(
        config => $self->config, ip => $self->ip, @_);
}

sub image_map {
    my $self = shift;
    return $self->_mk_device(@_)->imagemap;
}

sub image_data {
    my $self = shift;
    return $self->_mk_device(@_)->image_data;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
