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

    # my ($port, $ip, $x, $y, $width, $height) = @_;
    my $port = $self->device_ports->{$self->spec->{name}};
    my $text = ''; 

    # now also set image map text
    my $html_port = encode_entities($self->spec->{name});a
    my $width  = $self->image->getwidth  || 0;
    my $height = $self->image->getheight || 0;
    my $odd = 0; # row striping

    $text .= '<area href="device.html?ip='. $self->ip .'&amp;port='. $html_port
        .'" shape="rect" coords="0,0,'. $width .','. $height .'" alt="'. $html_port .'"';

    # get trunking status of port - no easier way sadly
    $port->{vlan} = 'Trunking' if $self->config->port_is_trunking;
    my $remote_ip = sql_scalar('device_ip', ['ip'], {'alias' => $port->{remote_ip}});
    my $remote_name = sql_scalar('device', ['dns'], {'ip' => $remote_ip}) || $port->{remote_ip};
    $port->{name} =~ s/[''""]//g;

    if (defined($netdisco::CONFIG{fp_overlib}) && $netdisco::CONFIG{fp_overlib} == 'true') {
        $text .= 'onmouseover="return overlib(\'<table width=300 cellspacing=0 cellpadding=3 border=0><colgroup><col width=50><col width=*></colgroup>'
                    .'<tr class=match-'. (++$odd % 2) .'><td align=right>Descr:<td align=left>&nbsp;'. $m->interp->apply_escapes($port->{name}, 'h') .'</td></tr>'
                    .'<tr class=match-'. (++$odd % 2) .'><td align=right>VLAN:<td align=left>&nbsp;'. $m->interp->apply_escapes($port->{vlan}, 'h') .'</td></tr>'
                    .'<tr class=match-'. (++$odd % 2) .'><td align=right>Speed:<td align=left>&nbsp;'. $m->interp->apply_escapes($port->{speed}, 'h') .'</td></tr>'
                    .'<tr class=match-'. (++$odd % 2) .'><td align=right>Duplex:<td align=left>&nbsp;'.
                        $port->{duplex} .'/'. $m->interp->apply_escapes($port->{duplex_admin}, 'h') .'</td></tr>';
        if ($port->{remote_ip}) {
            $remote_name  =~ s/[""'']//g;
            $text .= '<tr class=match-'. (++$odd % 2) .'><td align=right>Neighbour:<td align=left>&nbsp;'. $m->interp->apply_escapes($remote_name, 'h') .'</td></tr>';
            if ($port->{remote_port}) {
                $text .= '<tr class=match-'. (++$odd % 2) .'><td align=right>Nbr Port:<td align=left>&nbsp;'. $m->interp->apply_escapes($port->{remote_port}, 'h') .'</td></tr>';
            }   
        }   
        $text .= '</table>\',DELAY,250,CAPTION,\''. $m->interp->apply_escapes($port->{port}, 'h') .'\',CAPTIONSIZE,\'12pt\',CAPCOLOR,\'#f5deb3\',BGCOLOR,\'#191970\');"'
                    .'onmouseout="return nd();"';
    }   
    $text .= ">\n";

    $self->text($text);
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
