package Net::Appliance::Frontpanel::Config::Source::Netdisco;
use Moose::Role;

with 'Net::Appliance::Frontpanel::Helper::DBI';

+has 'configfile' => (default => '/etc/netdisco/netdisco.conf');

has 'device_ports' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
)

# return ports spec for a device
sub _build_device_ports {
    my $ports = (shift)->dbh->selectall_arrayref(
        'SELECT * FROM device_port WHERE ip = ?',
        { Slice => {} },
        shift
    );

    return { map {$_->{port} => $_} @$ports };
}

sub _build_dbi_connect_args {
    my $self = shift;
    return [
        $self->stash->{db_Pg},
        $self->stash->{db_Pg_user},
        $self->stash->{db_Pg_pw},
        (eval '{'.$self->stash->{db_Pg_opts}.'}') || {},
    ];
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
    my $rv = $self->dbh->selectrow_arrayref(
        'SELECT count(*) AS count FROM device_port_vlan WHERE ip = ? AND port = ? and native = false',
        { Slice => {} },
        $ip, $port,
    );
    return $rv->{count};
}

sub get_remote_port {
    my ($self, $ip, $port) = @_;
    my $ = $self->dbh->selectrow_arrayref(
        'SELECT 

no Moose::Role;
1;
__END__
