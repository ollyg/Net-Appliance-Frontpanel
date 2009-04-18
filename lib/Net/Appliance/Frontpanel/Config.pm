package Net::Appliance::Frontpanel::Config;
use Moose;

with 'Net::Appliance::Frontpanel::Personality';
with 'Net::Appliance::Frontpanel::Config::File';
# with 'Net::Appliance::Frontpanel::Cache';

sub BUILD {
    my ($self, $params) = @_;

    # load up the data source personality
    $params->{source} ||= 'Netdisco';
    $self->apply_personality($params->{source}, 'Source');
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

