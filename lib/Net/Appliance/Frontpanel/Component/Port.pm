package Net::Appliance::Frontpanel::Component::Port;
use Moose;

extends 'Net::Appliance::Frontpanel::Component';
use HTML::Entities 'encode_entities';

has spec => (
    is => 'ro',
    isa => 'HashRef[Any]',
    required => 1,
);

sub make_imagemap_text {
    my $self = shift;
    my $port = $self->config->device_port->{$self->ip, $self->spec->{name}};

    # now also set image map text
    my $html_port = encode_entities($self->spec->{name});
    my $width  = $self->image->getwidth  || 0;
    my $height = $self->image->getheight || 0;
    my $odd = 0; # row striping

    # get trunking status of port - no easier way sadly
    $port->{vlan} = 'Trunking' if $self->config->port_is_trunking;
    $port->{remote_name} = $self->config->device_name($port->{remote_ip});

    # make all port data html safe
    $port = { map {($_ => encode_entities($port->{$_}))} keys %$port };

    # FIXME Netdisco specific URL
    my $text .= '<area href="device.html?ip='. encode_entities($self->ip) .'&amp;port='. $html_port
        .'" shape="rect" coords="0,0,'. $width .','. $height .'" alt="'. $html_port .'"';

    if (defined($self->config->stash->{fp_overlib}) and $self->config->stash->{fp_overlib} eq 'true') {
        $text .= 'onmouseover="return overlib(\'<table width=300 cellspacing=0 cellpadding=3 border=0><colgroup><col width=50><col width=*></colgroup>'
                    .'<tr class=match-'. (++$odd % 2) .'><td align=right>Descr:<td align=left>&nbsp;'. $port->{name} .'</td></tr>'
                    .'<tr class=match-'. (++$odd % 2) .'><td align=right>VLAN:<td align=left>&nbsp;'. $port->{vlan} .'</td></tr>'
                    .'<tr class=match-'. (++$odd % 2) .'><td align=right>Speed:<td align=left>&nbsp;'. $port->{speed} .'</td></tr>'
                    .'<tr class=match-'. (++$odd % 2) .'><td align=right>Duplex:<td align=left>&nbsp;'.
                        $port->{duplex} .'/'. $port->{duplex_admin} .'</td></tr>';

        if ($port->{remote_ip}) {
            $text .= '<tr class=match-'. (++$odd % 2) .'><td align=right>Neighbour:<td align=left>&nbsp;'. $port->{remote_name} .'</td></tr>';
            if ($port->{remote_port}) {
                $text .= '<tr class=match-'. (++$odd % 2) .'><td align=right>Nbr Port:<td align=left>&nbsp;'. $port->{remote_port} .'</td></tr>';
            }
        }   
        $text .= '</table>\',DELAY,250,CAPTION,\''. $port->{port} .'\',CAPTIONSIZE,\'12pt\',CAPCOLOR,\'#f5deb3\',BGCOLOR,\'#191970\');"'
                    .'onmouseout="return nd();"';
    }   
    $text .= ">\n";

    $self->imagemap($text);
}

sub BUILD {
    my ($self, $params) = @_;

    my $status = ($self->spec->{dummy} ? 'empty' : 'up'); # FIXME
    my $file = $self->config->port_db->{ $self->spec->{type} }->{ $status };
    return unless $file;

    $self->image->read(file => $self->config->image_loc($file));
    $self->make_imagemap_text;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__
