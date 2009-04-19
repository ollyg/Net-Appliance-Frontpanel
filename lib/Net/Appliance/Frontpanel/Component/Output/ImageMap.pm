package Net::Appliance::Frontpanel::Component::Output::ImageMap;
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

sub rotate_map_by {
    my ($self, $degrees) = @_;

    my $process_for = {
        90  => q{' coords="'. (join ',', -$2+$x,$1,-$4+$y,$3) .'" '},
        180 => q{' coords="'. (join ',', -$1+$x,-$2+$y,-$3+$x,-$4+$y) .'" '},
        270 => q{' coords="'. (join ',', $2,-$1+$x,$4,-$3+$x) .'" '},
    };

    $self->transform_map( $process_for->{$degrees} );
}

sub transpose_map {
    my $self = shift;
    my $params = {@_};

    $self->transform_map(
        q{' coords="'. (join ',', $1+$x,$2+$y,$3+$x,$4+$y) .'" '},
        $params->{x} || 0, $params->{y} || 0,
    );
}

no Moose::Role;
1;
__END__

