package Net::Appliance::Frontpanel::Component::Image::Base;
use Moose::Role;

has image => (
    is => 'rw',
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

