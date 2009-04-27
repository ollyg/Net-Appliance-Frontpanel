package Net::Appliance::Frontpanel::Component;
use Moose;

with 'Net::Appliance::Frontpanel::Helper::Personality';
with 'Net::Appliance::Frontpanel::Helper::Logger';
with 'Net::Appliance::Frontpanel::Component::Output::ImageMap';

has 'config' => (
    is => 'ro',
    isa => 'Net::Appliance::Frontpanel::Config',
    required => 1,
    weak_ref => 1,
);

has 'imager' => (
    is => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub{ (shift)->config->stash->{fp_imager} || 'Imager' },
);

sub BUILDARGS {
    my $class = shift;
    my $params = $class->SUPER::BUILDARGS(@_);

    if (!exists $params->{config} and exists $params->{configfile}) {
        Class::MOP::load_class('Net::Appliance::Frontpanel::Config');
        return {
            %$params,
            config => Net::Appliance::Frontpanel::Config->new($params),
        };
    }
    return $params;
}

sub BUILD {
    my ($self, $params) = @_;

    # load up the image type personality
    $self->apply_personality($self->imager, 'Output');
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
