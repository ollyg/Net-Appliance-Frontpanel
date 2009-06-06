package Net::Appliance::Frontpanel::Component::Device;
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

        $p->{vlan} = 'Trunking'
            if $self->config->port_is_trunking($self->ip, $name);
        $p->{remote_name} = $self->config->device_name($p->{remote_ip});

        # make all port data html safe
        $p = { map {$_ => (encode_entities($p->{$_}) || '')} keys %$p };

        $ports->{$name} = $p;
    }

    return $ports;
}

has device_spec => (
    is => 'ro',
    isa => 'ArrayRef[HashRef]',
    auto_deref => 1,
    lazy_build => 1,
);

sub _build_device_spec {
    my $self = shift;
    return $self->config->load_spec($self->ip);
}

sub BUILD {
    my ($self, $params) = @_;
    $self->pre_flight_check_ok or return;
    $self->logger->notice('building frontpanel for device ['. $self->ip .']');

    # process each of the chassis making up this device
    foreach my $device ($self->device_spec) {
        my $current_height = ($self->image->getheight || 0);

        my $chassis = Net::Appliance::Frontpanel::Component::Module->new({
            config => $self->config,
            spec => { %$device, ports_data => $self->ports_data, ip => $self->ip },
            debug => $self->debug,
        });
        
        # shift imagemap down, and copy
        $chassis->transpose_map(y => $current_height) if $current_height > 1;
        $self->imagemap( $self->imagemap . $chassis->imagemap );

        # paste chassis
        $self->paste_into_self(
            child => $chassis->image,
            y     => $current_height,
        );
    }
}

sub bail_out_message {
    my ($self, $message) = @_;
    $self->logger->error($message);
    $self->imagemap("\n        <!-- $message -->\n");
}

sub pre_flight_check_ok {
    my $self = shift;

    if (! eval{ $self->config->port_db }) {
        $self->bail_out_message('failed to load the port types database, '.
            'cannot render any frontpanels');
        return 0;
    }

    if (! eval{ $self->config->image_db }) {
        $self->bail_out_message('failed to load the image formatting database, '.
            'cannot render any frontpanels');
        return 0;
    }

    if (! eval{ $self->device_spec }) {
        $self->bail_out_message('device ['.
            encode_entities($self->ip) .'] has no spec to load, skipping');
        return 0;
    }

    return 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
