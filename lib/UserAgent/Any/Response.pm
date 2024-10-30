package UserAgent::Any::Response;

use strict;
use warnings;
use v5.36;
use utf8;

use Carp;
use Moo;
use Scalar::Util 'blessed';

use namespace::clean;

sub new ($class, $res) {
  croak "Passed Response object must be a blessed reference" unless blessed($res);
  if ($res isa HTTP::Response) {
    require UserAgent::Any::Response::Impl::HttpResponse;
    return UserAgent::Any::Response::Impl::HttpResponse->new(res => $res);
  } elsif ($res isa Mojo::Message::Response) {
    require UserAgent::Any::Response::Impl::MojoMessageResponse;
    return UserAgent::Any::Response::Impl::MojoMessageResponse->new(res => $res);
  } else {
    croak 'Unknown Response type "'.ref($res).'"';
  }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Response

=head1 SYNOPSIS

  my $response = $any_ua->get($url);

  if ($response->success) {
    print $response->content."\n";
  } else {
    print $response->status_code." ".$response->status_text."\n";
  }

=head1 DESCRIPTION

C<UserAgent::Any::Response> is a read-only object containing the response from
a call made by L<UserAgent::Any>.

=head2 Constructor

=head2 Methods

=head3 status_code

  my $code = $res->status_code;

Returns the 3 digit numerical status code of the HTTP Response.

=head3 status_text

  my $text = $res->status_text;

Returns the response status message attribute explaining the response code.

=head3 content

  my $bytes = $res->content;

Returns the raw response content. This should be treated as a string of bytes.

=head3 decoded_content

  my $text = $res->decoded_content;

Returns the decoded response content according to the C<Content-Encoding>
header. For textual content this is turned into a Perl unicode string.

=head3 headers

  my %headers = $res->headers;
  my @headers_key_value_list = $res->headers;

Returns all headers of the response. Note that this actually returns a list of
alternating keys and values and that a given key can appear more than once if a
given header appears more than once in the response.

=head3 header

  my $header = $res->header($string);
  my @headers = $res->header($string);

Returns the value of the given header. if the header appears multiple times in
the response then returns the concatenated values (separated by C<,>) in scalar
context or all the values in list content.

=head3 res

  my $obj = $res->res;

Returns the underlying response object being wrapped.

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

L<HTTP::Response>

=item *

L<Mojo::Message::Response>

=back

=cut
