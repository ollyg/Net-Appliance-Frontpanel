package Net::Appliance::Frontpanel::Component::Module;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';

has spec => (
    is => 'ro',
    isa => 'HashRef[Any]',
    required => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
