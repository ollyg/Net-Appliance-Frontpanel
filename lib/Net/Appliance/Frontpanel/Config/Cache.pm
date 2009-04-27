package Net::Appliance::Frontpanel::Config::Cache;
use Moose::Role;

requires qw(stash);

has 'image_db' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_image_db {
    (shift)->load_data('image_db.pl');
}

has 'port_db' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_port_db {
    (shift)->load_data('port_db.pl');
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

sub load_data {
    my ($self, $file) = @_;
    return $self->load_file($self->data_loc($file));
}

sub load_spec {
    my ($self, $device) = @_;
    return $self->load_data($device .'_spec.pl');
}

no Moose::Role;
1;
__END__


