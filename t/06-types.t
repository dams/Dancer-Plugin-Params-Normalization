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
                params_types => [ qw (route) ],
            },
        };
    }
    use Dancer::Plugin::Params::Normalization;

    # the real test is done here : the route param is called 'NAME', but accessed
    # as 'name'
    get '/foo/:NAME' => sub {
		return params->{params->{name}};
    };
}

use lib 't';
use TestUtils;

# only route params are lowercase'd
my $response = get_response_for_request(GET => '/foo/test', { TEST => 5 });
ok(! length $response->{content});

# route param (:NAME) is lowercased to 'name', and returns 'plop'
$response = get_response_for_request(GET => '/foo/plop', { plop => 5});
is($response->{content}, 5);

