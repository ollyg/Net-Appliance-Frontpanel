#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Net::Appliance::Frontpanel;

$ENV{QUERY_STRING} =~ m/ip=(\d+\.\d+\.\d+\.\d+)/;
my $ip = $1;
exit unless $ip =~ m/^\d+\.\d+\.\d+\.\d+$/;

print "Content-Type: image/png\n\n";

my $f = Net::Appliance::Frontpanel->new(ip => $ip);
print $f->image_data;

exit 0;
