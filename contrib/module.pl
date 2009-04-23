#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use XML::LibXML;
use XML::LibXSLT;
use netdisco ':all';

config('/etc/netdisco/netdisco.conf');

my $ip = $ARGV[0];
die "missing arg is ip" unless $ip;
$ip = root_device($ip);

my $mods = sql_rows('device_module',['*'],{'ip'=>$ip},0,'order by parent,pos,index') || [];

my %modules;
foreach my $mod (@$mods) {
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

my $device = XML::LibXML::Element->new('device');
my %seen;
foreach my $id (sort {$a cmp $b} keys %modules) {
    next if $seen{$id};
    next if !defined $modules{$id};
    next if $id eq 'root';

    build_tree($id, $device);
}

sub build_tree {
    my ($id, $tree) = @_;
    ++$seen{$id};

    my $mod = $modules{$id}{module};
    return if $mod->{class} !~ m/(port|chassis|stack|container|module)/;

    # $mod->{$_} ||= '' for qw(name type class);
    # print "$mod->{pos} || $mod->{parent} || $mod->{description} || $mod->{name} || $mod->{type} || $mod->{class}\n";

    if ($mod->{name} =~ m{^(?:Te|Gi|Fa)\D*(\d+/\d+(?:/\d+)?)}) {
        # XXX munge the name - should be in SNMP::Info ?
        # XXX this is Cisco-specific.
        my $num = $1;
        $mod->{name} = ( $mod->{name} =~ m/^Fa/ ? "FastEthernet$num"       :
                         $mod->{name} =~ m/^Gi/ ? "GigabitEthernet$num"    :
                         $mod->{name} =~ m/^Te/ ? "TenGigabitEthernet$num" : $mod->{name} );
    }

    my $e = XML::LibXML::Element->new($mod->{class});
    $e->setAttribute('type', $mod->{type});
    $e->setAttribute('name', $mod->{name});
    $tree->appendChild($e);

    foreach my $kidtype ( keys %{$modules{$id}{children}} ) {
        foreach my $kid ( @{$modules{$id}{children}{$kidtype}} ) {

            next if !defined $kid;
            build_tree($kid, $e);
        }
    }
}

# ============================================================================

my $doc = XML::LibXML::Document->new();
my $parser = XML::LibXML->new();
my $xslt = XML::LibXSLT->new();

my $root = $doc->createElement('root');
$doc->setDocumentElement($root);

# insert device description XML generated from device_module DB table
$root->appendChild($device);

my $classes = $doc->createElement('classes');
my $p = $parser->parse_file( 'port.xml' );
$classes->appendChild( $_ ) for $p->findnodes('//port-image');
my $m = $parser->parse_file( 'module.xml' );
$classes->appendChild( $_ ) for $m->findnodes('//module');
my $c = $parser->parse_file( 'chassis.xml' );
$classes->appendChild( $_ ) for $c->findnodes('//chassis');

# insert module and chassis classes as loaded from shipped XML files
$root->appendChild($classes);

$doc = $xslt->parse_stylesheet_file('macro.xsl')->transform($doc);
$doc = $xslt->parse_stylesheet_file('entity.xsl')->transform($doc);

# ============================================================================

use File::Temp;
my $results;

# dump device spec as evaluable perl
# XXX cannot pass $doc straight to transform() - could be a bug
my $devicedoc = File::Temp->new;
$doc->toFile( $devicedoc->filename );
my $device2perl = $xslt->parse_stylesheet_file('device-spec2perl.xsl');
$results = $device2perl->transform( $parser->parse_file($devicedoc->filename) );
$device2perl->output_file($results, "${ip}_spec.pl");
$devicedoc->DESTROY;

# dump current port-image elements as evaluable perl
my $port2perl = $xslt->parse_stylesheet_file('port-image2perl.xsl');
$results = $port2perl->transform($parser->parse_file('port.xml'));
$port2perl->output_file($results, 'port_db.pl');

