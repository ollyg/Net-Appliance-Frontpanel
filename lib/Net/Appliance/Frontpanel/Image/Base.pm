package Net::Appliance::Frontpanel::Image;
use Moose::Role;

use List::MoreUtils qw(max);

has image => (
    is => 'ro',
    isa => 'Object',
    lazy_build => 1,
);

sub paste_into_self {
    my $self = shift;
    return $self->paste_into(@_, parent => $self->image);
}

no Moose::Role;
1;
__END__

