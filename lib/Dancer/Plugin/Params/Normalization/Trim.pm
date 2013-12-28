package Dancer::Plugin::Params::Normalization::Trim;
use strict;
use warnings;

# TRIM: normalization class for white space filtering

use base 'Dancer::Plugin::Params::Normalization::Abstract';

#set the trim_filter
my $trim_filter = sub {
    return scalar($_[0] =~ s/^\s+|\s+$//g)
};

sub normalize {
    my ($self, $params) = @_;
    $trim_filter->($_) for values %$params;
    return $params;
    }

1;

__END__

=pod

=head1 NAME

Dancer::Plugin::Params::Normalization::Trim - normalization class for white space filtering

=head1 DESCRIPTION

#add me

=cut
