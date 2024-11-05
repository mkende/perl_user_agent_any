package TestSuite;

use strict;
use warnings;
use utf8;

use v5.36;

use Test::HTTP::MockServer;
use Test2::V0;

my $mock = Test::HTTP::MockServer->new();
$mock->bind_mock_server();
$mock->start_mock_server(sub ($req, $res) {  # req and res are HTTP::Request and HTTP::Response objects
  if ($req->uri->path eq '/index' && $req->method eq 'GET') {
    $res->content('hello');
  } elsif ($req->uri->path eq '/echo' && $req->method eq 'POST') {
    $res->content($req->content);
  } else {
    die "unexpected call";
  }
});

my %get = ('' => 'get', 'cb' => 'get_cb', 'p' => 'get_p');
my %post = ('' => 'post', 'cb' => 'post_cb', 'p' => 'post_p');

my @tests = (
  [ sub ($ua, $mode) { $ua->${\$get{$mode}}($mock->url_base()."/index") },
    sub ($r, $name) {
      is($r->status_code, 200, "${name} - get index status code");
      is($r->decoded_content, 'hello', "${name} - get index decoded content");
    }
  ],
  [ sub ($ua, $mode) { $ua->${\$post{$mode}}($mock->url_base()."/echo", 'the content') },
    sub ($r, $name) {
      is($r->decoded_content, 'the content', "${name} - post echo decoded content");
    }
  ],
);

sub run ($ua, $start_loop = undef, $stop_loop = undef) {
  for my $t (@tests) {
    my ($req_emiter, $res_processor) = @{$t};
    my $r = $req_emiter->($ua, '');
    $res_processor->($r, 'sync');
  }

  return unless defined $start_loop;

  for my $t (@tests) {
    my ($req_emiter, $res_processor) = @{$t};
    $req_emiter->($ua, 'cb')->(sub ($r) { $res_processor->($r, 'callback'); $stop_loop->() });
    $start_loop->();
  }

  for my $t (@tests) {
    my ($req_emiter, $res_processor) = @{$t};
    $req_emiter->($ua, 'p')->then(sub ($r) { $res_processor->($r, 'promise'); $stop_loop->() });
    $start_loop->();
  }
}

1;
