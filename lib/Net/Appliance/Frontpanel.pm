package Net::Appliance::Frontpanel;
use Moose;

our $VERSION = '0.01';
$VERSION = eval $VERSION; # numify for warning-free dev releases

use Net::Appliance::Frontpanel::Config;

with 'Net::Appliance::Frontpanel::ImageRole';
with 'Net::Appliance::Frontpanel::CacheBuilderRole';

has 'config' => (
    is => 'rw',
    isa => 'Net::Appliance::Frontpanel::Config',
);

sub BUILD {
    my ($self, $params) = @_;
    $self->config(
        Net::Appliance::Frontpanel::Config->new($params));
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

Net::Appliance::Frontpanel - Images of network devices with clickable HTML imagemaps

=head1 VERSION

This document refers to version 0.01 of Net::Appliance::Frontpanel

=head1 WARNING

This is an ALPHA RELEASE. I'd really appreciate any bug reports; you can use
the CPAN RT bug tracking system, or email me (Oliver) directly at the address
at the bottom of this page.

=head1 PURPOSE

Use this module to generate PNG images of your network switches and routers.
It can also generate corresponding HTML imagemaps with a tooltip and hyperlink
for each port on the device.

=head1 SYNOPSIS

 use Net::Appliance::Frontpanel;
 my $panel = Net::Appliance::Frontpanel->new(ip => '192.168.0.1');
 
 print $panel->image_data; # returns a PNG
 print $panel->image_map;  # returns an HTML imagemap for the PNG

=head1 DESCRIPTION

This module will generate an image which looks like the front of a network
device, such as switch or router. The image is like those you see if you log
in to a web server on the device - it shows a picture of the device, with each
port coloured according to its state.

In addition, you can generate an HTML imagemap for this picture, with tooltip
information and a configurable hyperlink for each port.

=head2 REQUIREMENTS

Naturally, the module needs to learn about your device and its current state.
The default position is to integrate with the Netdisco Network Management
Tool, but you can plug the module into any data source.

The module uses a number of image files to build up a full frontpanel picture.
These images are supplied by the hardware manufacturer (e.g. Cisco) to
licensed customers, so neither the Netdisco team nor this module's author can
provide them to you.

=head1 NEW DEVICES

The current distribution of this module knows about a few Cisco switches of
varying types. If you have the images in place on your web server, there's a
good chance you'll get some kind of frontpanel display straight away. However
as device software gets updated, and new devices are released, this module
will need to know about them. This section explains how this is all done.

=head2 Device XML Specifications

A little bit of background and history is required, here. Netdisco, during its
overnight updating process, gathers information via SNMP from the device. One
area of information recovered is the ENTITY-MIB, which is described in RFC
2737, and is a logical description of the physical set-up of your device. The
description has some standardized names for components:

=over 4

=item *

Stack

=item *

Chassis

=item *

Container

=item *

Module

=item *

Port

=back

All devices can be described using a tree of just these components, and that's
what's stored in the Netdisco database. The components have code names; for
example a 100Mbit fibre port and a Gigabit copper port will have different
code names, but are both ports. All this allows us to start with generic
descriptions of the component parts of a device, and then when we look in
Netdisco's database, all the pieces can be put together to build a frontpanel
image with the right combination of ports, containers, and so on.

Three XML files in this distribution contain generic descriptions of every
component which we know about. The 100Mbit fibre port will have an entry in
the C<port.xml> file, typically mentioning just the image file used to represent
it on a frontpanel.  When this port is mentioned in Netdsco's database,
this module will know which image to use to represent the port. Other parts are
more complex; for instance the the chassis represents a particular model of
device, and tells this module where the other components such as ports and
containers (e.g. SFP slots) are placed. The C<chassis.xml> and C<module.xml>
files describe x and y co-ordinates, rotation, and other aspects of these
components.

Let's look at each component type in turn, and see how we represent them in
the XML files.

=head3 Stack

The stack component (e.g. C<cevStackCat37xx>) doesn't need an entry in the XML
database, as it's a logical component which this module just uses to let it
know there are multiple devices to be drawn.

=head3 Chassis

The chassis component (e.g. C<cevChassisCat375024>) does need to appear in the
XML database, as it tells this module which image forms the main background
for the device. An entry must go into the C<chassis.xml> file, and here is one
example:

 <!-- a Cisco 3750 with 24 10/100 ports and two SFP slots -->
 <chassis type="cevChassisCat375024" image="c375024_2.gif">
     <portGroup type="cevPortNIC100"
         x="110" y="25"
         xStep="20" yStep="16"
         width="6" height="2"
         countDirection="down"/>
 
     <portGroup type="cevPortNIC100"
         x="259" y="25"
         xStep="20" yStep="16"
         width="6" height="2"
         countDirection="down"/>
 
     <container type="cevContainerSFP" x="469" y="39"/>
     <container type="cevContainerSFP" x="533" y="39"/>
 </chassis>

The chassis description starts with a C<type>, which matches the code name
returned from an SNMP poll of the ENTITY-MIB on the device. Next is an
attribute that says which C<image> file to use for the component.

If you've ever seen one of these 24 port switches, you'll know that the ports
are split into two groups of 12, and that the port numbers count up from left
to right, with odd numbers on the top row and even numbers on the bottom row.
This is all described in the C<portGroup> element, which is a convenience to
save having to write out (and calculate the layout of) 12 separate C<port>
elements.  The ports in a port group I<must> all be of the same type. The
C<type> attribute tells this module which port to look up in C<port.xml> to
find the image to draw. The C<width> and C<height> attributes say how large
this port group is (6 x 2 = 12 ports, in a bunch which is six wide and two
high). The C<x> and C<y> attributes say where the top left of the port group
is in pixels, relative to the top left of the chassis image itself, and
C<xStep> and C<yStep> describe the spacing between the top left corner of each
port in the port group, in pixels.  Finally, the C<countDirection> attribute
is a hint to this module as to whether the counting of the ports increases
with the width of the group (C<across>) or the height (C<down>) first, before
continuing with the other dimension. Right to left or bottom to top counting
of ports can be achieved by using a negative value for C<xStep> or C<yStep>.

With this set of attributes, you can describe (almost) any group of ports,
with any orientation and count direction.

As well as fixed ports, devices often contain slots for pluggable modular
ports (SFP, XFP, and so on). These use the C<container> element, which simply
says where the slot is located on the chassis (in pixels from the top left of
the chassis image). When a container is empty, that's not a problem;
this module will discover this from the Netdisco database. Most chassis
images have on them a representation of the empty container (e.g. an empty SFP
slot) so things 'look right'. Some however, don't, so it's a good idea to use
the C<type> attribute and mention the container type. The module will then
draw an image for the container, just in case; this is described in more
detail in the Port section, below. On slot-based based devices, a container
might be a line card slot, rather than merely a port; this doesn't change the
chassis description, and we'll come back to modular chassis in the Module
section, below.

There also exists a C<port> element, and a C<containerGroup> element. These
follow exactly the same style as their sibling elements in the example above,
except for the difference in attributes used. You'll see examples of these in
the sections below. We could have represented the two containers in the
example above with one C<containerGroup>, but that would probably have been a
little excessive. Likewise each of the C<portGroup>s could have been 12 separate
C<port> elements.

One additional attribute not featured in this example is C<rotate>. This simply
specifies a clockwise rotation in degrees for the image file stored on disk,
and can be set to C<90>, C<180>, or C<270>. It's most commonly used in slot-based
chassis to rotate containers, such as the Cisco 6500 and 7600 series which
take the same line cards in varying orientations, depending on which chassis
you have. Both C<port> and C<container> elements, as well as their C<*Group>
siblings, may have a rotation.

=head3 Container

The container component (e.g. C<cevContainerSFP>) doesn't need an entry in the
XML database, as it's a slot into which something more useful gets put. It
does crop up in the C<port.xml> file, though, but that will be covered in the
Port section, below.

=head3 Module

Experience so far suggests modules turn out to be line cards in slot-based
chassis devices. The way to think about a module is that from the perspective
of this module it's really a kind of chassis-lite - it has ports and
containers just like a fixed chassis. In fact the XML description of a module
in the C<module.xml> file is exactly the same as for a chassis in
C<chassis.xml>, except the outer element is called C<module> rather than
C<chassis>.

Sometimes, though, there will be a module in the device component tree which
doesn't need to be mentioned in C<module.xml>. These modules appear in
fixed-chassis devices such as the 24 port switch used in the example
previously. The trick to identifying them is that these modules don't sit
within a container; sometimes they mention 'Fixed' in the description too,
e.g. "C<WS-C3750G-24TS - Fixed Module 0 (cevModuleCat375024TS)>". You can
ignore such modules, they'll be skipped as 'dummies' by this module.

=head3 Port

Whilst the port descriptions, which all live in the C<port.xml> file, are simple
in themselves, sadly the manufacturers have made a dog's breakfast of their
SNMP reports from devices. What this boils down to is that whilst you think
that a port ought to be reported as "C<cevPort100BaseFX>" in fact it might get
the code "C<cevPortFe>" or even "C<cevPort.123>" (I'm not kidding!). It appears to
be something which gets fixed as manufacturers release new software versions
for the device. Anyway, there is a simple system for working around these
mistakes, which we'll see below.

Your basic port identifier in C<port.xml> looks like this:

 <!-- 10/100/1000 RJ45 port -->
 <port-image type="cevPortBaseTEther">
     <up>green.gif</up>
     <down>gray.gif</down>
 </port-image>

As you can see, the module is using this information to select image files
when the port code appears in a module or chassis description. The port state
comes from the Netdisco database, so one of the images in the C<up> and C<down>
elements will be selected as appropriate.

In the Container section, above, I mentioned that you'll sometimes want to
have this module draw the image for an empty container if it's missing from
the chassis image. In this case you would create a C<port-image> element as in
the example above, with the C<type> attribute set to the container's code.
Instead of using C<up> or C<down> inner element, use an element called
C<empty> to specify the image to be used.

When you're getting the 'wrong' description code for a port, just add another
C<port> to the XML file with the same details but a different value for the
C<type> attribute's value. The module will pick the right one. However your
chassis or module spec will also probably be incorrect, so you'll need to
double up the C<port> or C<portGroup> element in that, adding another for the
rogue description code you're receiving. This module will ignore C<port> and
C<portGroup> elements in a C<chassis> or C<module> which are missing from the
device component tree in the Netdisco database.

Even then, sometimes this simple trick isn't going to work. We've seen devices
which report LC connector fibre ports as 1000BASE-T (copper) ports. In this
case you can't have a C<port-image> for the 1000BASE-T port using the LC
connector's image, because all your real 1000BASE-T ports will then be using
the wrong image! Okay, don't panic, there is a feature in this module to
deal with this. The problem crops up usually on one particular type of device,
so when specifying the C<type> attribute in a C<port-image>, you have the option to
qualify it with the chassis or module and/or container code. The
format is quite simple: separate the codes by the underscore character. Here
are some examples:

 <!-- 1Gig fibre port in an SFP slot in a WS-C3750G-12S -->
 <port-image type="cevChassisCat3750Ge12Sfp_cevPortBaseTEther"> ...
 
 <!-- Empty GBIC slot in 6500 chassis 8xGBIC line card -->
 <port-image type="cevCat6kWsx6408aGbic_cevContainerGbic"> ...
 
 <!-- 1Gig fibre GBIC module in 6500 chassis 8xGBIC line card -->
 <port-image type="cevCat6kWsx6408aGbic_cevPortGigBaseSX"> ...
 
 <!-- 1Gig fibre SFP module in early software releases -->
 <port-image type="cevContainerGbic_cevPortUnknown"> ...

You can see from these examples that sometimes it's useful to specify the port
code relative to its container, and other times relative to the module (line
card) or chassis. The C<port.xml> file has a comment in which explains the valid
combinations.

=head2 Validating your XML

It's possible to have your XML files validated, which will check for certain
common errors in syntax. A RELAX-NG (compact) schema is shipped with this
distribution, and you can use the C<trang> and C<xmllint> tools to validate it. The
minimum you should expect is that C<xmllint> says your XML files are parsable (it
echoes them out), and at best you can get it to use the RELAX-NG schema for a
more complete validation.

=head1 DEPENDENCIES

Other than the standard Perl distribution, you will need the following:

=over 4

=item *

Moose

=item *

XML::LibXML

=item *

XML::LibXSLT

=item *

HTML::Entities

=item *

URI::Escape

=item *

Config::Any

=item *

Imager

=item *

DBI

=back

=head1 AUTHOR

Oliver Gorwits C<< <oliver.gorwits@oucs.ox.ac.uk> >>

=head1 ACKNOWLEDGEMENTS

Thanks to Peter Ehlin who wrote the original Frontpanel patch for Netdisco.

=head1 COPYRIGHT & LICENSE

Copyright (c) Oliver Gorwits 2009.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

