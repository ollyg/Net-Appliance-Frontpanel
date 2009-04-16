package Net::Appliance::Frontpanel::Helper::DBI;
use Moose::Role;

use DBI;
requires '_build_dbi_connect_args';

has 'connect_args' => (
    is  => 'ro',
    isa => 'ArrayRef[Any]',
    lazy_build => 1,
    auto_deref => 1,
    builder => '_build_dbi_connect_args',
);

has 'dbh' => (
    is  => 'ro',
    default => sub { DBI->connect((shift)->connect_args) },
    lazy => 1,
);

sub DEMOLISH {
    (shift)->dbh->disconnect;
};

no Moose::Role;
1;
__END__
