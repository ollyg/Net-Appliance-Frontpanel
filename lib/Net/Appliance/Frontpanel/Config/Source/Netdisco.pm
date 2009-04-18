package Net::Appliance::Frontpanel::Config::Source::Netdisco;
use Moose::Role;

with 'Net::Appliance::Frontpanel::Helper::DBI';

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

# return ports spec for a device
sub device_ports {
    my $ports = (shift)->dbh->selectall_arrayref(
        'SELECT * FROM device_port WHERE ip = ?',
        { Slice => {} },
        shift
    );

    return { map {$_->{port} => $_} @$ports };
}

no Moose::Role;
1;
__END__
