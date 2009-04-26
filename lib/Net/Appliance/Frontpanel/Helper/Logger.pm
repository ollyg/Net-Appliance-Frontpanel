package Net::Appliance::Frontpanel::Helper::Logger;
use Moose::Role;

with 'MooseX::LogDispatch';
use File::Basename;

has 'debug' => (
    is => 'rw',
    isa => 'Bool',
    default => ($ENV{PERL_DEV} || 0),
);

has 'daemon_name' => (
    is => 'ro',
    isa => 'Str',
    default => (basename $0),
);

has log_dispatch_conf => (
    is => 'ro',
    isa => 'HashRef',
    lazy => 1,
    required => 1,
    default => sub {
        my $self = shift;
        return ($self->debug ?
            {
                class     => 'Log::Dispatch::Screen',
                min_level => 'debug',
                stderr    => 1,
                format    => '[%p] %m at %F line %L%n',
            }
            : {
                class     => 'Log::Dispatch::Syslog',
                min_level => 'info',
                facility  => 'daemon',
                ident     => $self->daemon_name,
                format    => '[%p] %m',
            }
        );
    },
);

no Moose::Role;
1;
__END__
