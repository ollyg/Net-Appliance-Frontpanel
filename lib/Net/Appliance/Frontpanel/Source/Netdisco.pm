package Net::Appliance::Frontpanel::Source::Netdisco;
use Moose::Role;

with 'Net::Appliance::Frontpanel::Helper::DBI';

sub _build_dbi_connect_args {
    my $self = shift;
    return [
        $self->config->{db_Pg},
        $self->config->{db_Pg_user},
        $self->config->{db_Pg_pw},
        (eval '{'.$self->config->{db_Pg_opts}.'}') || {},
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

no Moose::Role;
1;
__END__
