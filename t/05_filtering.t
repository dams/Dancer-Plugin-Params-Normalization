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
                params_filter => '^(?i)mytest$',
            },
        };
    }
    use Dancer::Plugin::Params::Normalization;

    get '/foo/:name' => sub {
		return params->{params->{name}};
    };
}

use lib 't';
use TestUtils;

# param filter regexp doesn't match, thus the param is no lowercased
my $response = get_response_for_request(GET => '/foo/test', { TEST => 5 });
ok(! length $response->{content});

# param filter regexp matches, thus the param is no lowercased
$response = get_response_for_request(GET => '/foo/mytest', { MYTEST => 5 });
is($response->{content}, 5);

