package Net::Appliance::Frontpanel::Component::Stack;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';
use Net::Appliance::Frontpanel::Component::Module;

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

    # process each of the chassis making up this stack
    foreach my $device ($self->spec) {
        my $current_height = ($self->image->getheight || 0);

        my $chassis = Net::Appliance::Frontpanel::Component::Module->new({
            config => $self->config, spec => $device });
        
        # shift imagemap down, and copy
        $chassis->transpose_map(y => $current_height);
        $self->imagemap( $self->imagemap . $chassis->imagemap );

        # paste chassis
        $self->paste_into_self(
            child => $chassis->image,
            y     => $current_height,
        );
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
