package Net::Appliance::Frontpanel::Config::File;
use Moose::Role;

use Config::Any;
use Carp qw(croak);

has 'configfile' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has 'stash' => (
    is => 'ro',
    isa => 'HashRef[Any]',
    lazy_build => 1,
);

sub _build_stash {
    my $self = shift;
    my $stash = eval{ Config::Any->load_files({
        files => [$self->configfile],
        use_ext => 0,
        flatten_to_hash => 1,
    })->{$self->configfile} };
    croak "failed to load config [".$self->configfile."]\n" if $@;
    return $stash;
}

no Moose::Role;
1;
__END__


