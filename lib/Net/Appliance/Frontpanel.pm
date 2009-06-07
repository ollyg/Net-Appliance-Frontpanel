package Net::Appliance::Frontpanel;
use Moose;

our $VERSION = '0.02';
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
 my $panel = Net::Appliance::Frontpanel->new(ip => '192.0.2.1');
 
 print $panel->image_data; # returns a PNG
 print $panel->image_map;  # returns an HTML imagemap for the PNG

=head1 DESCRIPTION

This module will generate an image which looks like the front of a network
device, such as switch or router. The image is like those you see if you log
in to a web server on the device - it shows a picture of the device, with each
port coloured according to its state.

In addition, you can generate an HTML imagemap for this picture, with tooltip
information and a configurable hyperlink for each port.

=head1 REQUIREMENTS

Naturally, the module needs to learn about your device and its current state.
The default position is to integrate with the Netdisco Network Management
Tool, but you can plug the module into any data source.

The module uses a number of image files to build up a full frontpanel picture.
These images are supplied by the hardware manufacturer (e.g. Cisco) to
licensed customers, so neither the Netdisco team nor this module's author can
provide them to you.

=head1 INSTALLATION

=head2 Configuration Data Source

If you have Netdisco installed, and its configuration file is located at
C</etc/netdisco/netdisco.conf> then you do not need to configure the data
source.

If you have Netdisco installed, but store your configuration file elsewhere,
then pass the C<configfile> parameter to the constructor, like so:

 my $panel = Net::Appliance::Frontpanel->new(
     configfile => '/usr/local/netdisco/netdisco.conf',
     ip => '192.0.2.1',
 );

It's possible to use a data source other than Netdisco, so long as you write a
small module to satisfy a simple API. You need to create a I<Source>, and pass
its name in the constructor like so:

 my $panel = Net::Appliance::Frontpanel->new(
     source => 'MyNewSource',
     ip => '192.0.2.1',
 );

The new Source is a module which contains a number of subroutine which return
information required to build the frontpanel (e.g. the results of a poll of
ENTITY-MIB upon the device). The default Source is C<Netdisco>, which connects
to the Netdisco database to retrieve this data, but your module could do other
things. You are advised to look at the source for the
C<Net::Appliance::Frontpanel::Config::Source::Netdisco> module for some
guidance (until the API stabilizes and is documented).

=head2 Device Images

The images of a network device are typically only available under license from
the vendor, often as part of a software download. They cannot be shipped with
this module. For many Cisco devices, you can untar the IOS bundle and there
will be a set of images in there to use.

You'll need to take the images and install them in the following directory:

 /var/tmp/frontpanel/images/

=head2 XML Data Sources

The module ships with a set of XML files which describe many Cisco switches.
These are located somewhere in your Perl C<@INC> path, which can be viewed
using the C<perl -V> command on your system. In a future release there will
be a secondary folder into which you can drop your own XML data source, to
extend support to other devices.

For more information on the XML data source format, see the
L<Net::Appliance::Frontpanel::Config::Cache> module documentation.

=head1 CONFIGURATION

=head2 Prime the Device Specification Cache

You can't create the images and imagemap directly from the XML sources, there
is an intermediate step which creates a cache of metadata. Make the following
directory available, such that you can write files into it:

 /var/tmp/frontpanel/data/

Then, using the script installed with this module, build the metadata cache:

 $ frontpanel --build-all

The line above will connect to your configured I<Source> and run a build for
all devices in the source. Remember this is just metadata, not the actual
images or imagemap data.

To build for just one device, run the following:

 $ frontpanel --build 192.0.2.1

Any time your backend Source has new data, you should rebuild this cache. You
could set up a cron job to C<--build-all>, and there is an example cron file
for this in the C<examples> folder of this distribution.

=head2 Javascript Libraries for Tooltips

You'll need to download Erik Bosrup's overLIB Javascript library and install
the I<mini> version of it in a suitable location on your web server. You
then should load this from your web application using something like this:

 <script type="text/javascript" src="/scripts/overlib_mini.js"><!-- overLIB (c) Erik Bosrup --></script>

=head1 USAGE

If you have an up to date version of Netdiso, then it will automatically load
and use this module if installed. Remember you still need to install the cache
refreshing cron job, as above.

The following assumes you have done this, and the device cache is primed.

=head2 PNG Image

You can dump the PNG Image for a device using the following command:

 $ frontpanel --image 192.0.2.1 > image.png

There is also an example CGI script for this task in the C<examples> folder of
this distribution.

=head2 HTML Image Map

You can dump an HTML Image Map for a device using the following command:

 $ frontpanel --image-map 192.0.2.1

There is also an example CGI script for this task in the C<examples> folder of
this distribution.

=head2 Configuration and Source Override

Any of the above C<frontpanel> commands can take an additional parameter to
specify an alternate location for the Netdisco configuration file:

 $ frontpanel --configfile=/usr/local/netdisco/netdisco.conf ...etc

Likewise, specify the Source like so:

 $ frontpanel --source=MyNewSource ...etc

=head1 LOGGING AND DEBUGGING

By default, the module will log to the C<daemon> syslog facility any critical
errors which it encounters.

You can set a debugging level on the module, and it will chirp about the
loading of images, and so on. Set the C<PERL_DEV> environment variable:

 # syslog level 'notice' and above, output to your screen
 $ PERL_DEV=1 frontpanel ...etc

 # syslog level 'debug' and above, output to your screen
 $ PERL_DEV=2 frontpanel ...etc

=head1 DEPENDENCIES

Other than the standard Perl distribution, you will need the following:

=over 4

=item *

Moose

=item *

MooseX::LogDispatch

=item *

MooseX::Object::Pluggable

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

Config::Tiny

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

