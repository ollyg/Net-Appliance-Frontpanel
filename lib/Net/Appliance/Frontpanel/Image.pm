package Net::Appliance::Frontpanel::Image;
use Moose::Role;

has image => (
    is => 'ro',
    isa => 'Object',
    lazy_build => 1,
);

no Moose::Role;
1;
__END__

