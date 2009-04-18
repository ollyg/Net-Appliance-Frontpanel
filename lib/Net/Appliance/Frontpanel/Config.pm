package Net::Appliance::Frontpanel::Config;
use Moose;

with 'Net::Appliance::Frontpanel::Personality';
with 'Net::Appliance::Frontpanel::ConfigFile';
with 'Net::Appliance::Frontpanel::Cache';

sub BUILD {
    my ($self, $params) = @_;

    # load up the data source personality
    $params->{source} ||= 'Netdisco';
    $self->apply_personality('Source', $params->{source});
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

