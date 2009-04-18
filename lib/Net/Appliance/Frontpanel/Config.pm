package Net::Appliance::Frontpanel::Config;
use Moose;

with 'Net::Appliance::Frontpanel::Personality';
with 'Net::Appliance::Frontpanel::Config::File';
# with 'Net::Appliance::Frontpanel::Cache';

has 'source' => (
    is => 'ro',
    isa => 'Str',
    default => 'Netdisco',
);

sub BUILD {
    my ($self, $params) = @_;
    $self->apply_personality($self->source, 'Source');
    $self->stash; # trigger loading of the config file
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

