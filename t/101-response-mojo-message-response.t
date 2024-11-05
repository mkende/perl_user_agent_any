use strict;
use warnings;
use utf8;

use Encode 'encode';
use Test2::V0 -target => 'UserAgent::Any::Response';

BEGIN {
  eval 'use Mojo::Message::Response';  ## no critic (ProhibitStringyEval, RequireCheckingReturnValueOfEval)
  skip_all('Mojo::Message::Response is not installed') if $@;
}

my $utf8_content = 'Héllö!';
my $raw_content = encode('UTF-8', $utf8_content);
my $raw_response = Mojo::Message::Response->new(code => 200, message => 'success');
$raw_response->body($raw_content);
my $headers = $raw_response->headers;
$headers->add('Content-Type' => 'text/plain; charset=utf-8');
$headers->add('Foo' => 'Bar', 'Bar2');
$headers->add('Baz' => 'bin');

my $r = CLASS()->new($raw_response);

isa_ok($r, ['UserAgent::Any::Response', 'UserAgent::Any::Response::Impl::MojoMessageResponse']);

is($r->res, $raw_response, 'res');
is($r->status_code, 200, 'status_code');
is($r->status_text, 'success', 'status_text');
is($r->content, $raw_content, 'content');
is($r->decoded_content, $utf8_content, 'decoded_content');
is($r->header('Baz'), 'bin', 'header1');
is($r->header('Foo'), 'Bar, Bar2', 'header2scalar');
is([$r->header('Foo')], ['Bar', 'Bar2'], 'header2list');

done_testing;
