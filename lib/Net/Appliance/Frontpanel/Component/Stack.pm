package Net::Appliance::Frontpanel::Component::Stack;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';
use Net::Appliance::Frontpanel::Component::Module;
use HTML::Entities 'encode_entities';

has ip => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has ports_data => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_ports_data {
    my $self = shift;
    my $ports = $self->config->device_ports($self->ip);
    
    foreach my $name (keys %$ports) {
        my $p = $ports->{$name};

        $p->{ip} = $self->ip; # XXX hack
        $p->{vlan} = 'Trunking'
            if $self->config->port_is_trunking($self->ip, $name);
        $p->{remote_name} = $self->config->device_name($p->{remote_ip});

        # make all port data html safe
        $p = { map {$_ => (encode_entities($p->{$_}) || '')} keys %$p };

        $ports->{$name} = $p;
    }

    return $ports;
}

has stack_spec => (
    is => 'ro',
    isa => 'ArrayRef[HashRef]',
    auto_deref => 1,
    lazy_build => 1,
);

sub _build_stack_spec {
    my $self = shift;
    return $self->config->load_spec($self->ip);
}

sub BUILD {
    my ($self, $params) = @_;

    # process each of the chassis making up this stack
    foreach my $device ($self->stack_spec) {
        my $current_height = ($self->image->getheight || 0);

        my $chassis = Net::Appliance::Frontpanel::Component::Module->new({
            config => $self->config,
            spec => { %$device, ports_data => $self->ports_data, ip => $self->ip },
        });
        
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
