use strict;
use warnings;
use lib qw(../lib);
use Test::More;
use lib 't';

plan tests => 2;

{
    package Webservice;
    use Dancer;

    BEGIN {
        set plugins => {
            'Params::Normalization' => {
                method => 'MyNormalization2',
            },
        };
    }
    use Dancer::Plugin::Params::Normalization;

    # no normalization in this route
    get '/foo' => sub {
		return params->{ing};
    };

    # this route normalizes its parameters names
    get '/bar' => sub {
		return params->{AME};
    };


}

use TestUtils;

# 'testing' should be shortened to 'ing'
my $response = get_response_for_request(GET => '/foo', { testing => 5 });
is($response->{content}, 5);

# 'ABCLONGNAME' should be shortened to 'AME'
$response = get_response_for_request(GET => '/bar', { ABCLONGNAME => 6});
is($response->{content}, 6);
