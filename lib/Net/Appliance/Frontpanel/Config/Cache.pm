package Net::Appliance::Frontpanel::Config::Cache;
use Moose::Role;

requires qw(stash);

has 'image_db_file' => (
    is => 'ro',
    isa => 'Str',
    default => 'image_db.pl',
    lazy => 1,
);

has 'port_db_file' => (
    is => 'ro',
    isa => 'Str',
    default => 'port_db.pl',
    lazy => 1,
);

has 'image_db' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_image_db {
    my $self = shift;
    $self->load_data($self->image_db_file);
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

has 'share_dir' => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_share_dir {
    my $self = shift;
    return ($self->stash->{fp_share_dir}
        || '/usr/local/share/frontpanel');
}

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

sub share_loc {
    my ($self, $file) = @_;
    return $self->share_dir . $file;
}

sub cache_loc {
    my ($self, $file) = @_;
    return $self->cache_dir . $file;
}

sub xml_loc {
    my ($self, $file) = @_;
    return $self->cache_loc('/xml/'. $file);
}

sub data_loc {
    my ($self, $file) = @_;
    return $self->cache_loc('/data/'. $file);
}

sub image_loc {
    my ($self, $file) = @_;
    return $self->share_loc('/images/' . $file);
}

sub load_file {
    my ($self, $disk_file) = @_;
    if (not (-e $disk_file && -r _ && -f _)) {
        $self->logger->error("cannot read [$disk_file]");
        return undef;
    }
    return do $disk_file;
}

sub spec_file {
    my ($self, $ip) = @_;
    return $self->data_loc($ip .'_spec.pl');
}

sub load_spec {
    my ($self, $device) = @_;
    return $self->load_file($self->spec_file($device));
}

sub load_data {
    my ($self, $file) = @_;
    return $self->load_file($self->data_loc($file));
}

no Moose::Role;
1;
__END__


