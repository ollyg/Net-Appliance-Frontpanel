package Net::Appliance::Frontpanel::ConfigStash;
use Moose::Role;

use Config::Any;
use Carp qw(croak);

has 'config' => (
    is => 'ro',
    isa => 'HashRef[Any]',
    lazy_build => 1,
);

sub _build_config {
    my $self = shift;
    my $config = eval{ Config::Any->load_files({
        files => [$self->configfile],
        use_ext => 0,
        flatten_to_hash => 1,
    })->{$self->configfile} };
    croak "failed to load config [".$self->configfile."]\n" if $@;
    return $config;
}

no Moose::Role;
1;
__END__

