package Net::Appliance::Frontpanel::Config::Cache;
use Moose::Role;

use File::ShareDir;
requires qw(stash);

# file names

has 'image_db_file' => (
    is => 'rw',
    isa => 'Str',
    default => 'image_db.pl',
    lazy => 1,
);

has 'port_db_file' => (
    is => 'rw',
    isa => 'Str',
    default => 'port_db.pl',
    lazy => 1,
);

# perl data structures auto-loaded

has 'image_db' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_image_db {
    my $self = shift;
    # XXX hack, we ship this and are not yet generating it
    $self->load_share($self->image_db_file);
}

has 'port_db' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_port_db {
    my $self = shift;
    $self->load_data($self->port_db_file);
}

# dir for shipped read-only files

has 'share_dir' => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_share_dir {
    my $self = shift;
    return ($self->stash->{fp_share_dir}
        || File::ShareDir::dist_dir('Net-Appliance-Frontpanel'));
#         || '/usr/local/share/frontpanel');
}

# dir for generated files

has 'cache_dir' => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_cache_dir {
    my $self = shift;
    return ($self->stash->{fp_cache_dir}
        || '/var/tmp/frontpanel');
}

# add file name to read-only dir loc

sub share_loc {
    my ($self, $file) = @_;
    return $self->share_dir . $file;
}

# add file name to generated dir loc

sub cache_loc {
    my ($self, $file) = @_;
    return $self->cache_dir . $file;
}

# add file to read-only dir loc, xml subdir

sub xml_loc {
    my ($self, $file) = @_;
    return $self->share_loc('/xml/'. $file);
}

# add file to generated dir loc, images subdir

sub image_loc {
    my ($self, $file) = @_;
    return $self->cache_loc('/images/' . $file);
}

# add file to generated dir loc, data subdir

sub data_loc {
    my ($self, $file) = @_;
    return $self->cache_loc('/data/'. $file);
}

# load perl data structure in a file

sub load_file {
    my ($self, $disk_file) = @_;
    if (not (-e $disk_file && -r _ && -f _)) {
        $self->logger->error("cannot read [$disk_file]");
        return undef;
    }
    return do $disk_file;
}

# load perl data structure for any file in the read-only share loc

sub load_share {
    my ($self, $file) = @_;
    return $self->load_file($self->share_loc('/'. $file));
}

# load perl data structure for any file in the generated dir loc, data subdir

sub load_data {
    my ($self, $file) = @_;
    return $self->load_file($self->data_loc($file));
}

# absolute path of a _spec file, in the generated dir loc, data subdir

sub spec_file {
    my ($self, $ip) = @_;
    return $self->data_loc($ip .'_spec.pl');
}

# load perl data structure for a _spec file

sub load_spec {
    my ($self, $device) = @_;
    return $self->load_file($self->spec_file($device));
}

no Moose::Role;
1;
__END__


