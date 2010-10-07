use strict;
use warnings;
use Dancer::ModuleLoader;
use Test::More;

plan tests => 1;

{
    package Webservice;
    use Dancer;
    use Dancer::Plugin::Params::Normalization;

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
