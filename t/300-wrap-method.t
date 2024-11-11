use 5.036;

use AnyEvent;
use Encode 'encode';
use Test2::V0 -target => 'UserAgent::Any';

package TestSubject {
  use AnyEvent::Loop;
  use AnyEvent;
  use Moo;
  use Promise::XS;
  use UserAgent::Any 'wrap_method';

  sub foo ($self, $l, $r, $c = 1) {
    return ($l + $r) x $c;
  }

  sub foo_cb ($self, $l, $r, $c = 1) {
    return sub ($cb) {
      my $i;
      $i = AnyEvent->idle(cb => sub { undef $i; $cb->($self->foo($l, $r, $c)) });
    };
  }

  sub foo_p ($self, $l, $r, $c = 1) {
    my $p = Promise::XS::deferred();
    my $i;
    $i = AnyEvent->idle(cb => sub { undef $i; $p->resolve($self->foo($l, $r, $c)) });
    return $p->promise();
  }

  wrap_method(bar => 'foo', sub ($self, $l, $r) { ($l * 10, $r * 5) });
  wrap_method(rebar => 'foo', sub ($self, $l, $r) { ($l, $r) }, sub ($self, $res, $l, $r) { return $res * 2 + $l + $r});
  wrap_method(countbar => 'foo', sub ($self, $l, $r, $c) { ($l, $r, $c) }, sub ($self, $res, @) { return $res });
};

my $test = TestSubject->new();

is($test->foo(1, 2), 3, 'foo');
is($test->bar(1, 2), 20, 'bar');
is($test->rebar(1, 2), 9, 'rebar');
is([$test->countbar(1, 2, 0)], [undef], 'count 0');
is([$test->countbar(1, 2, 1)], [3], 'count 1');
is($test->countbar(1, 2, 2), [3, 3], 'count 2');

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $test->foo_cb(1, 2)->(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 3, 'foo_cb');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $test->bar_cb(1, 2)->(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 20, 'bar_cb');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $test->rebar_cb(1, 2)->(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 9, 'rebar_cb');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $test->foo_p(1, 2)->then(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 3, 'foo_p');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $test->bar_p(1, 2)->then(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 20, 'bar_p');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $test->rebar_p(1, 2)->then(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 9, 'rebar_p');
}

done_testing;
