package Net::Appliance::Frontpanel::Component;
use Moose;

with qw(
    Net::Appliance::Frontpanel::Personality
    Net::Appliance::Frontpanel::Component::ImageMap
    Net::Appliance::Frontpanel::Component::Transforms
);

has 'config' => (
    is => 'ro',
    isa => 'Net::Appliance::Frontpanel::Config',
    required => 1,
    weak_ref => 1,
);

sub BUILD {
    my ($self, $params) = @_;

    # load up the image type personality
    my $img_type = $params->{config}->stash->{img_type} || 'Imager';
    $self->apply_personality($img_type, 'Image');
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
