package Net::Appliance::Frontpanel::Personality;
use Moose::Role;

with 'MooseX::Object::Pluggable';

sub apply_personality {
    my ($self, $pkg, $ns)  = @_;

    my $ns_backup = $self->_plugin_ns;
    $self->_plugin_ns($ns) if $ns;
    $self->meta->make_mutable;
    $self->load_plugin($pkg);
    $self->meta->make_immutable;
    $self->_plugin_ns($ns_backup) if $ns;

    return $self;
}   

no Moose::Role;
1;
__END__
