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
                method => 'uppercase',
            },
        };
    }
    use Dancer::Plugin::Params::Normalization;

    get '/foo' => sub {
		return params->{TEST};
    };
}

use lib 't';
use TestUtils;

my $response = get_response_for_request(GET => '/foo', { test => 5 });
is($response->{content}, 5);
