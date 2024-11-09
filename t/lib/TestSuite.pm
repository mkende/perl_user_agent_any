package TestSuite;

use strict;
use warnings;
use utf8;

use v5.36;

use Data::Dumper;
use Test::HTTP::MockServer;
use Test2::API 'intercept';
use Test2::IPC;
use Test2::Tools::Subtest 'subtest_streamed';
use Test2::V0;


my $mock;

sub _start_server {
  $mock = Test::HTTP::MockServer->new();
  $mock->bind_mock_server();
  $mock->start_mock_server(sub ($req, $res) {  # req and res are HTTP::Request and HTTP::Response objects
    if ($req->uri->path eq '/index' && $req->method eq 'GET') {
      $res->content('hello');
    } elsif ($req->uri->path eq '/echo' && $req->method eq 'POST') {
      $res->content($req->content);
    } elsif ($req->uri->path eq '/multi-header' and $req->header('X-multi') eq 'Foo, Bar, Baz') {
      # return OK
    } elsif ($req->uri->path eq '/content-header') {
      $res->content($req->header('Content'));
    } else {
      print STDERR Dumper($req);
      die "unexpected call";
    }
  });
}

sub _stop_server {
  $mock->stop_mock_server();
}

my %get = ('' => 'get', 'cb' => 'get_cb', 'p' => 'get_p');
my %post = ('' => 'post', 'cb' => 'post_cb', 'p' => 'post_p');

my @tests = (
  [ 'get index status',
    sub ($ua, $mode) { $ua->${\$get{$mode}}($mock->url_base()."/index") },
    sub ($r) {
      is($r->status_code, 200, 'status code');
      is($r->decoded_content, 'hello', 'decoded content');
    }
  ],[
    'post echo',
    sub ($ua, $mode) { $ua->${\$post{$mode}}($mock->url_base()."/echo", 'the content') },
    sub ($r) {
      is($r->decoded_content, 'the content', 'decoded content');
    }
  ],[
    'get multi header',
    sub ($ua, $mode) { $ua->${\$get{$mode}}($mock->url_base()."/multi-header", 'X-multi' => 'Foo', 'X-multi' => 'Bar', 'X-multi' => 'Baz') },
    sub ($r) {
      is($r->status_code, 200);
    }
  ],[
    'post multi header',
    sub ($ua, $mode) { $ua->${\$post{$mode}}($mock->url_base()."/multi-header", 'X-multi' => 'Foo', 'X-multi' => 'Bar', 'X-multi' => 'Baz') },
    sub ($r) {
      is($r->status_code, 200);
    }
  ],[
    'get content header',
    sub ($ua, $mode) { $ua->${\$get{$mode}}($mock->url_base()."/content-header", 'Content' => 'the content') },
    sub ($r) {
      todo "unimplemented" => sub {
        # In general the UA implementations have some kind of Headers object
        # that they can take to disambiguate between the content and a header
        # called Content.
        is($r->decoded_content, 'the content');
      };
    }
  ],[
    'post content header',
    sub ($ua, $mode) { $ua->${\$post{$mode}}($mock->url_base()."/content-header", 'Content' => 'the content') },
    sub ($r) {
      todo "unimplemented" => sub {
        is($r->decoded_content, 'the content');
      };
    }
  ],
);

sub run ($get_ua, $start_loop = undef, $stop_loop = undef) {
  _start_server();

  subtest_streamed 'sync' => sub {
    for my $t (@tests) {
      my ($name, $req_emiter, $res_processor) = @{$t};
      subtest $name => sub {
        my $r = $req_emiter->($get_ua->(), '');
        $res_processor->($r);
      }
    }
  };

  return unless defined $start_loop;

  subtest_streamed 'callback' => sub {
    for my $t (@tests) {
      my ($name, $req_emiter, $res_processor) = @{$t};
      subtest $name => sub {
        $req_emiter->($get_ua->(), 'cb')->(sub ($r) {
          $res_processor->($r);
          $stop_loop->();
        });
        my $events = $start_loop->();
      }
    }
  };

  subtest_streamed 'promise' => sub {
    for my $t (@tests) {
      my ($name, $req_emiter, $res_processor) = @{$t};
      subtest $name => sub {
        my $p = $req_emiter->($get_ua->(), 'p')->then(sub ($r) { $res_processor->($r); $stop_loop->() });
        $start_loop->();
      }
    }
  };

  _stop_server();
}

1;
