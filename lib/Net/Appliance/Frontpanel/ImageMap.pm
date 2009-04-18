package Net::Appliance::Frontpanel::ImageMap;
use Moose::Role;

has imagemap => (
    is => 'rw',
    isa => 'Str',
    default => sub { '' },
);

no Moose::Role;
1;
__END__

