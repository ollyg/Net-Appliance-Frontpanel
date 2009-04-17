package Net::Appliance::Frontpanel;
use Moose;

with qw(
    Net::Appliance::Frontpanel::ConfigStash
    Net::Appliance::Frontpanel::Personality
);

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
