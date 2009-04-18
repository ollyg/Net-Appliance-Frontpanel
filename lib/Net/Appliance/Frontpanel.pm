package Net::Appliance::Frontpanel;
use Moose;

use Net::Appliance::Frontpanel::Config;

has 'config' => (
    is => 'rw',
    isa => 'Net::Appliance::Frontpanel::Config',
);

sub BUILD {
    my ($self, $params) = @_;
    $self->config(
        Net::Appliance::Frontpanel::Config->new($params));
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
