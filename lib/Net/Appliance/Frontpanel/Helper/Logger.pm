package Net::Appliance::Frontpanel::Helper::Logger;
use Moose::Role;

with 'MooseX::LogDispatch';
use File::Basename;

has 'debug' => (
    is => 'rw',
    isa => 'Int',
    lazy_build => 1,
);

sub _build_debug {
    return ($ENV{PERL_DEV} || 0);
}

has 'daemon_name' => (
    is => 'ro',
    isa => 'Str',
    default => (basename $0),
);

has log_dispatch_conf => (
    is => 'ro',
    isa => 'HashRef',
    lazy_build => 1,
);

sub _build_log_dispatch_conf {
    my $self = shift;

    my $conf_for_level = {
        0 => {
            class     => 'Log::Dispatch::Syslog',
            min_level => 'critical',
            facility  => 'daemon',
            ident     =>  $self->daemon_name,
            format    => '[%p] %m',
        },
        1 => {
            class     => 'Log::Dispatch::Screen',
            min_level => 'notice',
            stderr    =>  1,
            format    => '[%p] %m%n',
        },
        2 => {
            class     => 'Log::Dispatch::Screen',
            min_level => 'debug',
            stderr    =>  1,
            format    => '[%p] %m%n',
            #format    => '[%p] %m at %F line %L%n',
        },
    };

    return $conf_for_level->{$self->debug};
}

no Moose::Role;
1;
__END__
