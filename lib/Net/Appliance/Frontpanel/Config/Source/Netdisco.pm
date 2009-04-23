package Net::Appliance::Frontpanel::Config::Source::Netdisco;
use Moose::Role;

with 'Net::Appliance::Frontpanel::Helper::DBI';
use URI::Escape qw(uri_escape);

+has 'configfile' => (default => '/etc/netdisco/netdisco.conf');

sub _build_dbi_connect_args {
    my $self = shift;
    return [
        $self->stash->{db_Pg},
        $self->stash->{db_Pg_user},
        $self->stash->{db_Pg_pw},
        (eval '{'.$self->stash->{db_Pg_opts}.'}') || {},
    ];
}

sub make_port_link {
    my ($self, $ip, $port) = @_;
    return 'device.html?ip='. uri_escape($ip) .'&port='. uri_escape($port);
}

# return list of devices
sub devices_list {
    (shift)->dbh->selectcol_arrayref('SELECT ip FROM device');
}

# return modules spec for a device
sub device_modules {
    (shift)->dbh->selectall_arrayref(
        'SELECT * FROM device_module WHERE ip = ? ORDER BY parent,pos,index',
        { Slice => {} },
        shift
    );
}

sub port_is_trunking {
    my ($self, $ip, $port) = @_;
    my $rv = $self->dbh->selectall_arrayref(
        'SELECT count(*) AS count FROM device_port_vlan WHERE ip = ? AND port = ? and native = false',
        { Slice => {} },
        $ip, $port,
    );
    return $rv->[0]->{count};
}

sub device_name {
    my ($self, $ip) = @_;

    my $device_ip = $self->dbh->selectall_arrayref(
        'SELECT ip FROM device_ip WHERE alias = ?',
        { Slice => {} },
        $ip,
    )->[0]->{ip};

    my $device_name = $self->dbh->selectall_arrayref(
        'SELECT dns FROM device WHERE ip = ?',
        { Slice => {} },
        $device_ip,
    )->[0]->{dns} || $device_ip;

    return $device_name;
}

# return ports spec for a device
sub device_ports {
    my ($self, $ip) = @_;
    my $ports = $self->dbh->selectall_arrayref(
        'SELECT * FROM device_port WHERE ip = ?',
        { Slice => {} },
        $ip
    );
    return { map {$_->{port} => $_} @$ports };
}

no Moose::Role;
1;
__END__
