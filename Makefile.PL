use inc::Module::Install 0.76;
perl_version '5.008001';

all_from      'lib/Net/Appliance/Frontpanel.pm';

requires      'Moose'          => 0;
requires      'XML::LibXML'    => 0;
requires      'XML::LibXSLT'   => 0;
requires      'HTML::Entities' => 0;
requires      'URI::Escape'    => 0;
requires      'Config::Any'    => 0;
requires      'Config::Tiny'   => 0;
requires      'Imager'         => 0;
requires      'DBI'            => 0;

requires      'File::Temp'     => 0;
requires      'List::Util'     => 0;
requires      'Carp'           => 0;
requires      'File::Basename' => 0;
requires      'File::ShareDir' => 0;
requires      'Getopt::Long'   => 0;

# test_requires 'Test::More'       => '0.47';

install_share;
install_script 'script/frontpanel';

WriteAll;
