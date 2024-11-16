package UserAgent::Any::Wrapper;

use 5.036;

use Exporter 'import';

our $VERSION = 0.01;
our @EXPORT_OK = ('wrap_method');

sub _wrap_response {
  return undef unless @_;  ## no critic (ProhibitExplicitReturnUndef)
  return @_ if @_ == 1;
  return \@_;
}

sub wrap_method {  ## no critic (RequireArgUnpacking)
  my $name = shift;
  my $member = shift if ref($_[0]) eq 'CODE';  ## no critic (ProhibitConditionalDeclarations)
  my ($method, $code, $cb) = @_;
  my $dest_pkg = caller(0);
  no strict 'refs';  ## no critic (ProhibitNoStrict)
  my $get_obj = defined $member ? sub ($self) { $self->$member() } : sub ($self) { $self };
  if (defined $cb) {
    *{"${dest_pkg}::${name}"} = sub ($self, @args) {
      $cb->($self, _wrap_response($get_obj->($self)->$method($code->($self, @args))), @args);
    };
    my $method_cb = "${method}_cb";
    *{"${dest_pkg}::${name}_cb"} = sub ($self, @args) {
      return sub ($final_cb) {
        $get_obj->($self)->$method_cb($code->($self, @args))
            ->(sub { $final_cb->($cb->($self, &_wrap_response, @args)) });
      }
    };
    my $method_p = "${method}_p";
    *{"${dest_pkg}::${name}_p"} = sub ($self, @args) {
      $get_obj->($self)->$method_p($code->($self, @args))
          ->then(sub { $cb->($self, &_wrap_response, @args) });
    };
  } else {
    *{"${dest_pkg}::${name}"} =
        sub ($self, @args) { $get_obj->($self)->$method($code->($self, @args)) };
    my $method_cb = "${method}_cb";
    *{"${dest_pkg}::${name}_cb"} =
        sub ($self, @args) { $get_obj->($self)->$method_cb($code->($self, @args)) };
    my $method_p = "${method}_p";
    *{"${dest_pkg}::${name}_p"} =
        sub ($self, @args) { $get_obj->($self)->$method_p($code->($self, @args)) };
  }
  return;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Wrapper – Helpers to write higher level client libraries on top
of C<UserAgent::Any>, while retaining its benefit (support of any user agent,
all HTTP verbs, multiple asynchronous models, etc.).

=head1 SYNOPSIS

  wrap_method('bar' => 'foo', sub ($self, @args) { make_args_for_foo($@args) });

=head1 DESCRIPTION

This section describes how to write higher level client libraries, on top of
C<UserAgent::Any>, while retaining its benefit (support for any user agents and
multiple asynchronous models).

You should first read the documentation of the
L<C<UserAgent::Any::get()> method>|UserAgent::Any/get> to understand the
asynchronous models implemented by L<UserAgent::Any>.

=head3 Wrapping a class method

  wrap_method($name => $delegate, sub ($self, ...) { ... }, sub ($self, $res, ...));

The call above will generate in your class a set of methods named C<$name>,
C<$name_cb>, and C<$name_p>. These methods will each execute the first sub that
was passed to C<wrap_method()> and then pass the results to the method named
with C<$delegate> and a suffix matching that of the function called. The result
of that call if passed to the second sub, if it was provided, in the right async
context (in a callback or a C<then> method of a promise).

For example, if you have a class that can I<already> handle methods C<foo>,
C<foo_cb>, and C<foo_p> with the same semantics as the user agent methods above
(this will typically be the methods for C<UserAgent::Any> itself) and you want
to expose a method C<bar> that depends on C<foo> you can write:

  wrap_method('bar' => 'foo', sub ($self, @args) { make_args_for_foo($@args) });

And this will expose in your package a set of C<bar>, C<bar_cb>, and C<bar_p>
methods with the same semantics that will use the provided method reference to
build the arguments to C<foo>. For the synchronous case, the method from the
example above will be equivalent to:

  sub bar ($self, @args) { $self->foo($self, make_args_for_foo(@args))}

You can optionally pass a second callback that will be called with the response
from the wrapped method:

  wrap_method($name => $delegate, $cb,
              sub ($self, $res, @args) { process_results($res) });

The second callback will be called with the current object, the response from
the wrapped method and the arguments that were passed to the wrappers (the same
that were already passed to the first callback). The wrapped method will be
called in list context. If it returns exactly 1 result, then that result is
passed as-is to the second callback; if it returns 0 result, then the callback
will receive C<undef>; otherwise the callback will receive an array reference
with the result of the call.

The call above is equivalent to the following code (for the synchronous case):

  sub bar ($self, @args) {
    process_results($self->foo($self, make_args_for_foo(@args)));
  }

If you don’t pass a second callback, then the callback, promise or method will
return the default result from the invoked method, without any transformation.

=head3 Wrapping a method of a class member

  wrap_method($name => \&method, $delegate, $cb1[, $cb2]);

Alternatively to the above, C<wrap_method> can be used to wrap a method of a
class member. Instead of calling the method named C<$delegate> in your class,
the call above will call the method named C<$delegate> on the reference returned
by the call to C<&method>.

=head2 Example

Here is are two minimal example on how to create a client library for a
hypothetical service exposing a C<create> call using the C<POST> method.

  package MyPackage;

  use 5.036;

  use Moo;
  use UserAgent::Any 'wrap_method';

  use namespace::clean;

  extends 'UserAgent::Any';

  wrap_method(create_document => 'post', sub ($self, %opts) {
    return ('https://example.com/create/'.$opts{document_id}, $opts{content});
  });

Or, if you don’t want to re-expose the C<UserAgent::Any> method in your class
directly (possibly because you want to re-use the same names), you can do:

  package MyPackage;

  use 5.036;

  use Moo;
  use UserAgent::Any 'wrap_method';

  use namespace::clean;

  has ua => (
    is => 'ro',
    coerce => sub { UserAgent::Any->new($_[0]) },
    required => 1,
  );

  wrap_method(create_document => \&ua => 'post', sub ($self, %opts) {
    return ('https://example.com/create/'.$opts{document_id}, $opts{content});
  });

=head1 AUTHOR

Mathias Kende <mathias@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2024 Mathias Kende

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=head1 SEE ALSO

=over 4

=item *

L<UserAgent::Any>

=back

=cut
