use strict;
use warnings;
use lib qw(../lib);
use Dancer::ModuleLoader;
use Test::More;
# import => ['!pass'];

plan tests => 2;

{
    package Webservice;
    use Dancer;
    use Dancer::Plugin::Params::Normalization;

    set plugins => {
        'Params::Normalization' => {
            method => 'lowercase',
        },
    };

    get '/foo' => sub {
		use Data::Dumper;
		print STDERR Dumper(params);
		return params->{test};
    };
}

use lib 't';
use TestUtils;

# test normal params
my $response = get_response_for_request(GET => '/foo', { test => 5 });
ok($response->{content} == 5, "bad response : '$response'");
my $response2 = get_response_for_request(GET => '/foo', { TEST => 5 });
ok($response2->{content} == 5, "bad response : '$response2'");
