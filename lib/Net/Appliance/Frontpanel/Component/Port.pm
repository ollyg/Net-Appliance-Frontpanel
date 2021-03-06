package Net::Appliance::Frontpanel::Component::Port;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';
use HTML::Entities 'encode_entities';

has spec => (
    is => 'ro',
    isa => 'HashRef[Any]',
    required => 1,
);

sub port_link_start {
    my ($self, $ip, $port) = (shift, shift, shift);
    my $target = $self->config->make_port_link($ip, $port);
    return sprintf qq{
        <area href="%s" shape="rect" coords="0,0,%s,%s" alt="%s" }, $target, @_;
}

sub port_link_end {
    my $self = shift;
    return sprintf q{
        /> }, @_;
}

sub port_overlib_start {
    my $self = shift;
    return sprintf q{
        onmouseover="return overlib('
            <table width=300 cellspacing=0 cellpadding=3 border=0>
                <colgroup><col width=50><col width=*></colgroup>
                    <tr class=match-%s><td align=right>Descr:<td align=left>&nbsp;%s</td></tr>
                    <tr class=match-%s><td align=right>VLAN:<td align=left>&nbsp;%s</td></tr>
                    <tr class=match-%s><td align=right>Speed:<td align=left>&nbsp;%s</td></tr>
                    <tr class=match-%s><td align=right>Duplex:<td align=left>&nbsp;%s/%s</td></tr> }, @_;
}

sub port_overlib_end {
    my $self = shift;
    return sprintf q{
            </table>',
            DELAY, 250,
            CAPTION, '%s',
            CAPTIONSIZE, '12pt',
            CAPCOLOR, '#f5deb3',
            BGCOLOR, '#191970',
        );"
        onmouseout="return nd();" }, @_;
}

sub port_remote_name {
    my $self = shift;
    return sprintf q{
                    <tr class=match-%s><td align=right>Neighbour:<td align=left>&nbsp;%s</td></tr> }, @_;
}

sub port_remote_port {
    my $self = shift;
    return sprintf q{
                    <tr class=match-%s><td align=right>Nbr Port:<td align=left>&nbsp;%s</td></tr> }, @_;
}

sub make_imagemap_text {
    my $self = shift;
    my $port = $self->spec->{ports_data}->{$self->spec->{name}}
        or return ''; # no info to display

    my $html_port = encode_entities($self->spec->{name});
    my $width  = $self->image->getwidth  || 0;
    my $height = $self->image->getheight || 0;
    my $odd = 0; # row striping

    my $text = $self->port_link_start(
        $self->spec->{ip}, $self->spec->{name}, $width, $height, $html_port);

    if (defined($self->config->stash->{fp_overlib})
        and $self->config->stash->{fp_overlib} eq 'true') {
        $text .= $self->port_overlib_start(
            (++$odd % 2), $port->{name},
            (++$odd % 2), $port->{vlan},
            (++$odd % 2), $port->{speed},
            (++$odd % 2), $port->{duplex}, $port->{duplex_admin},
        );

        if ($port->{remote_ip}) {
            $text .= $self->port_remote_name(
                (++$odd % 2), $port->{remote_name});

            if ($port->{remote_port}) {
                $text .= $self->port_remote_port(
                    (++$odd % 2), $port->{remote_port});
            }
        }
        $text .= $self->port_overlib_end($port->{port});
    }
    $text .= $self->port_link_end;
    $self->imagemap($text);
}

sub BUILD {
    my ($self, $params) = @_;
    $self->logger->notice('    processing port ['. $self->spec->{name} .']');

    if ($self->spec->{dummy} or
        exists $self->spec->{ports_data}->{$self->spec->{name}}) {

        my $status = ($self->spec->{dummy} ? 'empty' :
            $self->spec->{ports_data}->{$self->spec->{name}}->{up});

        $self->spec->{image} =
            $self->config->port_db->{ $self->spec->{type} }->{ $status };

        $self->load_or_make_image;
        $self->make_imagemap_text;
    }
    else {
        $self->logger->error('        skipping rendering, no data from Source');
        $self->imagemap("\n        <!-- port [". encode_entities($self->spec->{name})
            ."] not provided by Source, skipping -->");
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
