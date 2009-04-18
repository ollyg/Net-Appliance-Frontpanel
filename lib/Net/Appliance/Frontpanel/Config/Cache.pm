package Net::Appliance::Frontpanel::Config::Cache;
use Moose::Role;

has 'port_db' => (
    is => 'ro',
    isa => 'HashRef[HashRef]',
    lazy_build => 1,
);

sub _build_port_db {
    (shift)->load_cache('port_db.pl');
}

sub load_file {
    my ($self, $file) = @_;
    my $path = $self->stash->{fp_dir};
    return do "$path/$file";
}    

sub load_cache {
    my ($self, $file) = @_;
    return $self->load_file('data/'. $file);
}

sub load_spec {
    my ($self, $file) = @_;
    return $self->load_cache($file .'_spec.pl');
}

sub image_loc {
    my ($self, $file) = @_;
    return $self->stash->{fp_dir} .'/images/'. $file;
}

no Moose::Role;
1;
__END__


