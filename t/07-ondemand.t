use strict;
use warnings;
use lib qw(../lib);
use Test::More;

plan tests => 2;

{
    package Webservice;
    use Dancer;

    BEGIN {
        set plugins => {
            'Params::Normalization' => {
                method => 'lowercase',
                general_rule => 'ondemand',
            },
        };
    }
    use Dancer::Plugin::Params::Normalization;

    # no normalization in this route
    get '/foo' => sub {
		return params->{test};
    };

    # this route normalizes its parameters names
    get '/bar' => sub {
        normalize;
		return params->{test};
    };


}

use lib 't';
use TestUtils;

# this route doesn't do parameters normalization
my $response = get_response_for_request(GET => '/foo', { TEST => 5 });
ok(! length $response->{content});

# this route does parameters normalization
$response = get_response_for_request(GET => '/bar', { TEST => 5});
is($response->{content}, 5);

