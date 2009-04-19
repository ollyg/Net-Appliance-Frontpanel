package Net::Appliance::Frontpanel::Component::Output::Imager;
use Moose::Role;

use List::Util qw(max);
use Imager;

has image => (
    is => 'rw',
    isa => 'Object',
    lazy_build => 1,
);

sub _build_image {
    my $self = shift;
    return Imager->new;
}

sub paste_into_self {
    my $self = shift;
    return $self->paste_into(@_, parent => $self->image);
}

sub paste_into {
    my $self = shift;
    my $params = {@_};

    my ($parent, $child, $x, $y)
        = @{$params}{qw(parent child x y)};
    $x ||= 0; $y ||= 0;

    my ($cw, $ch) = ($child->getwidth  || 0, $child->getheight  || 0);
    my ($pw, $ph) = ($parent->getwidth || 0, $parent->getheight || 0);

    my $newwidth  = max ($pw, ($x + $cw));
    my $newheight = max ($ph, ($y + $ch));

    my $copy = $parent->copy;
    $parent->img_set(xsize => $newwidth, ysize => $newheight, channels => 4); 
    $parent->paste(src => $copy) if $pw > 1;
    $parent->rubthrough(src => $child->convert(preset => 'addalpha'), tx => $x, ty => $y);

    return $self
}

no Moose::Role;
1;
__END__
