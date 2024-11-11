package TestSuite;

use strict;
use warnings;
use utf8;

use 5.036;

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
    } elsif ($req->uri->path eq '/get-method') {
      $res->content($req->method);
    } elsif ($req->uri->path eq '/echo' && $req->method eq 'POST') {
      $res->content($req->content);
    } elsif ($req->uri->path eq '/multi-header' and $req->header('X-multi') eq 'Foo, Bar, Baz') {
      # return OK
    } elsif ($req->uri->path eq '/content-header') {
      $res->content($req->header('Content'));
    } else {
      print STDERR Dumper($req);
      die sprintf "unexpected call %s %s", $req->method, $req->uri->path;
    }
  });
}

sub _stop_server {
  $mock->stop_mock_server();
}

my %get = ('' => 'get', 'cb' => 'get_cb', 'p' => 'get_p');
my %post = ('' => 'post', 'cb' => 'post_cb', 'p' => 'post_p');

my @tests = (
  [
    'get index',
    sub ($ua, $mode) { $ua->${\$get{$mode}}($mock->url_base()."/index") },
    sub ($r) {
      is($r->status_code, 200, 'status code');
      is($r->decoded_content, 'hello', 'decoded content');
    }
  ],[
    'get',
    sub ($ua, $mode) { $ua->${\$get{$mode}}($mock->url_base()."/get-method") },
    sub ($r) {
      is($r->decoded_content, 'GET');
    }
  ],[
    'post',
    sub ($ua, $mode) { $ua->${\$post{$mode}}($mock->url_base()."/get-method") },
    sub ($r) {
      is($r->decoded_content, 'POST');
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

  my @runner = (
    ['sync', '', sub ($req, $proc) { $proc->($req) } ],
    ['callback', 'cb', sub ($req, $proc) {
      $req->(sub ($r) {
          $proc->($r);
          $stop_loop->();
        });
        $start_loop->();
    } ],
    ['promise', 'p', sub ($req, $proc) {
      $req->then(sub ($r) { $proc->($r); $stop_loop->() });
        $start_loop->();
    } ]
  );

  my $ua = $get_ua->();

  for my $run (@runner) {
    my ($run_name, $suffix, $handler) = @{$run};
    next if $run_name ne 'sync'; # && !defined $start_loop;
    subtest_streamed $run_name, {no_fork => 1} => sub {
      for my $t (@tests) {
        my ($test_name, $req_emiter, $res_processor) = @{$t};
        subtest $test_name, {no_fork => 1} => sub {
          my $r = $req_emiter->($ua, $suffix);
          $handler->($r, $res_processor);
        }
      }
    }
  }

  _stop_server();
}

1;
