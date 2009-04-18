package Net::Appliance::Frontpanel::Chassis;
use Moose;

with qw(
    Net::Appliance::Frontpanel::Personality
    Net::Appliance::Frontpanel::ImageMap
);

has source => (
    is => 'ro',
    isa => 'Net::Appliance::Frontpanel::Source',
    required => 1,
);

has cache => (
    is => 'ro',
    isa => 'Net::Appliance::Frontpanel::Cache',
    required => 1,
);

has spec => (
    is => 'ro',
    isa => 'ArrayRef[Any]',
    auto_deref => 1,
    lazy_build => 1,
);

sub _build_spec {
    my $self = shift;
    return $self->cache->load_spec($self->ip);
}

has ip => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

sub BUILD {
    my ($self, $params) = @_;

    # load up the image type personality
    $params->{img_type} ||= 'PNG';
    $self->apply_personality(
        'Net::Appliance::Frontpanel::Image',
        $params->{img_type}
    );

    foreach my $device ($self->spec) {
        my $module = $self->make_module($device);
        $self->transpose_and_copy(
            child => $module,
            y     => ($self->image->getheight || 0),
        );
    }
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
