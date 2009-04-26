package Net::Appliance::Frontpanel::Config::Cache;
use Moose::Role;

requires qw(stash);

has 'image_db' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_image_db {
    (shift)->load_cache('image_db.pl');
}

has 'port_db' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_port_db {
    (shift)->load_cache('port_db.pl');
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

has 'temp_dir' => (
    is => 'ro',
    isa => 'Str',
    lazy_build => 1,
);

sub _build_temp_dir {
    my $self = shift;
    return ($self->stash->{fp_temp_dir}
        || '/var/tmp/frontpanel');
}

sub load_file {
    my ($self, $file) = @_;
    my $disk_file = $self->temp_dir . "/$file";
    if (not (-e $disk_file && -r _ && -f _)) {
        $self->logger->error("cannot read [$disk_file]");
        return undef;
    }
    return do $disk_file;
}    

sub load_cache {
    my ($self, $file) = @_;
    return $self->load_file('data/'. $file);
}

sub load_spec {
    my ($self, $device) = @_;
    return $self->load_cache($device .'_spec.pl');
}

sub image_loc {
    my ($self, $file) = @_;
    return $self->share_dir .'/images/'. $file;
}

no Moose::Role;
1;
__END__


