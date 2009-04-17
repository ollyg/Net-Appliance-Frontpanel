package Net::Appliance::Frontpanel::Personality;
use Moose::Role;

use Class::MOP ();
use Carp qw(croak);

sub apply_personality {
    my ($self, $ns, $pkg)  = @_;
    $ns ||= 'Plugin';

    # namespace with :: is assumed not to be relative
    my $parent = ($ns =~ m/::/ ? '' :
        (blessed $self) . '::');

    my $role = "${parent}${ns}::${pkg}";
    eval { Class::MOP::load_class($role) };
    croak "Failed to load role: ${role} $@\n" if $@;
    $role->meta->apply($self);
}   

no Moose::Role;
1;
__END__
