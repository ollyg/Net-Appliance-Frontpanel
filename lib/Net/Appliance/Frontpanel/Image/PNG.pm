package Net::Appliance::Frontpanel::Image::PNG;
use Moose::Role;

extends 'Net::Appliance::Frontpanel::Image';
use Imager;

sub _build_image {
    my $self = shift;
    return Imager->new();
}

no Moose::Role;
1;
__END__
