#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Net::Appliance::Frontpanel;

$ENV{QUERY_STRING} =~ m/ip=(\d+\.\d+\.\d+\.\d+)/;
my $ip = $1;
exit unless $ip =~ m/^\d+\.\d+\.\d+\.\d+$/;

print "Content-Type: text/html\n\n";
print qq{<head></head>\n<body>\n"};
print qq{<img src="image.cgi?ip=$ip" usemap="#FrontPanel" title="$ip" alt="Front Panel" />\n};
print qq{<map id="FrontPanel" name="FrontPanel">\n"};

my $f = Net::Appliance::Frontpanel->new(ip => $ip);
print $f->image_map;

print qq{</map>\n};

exit 0;
