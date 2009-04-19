package Net::Appliance::Frontpanel::Config::File;
use Moose::Role;

use Config::Any;
use Carp qw(croak);

has 'configfile' => (
    is => 'ro',
    isa => 'Str',
    predicate => 'has_configfile',
);

has 'stash' => (
    is => 'ro',
    isa => 'HashRef[Any]',
    lazy_build => 1,
);

sub _build_stash {
    my $self = shift;
    $self->has_configfile
        or croak "configfile is a required parameter";

    my $stash = eval{ Config::Any->load_files({
        files => [$self->configfile],
        use_ext => 0,
        flatten_to_hash => 1,
    })->{$self->configfile} };
    croak "failed to load config [".$self->configfile."]\n"
        if !defined $stash or $@;

    return $stash;
}

no Moose::Role;
1;
__END__


