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

=head2 Constructor

  my $ua = UserAgent::Any->new($underlying_ua);

Builds a new C<UserAgent::Any> object wrapping the given underlying user agent.
Currently supported wrapped objects are L<LWP::UserAgent>,
L<AnyEvent::UserAgent> and L<Mojo::UserAgent>. Feel free to ask for or
contribute new implementations.

=head2 Methods

=head3 get

  my $res = $ua->get($url, %params);

=head3 get_cb

  $ua->get_cb($url, %params)->($cb);

=head3 get_p

  my $promise = $ua->get_p($url, %params);

=head3 post

  my $res = $ua->post($url, %params, $content);

=head3 post_cb

  $ua->post_cb($url, %params, $content)->($cb);

=head3 post_p

  my $promise = $ua->post_p($url, %params, $content);

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
