package Dancer::Plugin::Params::Normalization::Trim;
use strict;
use warnings;

# TRIM: normalization class for white space filtering

use base 'Dancer::Plugin::Params::Normalization::Abstract';

# set the trim_filter
sub _trim_filter {
    $_[0] =~ s/^\s+|\s+$//g;
}

sub normalize {
    my ($self, $params) = @_;
    $params = $self->_trim_filter($params) foreach keys %$params;
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
