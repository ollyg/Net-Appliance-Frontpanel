package Net::Appliance::Frontpanel::ImageMap;
use Moose::Role;

has imagemap => (
    is => 'rw',
    isa => 'Str',
    default => sub { '' },
);

sub rotate_map_90 {
    my ($self, $text) = @_;

    my $text =~ s{ coords="(\d+),(\d+),(\d+),(\d+)" }
                 {' coords="'. (join ',', -$2+$height,$1,-$4+$height,$3) .'" '}eg;
    return $text;
}

sub rotate_map_180 {
    my ($self, $text) = @_;

    my $text =~ s{ coords="(\d+),(\d+),(\d+),(\d+)" }
                 {' coords="'. (join ',', -$1+$width,-$2+$height,-$3+$width,-$4+$height) .'" '}eg;
    return $text;
}

sub rotate_map_270 {
    my ($self, $text) = @_;

    my $text =~ s{ coords="(\d+),(\d+),(\d+),(\d+)" }
                 {' coords="'. (join ',', $2,-$1+$width,$4,-$3+$width) .'" '}eg;
    return $text;
}

sub transpose_map {
    my $self = shift;
    my $params = {@_};

    my $x = $params->{x} || 0;
    my $y = $params->{y} || 0;
    my $text = $params->{text};

    $text =~ s{ coords="(\d+),(\d+),(\d+),(\d+)" }
              {' coords="'. (join ',', $1+$x,$2+$y,$3+$x,$4+$y) .'" '}eg;
    return $text;
}

no Moose::Role;
1;
__END__

