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

sub load_or_make_image {
    my $self = shift;
    my $file = $self->spec->{image};
    my $disk_file = $self->config->image_loc($file);

    if (-e $disk_file && -r _ && -f _) {
        $self->logger->debug("... loading image [$disk_file]");
        $self->image->read( file => $disk_file );
    }
    else {
        $self->logger->debug("... faking image for [$file]");

        # load cache if we can
        my $cache = $self->config->image_db->{$file};

        # set size (fail safe to 1x1 if there's no cache for this img)
        $self->image->img_set(
            xsize => $cache->{w} || 1,
            ysize => $cache->{h} || 1,
            channels => 4,
        );

        # fill
        $self->image->box(color => $cache->{border})
            if exists $cache->{border};
        $self->image->flood_fill(
            x => 5, y => 5,
            %{$cache->{flood}},
        ) if exists $cache->{flood};
    }
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
