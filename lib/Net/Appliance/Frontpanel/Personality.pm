package Net::Appliance::Frontpanel::Personality;
use Moose::Role;

extends 'MooseX::Object::Pluggable';

sub apply_personality {
    my ($self, $pkg, $ns)  = @_;

    my $ns_backup = $self->_plugin_ns;
    $self->_plugin_ns($ns) if $ns;
    $self->apply_plugin($pkg);
    $self->_plugin_ns($ns_backup) if $ns;

    return $self;
}   

no Moose::Role;
1;
__END__
