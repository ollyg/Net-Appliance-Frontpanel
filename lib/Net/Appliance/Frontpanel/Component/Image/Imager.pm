package Net::Appliance::Frontpanel::Image::PNG;
use Moose::Role;

with 'Net::Appliance::Frontpanel::Image';
use Imager;

sub _build_image {
    my $self = shift;
    return Imager->new();
}

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

no Moose::Role;
1;
__END__
