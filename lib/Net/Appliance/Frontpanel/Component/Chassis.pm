package Net::Appliance::Frontpanel::Component::Stack;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';
use Net::Appliance::Frontpanel::Component::Chassis;

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
    return do ("/home/oliver/data/". $self->ip ."_spec.pl");
    # FIXME
    # return $self->config->load_spec($self->ip);
}

sub BUILD {
    my ($self, $params) = @_;

    # process each of the chassis modules making up this device
    foreach my $device ($self->spec) {
        my $current_height = ($self->image->getheight || 0);

        my $module = Net::Appliance::Frontpanel::Component::Chassis->new({
            config => $self->config, spec => $device });
        
        # shift imagemap down, and copy
        $module->transpose_map(y => $current_height);
        $self->imagemap( $self->imagemap . $module->imagemap );

        # paste module
        $self->paste_into_self(
            child => $module->image,
            y     => $current_height,
        );
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
