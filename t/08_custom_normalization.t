use strict;
use warnings;
use lib qw(../lib);
use Test::More;

{
package My::Normalization1;
use strict;
use warnings;
use base qw(Dancer::Plugin::Params::Normalization::Abstract);

# shorten to 3 first caracters
sub normalize {
    my ($self, $params) = @_;
    $params->{substr($_, 0, 3)} = delete $params->{$_} foreach keys %$params;
    return $params;
}

}
plan tests => 2;

{
    package Webservice;
    use Dancer;

    BEGIN {
        set plugins => {
            'Params::Normalization' => {
                method => 'My::Normalization1',
            },
        };
    }
    use Dancer::Plugin::Params::Normalization;

    # no normalization in this route
    get '/foo' => sub {
		return params->{tes};
    };

    # this route normalizes its parameters names
    get '/bar' => sub {
		return params->{ABC};
    };


}

use lib 't';
use TestUtils;

# 'testing' should be shortened to 'tes'
my $response = get_response_for_request(GET => '/foo', { testing => 5 });
is($response->{content}, 5);

# 'ABCLONGNAME' should be shortened to 'ABC'
$response = get_response_for_request(GET => '/bar', { ABCLONGNAME => 6});
is($response->{content}, 6);


1;
