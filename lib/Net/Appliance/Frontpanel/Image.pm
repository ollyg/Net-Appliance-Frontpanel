package Net::Appliance::Frontpanel::Image;
use Moose::Role;

use List::MoreUtils qw(max);

has image => (
    is => 'ro',
    isa => 'Object',
    lazy_build => 1,
);

sub paste_into {
    my $self = shift;
    my $params = {@_};

    my ($parent, $child, $x, $y)
        = @{$params}{qw(parent, child, x, y)};

    my ($cw, $ch) = ($child->getwidth, $child->getheight);
    my ($pw, $ph) = ($parent->getwidth, $parent->getheight);

    my $newwidth  = max ($pw, ($x + $cw));
    my $newheight = max ($ph, ($y + $ch));

    my $copy = $parent->copy;
    $parent->img_set(xsize => $newwidth, ysize => $newheight, channels => 4); 
    $parent->paste(src => $copy) if $pw > 1;
    $parent->rubthrough(src => $child->convert(preset => 'addalpha'), tx => $x, ty => $y);

    return $self
}

sub paste_into_self {
    my $self = shift;
    return $self->paste_into(@_, parent => $self->image);
}

no Moose::Role;
1;
__END__

