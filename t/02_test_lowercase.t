use strict;
use warnings;
use lib qw(../lib);
use Test::More;

plan tests => 1;

{
    package Webservice;
    use Dancer;

    BEGIN {
        set plugins => {
            'Params::Normalization' => {
                method => 'lowercase',
            },
        };
    }
    use Dancer::Plugin::Params::Normalization;

    get '/foo' => sub {
		return params->{test};
    };
}

use lib 't';
use TestUtils;

# test lowercasing
my $response = get_response_for_request(GET => '/foo', { TEST => 5 });
is($response->{content}, 5);
