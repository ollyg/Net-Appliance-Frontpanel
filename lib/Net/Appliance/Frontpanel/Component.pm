package Net::Appliance::Frontpanel::Component;
use Moose;

with 'Net::Appliance::Frontpanel::Helper::Personality';
with 'Net::Appliance::Frontpanel::Component::Output::ImageMap';

has 'config' => (
    is => 'ro',
    isa => 'Net::Appliance::Frontpanel::Config',
    required => 1,
    weak_ref => 1,
);

has 'image_type' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub{ (shift)->config->stash->{fp_image_type} || 'Imager' },
);

sub BUILD {
    my ($self, $params) = @_;

    # load up the image type personality
    $self->apply_personality($self->image_type, 'Output');
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
