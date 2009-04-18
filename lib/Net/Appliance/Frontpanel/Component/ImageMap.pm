package Net::Appliance::Frontpanel::Component::ImageMap;
use Moose::Role;

has imagemap => (
    is => 'rw',
    isa => 'Str',
    default => sub { '' },
);

sub transform_map {
    my ($self, $process, $x, $y) = @_;

    $x ||= ($self->image->getwidth  || 0);
    $y ||= ($self->image->getheight || 0);
    my $text = $self->imagemap;

    $text =~ s{ coords="(\d+),(\d+),(\d+),(\d+)" }{$process}eeg;
    $self->imagemap($text);
}

sub rotate_map_90 {
    my $self = shift;
    $self->transform_map(q{' coords="'. (join ',', -$2+$x,$1,-$4+$y,$3) .'" '});
}

sub rotate_map_180 {
    my $self = shift;
    $self->transform_map(q{' coords="'. (join ',', -$1+$x,-$2+$y,-$3+$x,-$4+$y) .'" '});
}

sub rotate_map_270 {
    my $self = shift;
    $self->transform_map(q{' coords="'. (join ',', $2,-$1+$x,$4,-$3+$x) .'" '});
}

sub transpose_map {
    my $self = shift;
    $self->transform_map(q{' coords="'. (join ',', $1+$x,$2+$y,$3+$x,$4+$y) .'" '}, @_);
}

no Moose::Role;
1;
__END__

