use 5.036;

use AnyEvent;
use Encode 'encode';
use Test2::V0;

# We first test the wrap_method directly calling a class method.

package TestSubject {
  use AnyEvent::Loop;
  use AnyEvent;
  use Moo;
  use Promise::XS;
  use UserAgent::Any::Wrapper 'wrap_method';

  sub foo ($self, $l, $r, $c = 1) {
    return ($l + $r) x $c;
  }

  sub foo_cb ($self, $l, $r, $c = 1) {
    return sub ($cb) {
      my $i;
      $i = AnyEvent->idle(cb => sub { undef $i; $cb->(foo($self, $l, $r, $c)) });
    };
  }

  sub foo_p ($self, $l, $r, $c = 1) {
    my $p = Promise::XS::deferred();
    my $i;
    $i = AnyEvent->idle(cb => sub { undef $i; $p->resolve(foo($self, $l, $r, $c)) });
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

# Now we test the wrap_method calling a method of a member of the class.

package TestDerived {
  use Moo;
  use UserAgent::Any::Wrapper 'wrap_method', 'wrap_method_sets';

  has subject => (is => 'rw');

  wrap_method(hop => \&subject => 'foo', sub ($self, $l, $r) { ($l, $r) });
  wrap_method(rehop => \&subject => 'foo', sub ($self, $l, $r) { ($l, $r) }, sub ($self, $res, @) { return $res + 1 });
  wrap_method_sets(['foo'], \&subject, sub ($self, $l, $r) { ($l, $r + 2) });
}

my $derived = TestDerived->new(subject => $test);

is($derived->hop(1, 2), 3, 'hop');
is($derived->rehop(1, 2), 4, 'rehop');
is($derived->foo(1, 2), 5, 'foohop');

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $derived->hop_cb(1, 2)->(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 3, 'hop_cb');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $derived->rehop_cb(1, 2)->(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 4, 'rehop_cb');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $derived->foo_cb(1, 2)->(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 5, 'foohop_cb');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $derived->hop_p(1, 2)->then(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 3, 'hop_p');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $derived->rehop_p(1, 2)->then(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 4, 'rehop_p');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $derived->foo_p(1, 2)->then(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 5, 'foohop_p');
}

# Now we test the wrap_method calling a method of a member of the class.

package TestDerived2 {
  use Moo;
  use UserAgent::Any::Wrapper 'wrap_method_sets';

  extends 'TestSubject';

  wrap_method_sets(['foo'], 'TestSubject', sub ($self, $l, $r) { ($l, $r + 3) });
}

my $derived2 = TestDerived2->new();

is($derived2->foo(1, 2), 6, 'basehop');

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $derived2->foo_cb(1, 2)->(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 6, 'basehop_cb');
}

{
  my $r = 0;
  my $cv = AnyEvent->condvar;
  $derived2->foo_p(1, 2)->then(sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  is($r, 6, 'basehop_p');
}

done_testing;
