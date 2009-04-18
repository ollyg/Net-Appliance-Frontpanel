package Net::Appliance::Frontpanel::Chassis;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';

has ip => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has spec => (
    is => 'ro',
    isa => 'ArrayRef[HashRef]',
    auto_deref => 1,
    lazy_build => 1,
);

sub _build_spec {
    my $self = shift;
    return $self->config->load_spec($self->ip);
}

sub transpose_and_paste {
    my $self = shift;
    my $params = {@_};

    my $text = $self->transpose_map(
        text => $params->{child}->{imagemap},
        x    => $params->{x},
        y    => $params->{y},
    );
    $self->imagemap( $self->imagemap .= $text );

    $self->paste_into_self(
        child  => $params->{child}->{image},
        x      => $params->{x},
        y      => $params->{y},
    );

    return $self;
}

sub BUILD {
    my ($self, $params) = @_;

    foreach my $device ($self->spec) {
        my $module = $self->make_module($device);
        $self->transpose_and_paste(
            child => $module,
            y     => ($self->image->getheight || 0),
        );
    }
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
