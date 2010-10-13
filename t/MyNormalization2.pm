package MyNormalization2;
use strict;
use warnings;
use base qw(Dancer::Plugin::Params::Normalization::Abstract);

# shorten to 3 last caracters
sub normalize {
    my ($self, $params) = @_;
    $params->{substr($_, -3, 3)} = delete $params->{$_} foreach keys %$params;
    return $params;
}

1;
