package Dancer::Plugin::Params::Normalization;
use Dancer ':syntax';
use Dancer::Plugin;

our $AUTHORITY = 'DAMS';
our $VERSION = '0.0001';

my $conf = plugin_setting;

# method that does nothing. It's optimized to nothing at compile time
my $void = sub(){};

# method that loops on a hashref and apply a given method on its keys
my $params_filter = $void;
my $apply_on_keys = sub {
    my ($h, $func) = @_;
    my $new_h = {};
    while (my ($k, $v) = each (%$h)) {
        $params_filter->($k)
          or next;
        my $new_k = $func->($k);
        exists $new_h->{$new_k} && ! ($conf->{no_conflict_warn} || 0)
          and warn "paramater names conflict while doing normalization of parameters '$k' : it produces '$new_k', which alreay exists.";
        $new_h->{$new_k} = $v;
    }
    return $new_h;
};
                          
    

# default normalization method is passthrough (do nothing)
my $normalization_fonction = $void;
if (defined $conf->{method}) {
    if (defined $conf->{params_filter}) {
        my $re = $conf->{params_filter};
        $params_filter = sub { scalar($_[0] =~ /$re/) };
    }

	my $method;
    if      ($conf->{method} eq 'lowercase') {
        $method = sub { my ($h) = @_; $apply_on_keys->($h, sub { lc($_[0]) } ) };
    } elsif ($conf->{method} eq 'uppercase') {
        $method = sub { my ($h) = @_; $apply_on_keys->($h, sub { uc($_[0]) } ) };
    } elsif ($conf->{method} eq 'ucfirst') {
        $method = sub { my ($h) = @_; $apply_on_keys->($h, sub { ucfirst($_[0]) } ) };
    } else {
        my $class = $conf->{method};
        eval("require $class");
        $@ and die "error while requiring custom normalization class '$class' : $@";
        my $abstract_classname = __PACKAGE__ . '::Abstract';
        $class->isa(__PACKAGE__ . '::Abstract')
          or die "custom normalization class '$class' doesn't inherit from '$abstract_classname'";
        my $instance = $class->new();
        # using a custom normalization is incompatible with params filters
        defined $conf->{params_filter}
          and die "your configuration contains a 'params_filter' fields, and a custom 'method' normalization class name. The two fields are incompatible";
        # todo : use *method = \&{$class->normalize} or seomthin'
        $method = sub { $instance->normalize($_[0]) };
    }

    my $routes_filter = $void;
    if (defined $conf->{routes_filter}) {
        $routes_filter = sub { };
    }

    # TODO : implement route filtering

    $normalization_fonction = sub { 
        request->_set_query_params($method->(params('query')));
        request->_set_body_params($method->(params('body')));
        request->_set_route_params($method->(params('route')));
    };
}

if (defined $conf->{general_rule}) {
    $conf->{general_rule} =~ /^always$|^ondemand$/
      or die 'configuration field general_rule must be one of : always, ondemand';      
    if ($conf->{general_rule} eq 'ondemand') {
        register normalize => sub{ $normalization_fonction->() };
    } else {
        before $normalization_fonction;
    }
} else {
    before $normalization_fonction;
}


register_plugin;

1;
__END__

=pod

=head1 NAME

Dancer::Plugin::Params::Normalization - A plugin for normalizing query parameters in Dancer.

=head1 SYNOPSYS

    package MyWebService;

    use Dancer;
    use Dancer::Plugin::Params::Normalization;

    get '/user/:name' => sub {
        'Hello ' . params->{name};
    };

    # curl http://mywebservice/user/42.json
    { "id": 42, "name": "John Foo", email: "jhon.foo@example.com"}

    # curl http://mywebservice/user/42.yml
    --
    id: 42
    name: "John Foo"
    email: "jhon.foo@example.com"

=head1 DESCRIPTION

This plugin helps you normalize the query parameters in Dancer.

=head1 CONFIGURATION

The behaviour of this plugin is primarily setup in the configuration file, in
your main config.yml or environment config file.

  # Example 1 : always lowercase all parameters from all routes
  plugins:
    Params::Normalization:
      method: lowercase

  # Example 1 : always uppercase all parameters from routes starting with /Admin/
  plugins:
    Params::Normalization:
      method: uppercase
      routes_filter: ^/Admin/

  # Example 1 : on-demand uppercase parameters that match [aA]
  plugins:
    Params::Normalization:
      general_rule: ondemand
      method: uppercase
      params_filter: [aA]

Here is a list of configuration fields:

=head2 general_rule

This field specifies if the normalization should always happen, or on demand.

Value can be of:

=over

=item always

Parameters from the routes matching the filter (see below) will

=item ondemand

Parameters are not normalized by default. The code in the route definition
needs to call normalize_params to have the parameters normalized =head1

=back

B<Default value>: C<always>

=head2 method

This field specifies what kind of normalization to do.

Value can be of:

=over

=item lowercase

parameters names are lowercased

=item uppercase

parameters names are uppercased

=item ucfirst

parameters names are ucfirst'ed

=item Custom::Class::Name

Used to execute a custom normalization method.

The given class should inherit
L<Dancer::Plugin::Params::Normalization::Abstract> and implement the method
C<normalize>. this method takes in argument a hashref of the parameters, and
returns a hashrefs of the normalized parameters. It can have an C<init> method
if it requires initialization.

Using a custom normalization is incompatible with C<params_filter> (see below).

=item passthrough

Doesn't do any normalization. Useful to disable the normalization without to
change the code

=back

B<Default value>: C<passthrough>

=head2 routes_filter

Optional, used to filters which routes the normalization should apply to.

The value is a regexp string that will be evaluated against the route names.

=head2 params_filter

Optional, used to filters which parameters the normalization should apply to.

The value is a regexp string that will be evaluated against the parameter names.

=head2 no_conflict_warn

Optional, if set to a true value, the plugin won't issue a warning when parameters name
conflict happens. See L<PARAMETERS NAMES CONFLICT>.

=head1 KEYWORDS

=head2 normalize

The general usage of this plugin is to enable normalization automatically in the configuration.

However, If the configuration field C<general_rule> is set to C<ondemand>, then
the normalization doesn't happen automatically. The C<normalize> keyword can
then be used to normalize the parameters on demand.

All you have to do is add 

  normalize;

=head1 PARAMETERS NAMES CONFLICT

if two normalized parameters names clash, a warning is issued. Example, if
while lowercasing parameters the route receives two params : C<param> and
C<Param>, they will be both normalized to C<param>, which leads to a conflict.
You can avoid the warning being issued by adding the configuration key
C<no_conflict_warn> to a true value.

=head1 LICENCE

This module is released under the same terms as Perl itself.

=head1 AUTHORS

This module has been written by Damien Krotkine <dams@cpan.org>.

=head1 SEE ALSO

L<Dancer>

=cut
