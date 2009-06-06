package Net::Appliance::Frontpanel::CacheBuilderRole;
use Moose::Role;

with 'Net::Appliance::Frontpanel::Helper::Logger';
use XML::LibXML;
use XML::LibXSLT;
use File::Temp;

has 'xslt_parser' => (
    is => 'ro',
    isa => 'XML::LibXSLT',
    default => sub { XML::LibXSLT->new() },
    lazy => 1,
);

has 'xml_parser' => (
    is => 'ro',
    isa => 'XML::LibXML',
    default => sub { XML::LibXML->new() },
    lazy => 1,
);

has 'hardware_classes' => (
    is => 'ro',
    isa => 'XML::LibXML::Document',
    lazy_build => 1,
);

sub _build_hardware_classes {
    my $self = shift;
    my $parser = $self->xml_parser;
    my $classes = XML::LibXML::Element->new('classes');

    my $p = $parser->parse_file( $self->config->xml_loc('port.xml') );
    $classes->appendChild( $_ ) for $p->findnodes('//port-image');
    my $m = $parser->parse_file( $self->config->xml_loc('module.xml') );
    $classes->appendChild( $_ ) for $m->findnodes('//module');
    my $c = $parser->parse_file( $self->config->xml_loc('chassis.xml') );
    $classes->appendChild( $_ ) for $c->findnodes('//chassis');

    return $classes;
}

sub transform_and_write_out {
    my ($self, %args) = @_;
    my $stylesheet = $self->xslt_parser->parse_stylesheet_file($args{xslt});
    my $results = $stylesheet->transform( $self->xml_parser->parse_file($args{xml}) );
    $stylesheet->output_file($results, $args{out});
}

# munge the name - should be in SNMP::Info ?
# this is Cisco-specific.
sub munge_port_name {
    my ($self, $name) = @_;

    if ($name =~ m{^(?:Te|Gi|Fa)\D*(\d+/\d+(?:/\d+)?)}) {
        my $num = $1;
        $name = ( $name =~ m/^Fa/ ? "FastEthernet$num"       :
                  $name =~ m/^Gi/ ? "GigabitEthernet$num"    :
                  $name =~ m/^Te/ ? "TenGigabitEthernet$num" : $name );
    }
    return $name;
}

sub build_tree {
    my ($self, $id, $tree, $seen, %modules) = @_;
    ++$seen->{$id};

    my $mod = $modules{$id}{module};
    return if $mod->{class} !~ m/(port|chassis|stack|container|module)/;

    $self->logger->debug("ITEM pos:[$mod->{pos}] parent:[$mod->{parent}] "
        ."description[$mod->{description}] name[$mod->{name}] type[$mod->{type}] class[$mod->{class}]");

    $mod->{name} = $self->munge_port_name($mod->{name});

    my $e = XML::LibXML::Element->new($mod->{class});
    $e->setAttribute('type', $mod->{type});
    $e->setAttribute('name', $mod->{name});
    $tree->appendChild($e);

    foreach my $kidtype ( keys %{$modules{$id}{children}} ) {
        foreach my $kid ( @{$modules{$id}{children}{$kidtype}} ) {

            next if !defined $kid;
            build_tree($kid, $e, $seen, %modules);
        }
    }
}

sub get_modules {
    my ($self, $ip) = @_;
    my %modules;

    foreach my $mod (@{$self->config->device_modules($ip)}) {
        $modules{$mod->{index}}{module} = $mod;

        if ($mod->{parent}) {
            if ($mod->{pos}) {
                ${$modules{$mod->{parent}}{children}{$mod->{class}}}[$mod->{pos}] = $mod->{index};
            } else {
                push(@{$modules{$mod->{parent}}{children}{$mod->{class}}}, $mod->{index});
            }
        } else {
            push(@{$modules{root}}, $mod->{index});
        }
    }
    return %modules;
}

# dump device spec as evaluable perl
sub make_device_cache {
    my ($self, $ip) = @_;
    my %modules = $self->get_modules($ip);

    my $device = XML::LibXML::Element->new('device');
    my $seen = {};
    foreach my $id (sort {$a cmp $b} keys %modules) {
        next if $seen->{$id};
        next if !defined $modules{$id};
        next if $id eq 'root';

        $self->build_tree($id, $device, $seen, %modules);
    }

    my $doc = XML::LibXML::Document->new();
    my $root = XML::LibXML::Element->new('root');
    $doc->setDocumentElement($root);

    # insert device description XML generated from device_module DB table
    $root->appendChild($device);

    # insert module and chassis classes as loaded from shipped XML files
    $root->appendChild($self->hardware_classes);

    $doc = $self->xslt_parser->parse_stylesheet_file($self->config->xml_loc('macro.xsl'))->transform($doc);
    $doc = $self->xslt_parser->parse_stylesheet_file($self->config->xml_loc('entity.xsl'))->transform($doc);

    # ============================================================================

    my $tempdoc = File::Temp->new;
    $doc->toFile( $tempdoc->filename );

    $self->transform_and_write_out(
        xml  => $tempdoc->filename,
        xslt => $self->config->xml_loc('device-spec2perl.xsl'),
        out  => $self->config->spec_file($ip),
    );
    $tempdoc->DESTROY;
}

# dump current port-image elements as evaluable perl
sub make_ports_cache {
    my $self = shift;
    $self->transform_and_write_out(
        xml  => $self->config->xml_loc('port.xml'),
        xslt => $self->config->xml_loc('port-image2perl.xsl'),
        out  => $self->config->data_loc( $self->config->port_db_file ),
    );
}

sub make_cache_all {
    my $self = shift;
    $self->make_ports_cache;
    $self->make_device_cache($_) for @{$self->config->devices_list};
}

no Moose::Role;
1;
__END__
