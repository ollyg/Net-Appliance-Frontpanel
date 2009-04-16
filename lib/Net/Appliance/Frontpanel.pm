package Net::Appliance::Frontpanel;
use Moose;

use Config::Any;
use Class::MOP ();
use Carp qw(croak);

has 'configfile' => (
    is => 'ro',
    isa => 'Str',
    default => '/etc/netdisco/netdisco.conf', # XXX
    required => 1,
);

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
};

sub BUILD {
    my ($self, $params) = @_;

    # load up the data source personality
    $params->{source} ||= 'Netdisco';
    my $role = __PACKAGE__ . "::Source::$params->{source}";
    eval { Class::MOP::load_class($role) };
    croak "Failed to load role: ${role} $@\n" if $@;
    $role->meta->apply($self);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
