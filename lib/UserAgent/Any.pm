package UserAgent::Any;

use v5.36;

use Carp;
use Moo;
use Scalar::Util 'blessed';

use namespace::clean;

sub new ($class, $ua) {
  croak "Passed User Agent object must be a blessed reference" unless blessed($ua);
  if ($ua isa LWP::UserAgent) {
    require UserAgent::Any::Impl::LwpUserAgent;
    return UserAgent::Any::Impl::LwpUserAgent->new(ua => $ua);
  } elsif ($ua isa AnyEvent::UserAgent) {
    require UserAgent::Any::Impl::AnyEventUserAgent;
    return UserAgent::Any::Impl::AnyEventUserAgent->new(ua => $ua);
  } elsif ($ua isa Mojo::UserAgent) {
    require UserAgent::Any::Impl::MojoUserAgent;
    return UserAgent::Any::Impl::MojoUserAgent->new(ua => $ua);
  } elsif ($ua isa HTTP::Promise) {
    require UserAgent::Any::Impl::HttpPromise;
    return UserAgent::Any::Impl::HttpPromise->new(ua => $ua);
  } else {
    croak 'Unknown User Agent type "'.ref($ua).'"';
  }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any – Wrapper above any UserAgent library, supporting sync and async
calls

=head1 SYNOPSIS

  my $ua = UserAgent::Any->new(LWP::UserAgent->new(%options));

  my $res = $ua->get($url, %params);

=head1 DESCRIPTION

C<UserAgent::Any> is to user agents what L<Log::Any> is to loggers, it allows to
write libraries making RPC calls without having to rely on one particular user
agent implementation.

C<UserAgent::Any> also supports both synchronous and asynchronous calls even if
the underlying user agent is synchronous only.

=head2 Supported user agents

=head3 L<LWP::UserAgent>

When using an L<LWP::UserAgent>, a C<UserAgent::Any> object only implements the
synchronous calls (without the C<_cb> or C<_p> suffixes).

=head3 L<Mojo::UserAgent>

When using a L<Mojo::UserAgent>, a C<UserAgent::Any> object implements the
asynchronous calls using the global singleton L<Mojo::IOLoop> and the methods
with the C<_p> suffix return L<Mojo::Promise> objects.

=head3 L<AnyEvent::UserAgent>

When using a L<AnyEvent::UserAgent>, a C<UserAgent::Any> object implements the
asynchronous calls using L<AnyEvent> C<condvar> and the methods with the C<_p>
suffix return L<Promise::XS> objects (that module needs to be installed).

Note that you probably want to set the event loop used by the promise, which has
global effect so is not done by this module. It can be achieved with:

  Promise::XS::use_event('AnyEvent');

You can read more about that in L<Promise::XS/EVENT LOOPS>.

If you need different promise objecte (especially L<Future>), feel free to ask
for or contribute new implementations.

=head2 Constructor

  my $ua = UserAgent::Any->new($underlying_ua);

Builds a new C<UserAgent::Any> object wrapping the given underlying user agent.
The wrapped object must be an instance of a
L<supported user agent|/Supported user agent>. Feel free to ask for or
contribute new implementations.

=head2 Methods

=head3 get

  my $res = $ua->get($url, %params);

  $ua->get_cb($url, %params)->($cb);

  my $promise = $ua->get_p($url, %params);

Note that while the example aboves are using C<%params>, the parameters are
actually treated as a list as the same key can appear multiple times to send the
same header multiple time. But that list must be an even-sized list of
alternating key-value pairs.

=head3 post

  my $res = $ua->post($url, %params, $content);

  $ua->post_cb($url, %params, $content)->($cb);

  my $promise = $ua->post_p($url, %params, $content);

=head3 Where are the other methods?

Modern REST application should only use the C<GET> and C<POST> verbs so these
are the only one implemented currently. If you need them, feel free to ask for
or contribute the implementation of other methods.

=head1 BUGS AND LIMITATIONS

=over 4

=item *

L<AnyEvent::UserAgent> does not properly support sending a single header
multiple times: all the values will be concatenated (separated by C<, >) and
sent as a single header. This is supposed to be equivalent but might give a
different behavior from other implementations.

=back

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

L<LWP::UserAgent>

=item *

L<AnyEvent::UserAgent>

=item *

L<Mojo::UserAgent>

=back

=cut
