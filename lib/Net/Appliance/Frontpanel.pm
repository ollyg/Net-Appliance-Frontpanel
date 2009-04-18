package Net::Appliance::Frontpanel;
use Moose;

use Net::Appliance::Frontpanel::Config;

has 'params' => (
    is => 'rw',
    isa => 'HashRef[Any]',
);

has 'config' => (
    is => 'ro',
    isa => 'Net::Appliance::Frontpanel::Config',
    lazy_build => 1,
);

sub _build_config {
    return Net::Appliance::Frontpanel::Config->new(
        (shift)->params,
    );
}

sub BUILD {
    my ($self, $params) = @_;
    $self->params($params);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
