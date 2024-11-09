package UserAgent::Any::Impl::AnyEventUserAgent;

use v5.36;

use AnyEvent;
use Promise::XS;
use Moo;

use namespace::clean;

extends 'UserAgent::Any';
with 'UserAgent::Any::Impl';

sub get ($this, $url, @params) {
  my $cv = AnyEvent->condvar;
  my $r;
  $this->{ua}->get(
    $url,
    %{UserAgent::Any::Impl::_params_to_hash(@params)},
    sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  return $this->_new_response($r);
}

sub get_cb ($this, $url, @params) {
  return sub ($cb) {
    $this->{ua}->get(
      $url,
      %{UserAgent::Any::Impl::_params_to_hash(@params)},
      sub ($res) { $cb->($this->_new_response($res)) });
    return;
  };
}

sub get_p ($this, $url, @params) {
  my $p = Promise::XS::deferred();
  $this->{ua}->get(
    $url,
    %{UserAgent::Any::Impl::_params_to_hash(@params)},
    sub ($res) { $p->resolve($this->_new_response($res)) });
  return $p->promise();
}

sub post {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  my $cv = AnyEvent->condvar;
  my $r;
  $this->{ua}->post(
    $url,
    %{UserAgent::Any::Impl::_params_to_hash(@{$params})},
    (defined ${$content} ? (Content => ${$content}) : ()),
    sub ($res) { $r = $res; $cv->send });
  $cv->recv;
  return $this->_new_response($r);
}

sub post_cb {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return sub ($cb) {
    $this->{ua}->post(
      $url,
      %{UserAgent::Any::Impl::_params_to_hash(@{$params})},
      (defined ${$content} ? (Content => ${$content}) : ()),
      sub ($res) { $cb->($this->_new_response($res)) });
    return;
  };
}

sub post_p {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  my $p = Promise::XS::deferred();
  $this->{ua}->post(
    $url,
    %{UserAgent::Any::Impl::_params_to_hash(@{$params})},
    (defined ${$content} ? (Content => ${$content}) : ()),
    sub ($res) { $p->resolve($this->_new_response($res)) });
  return $p->promise();
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Impl::AnyEventUserAgent

=head1 SYNOPSIS

Implementation of L<UserAgent::Any> for the L<AnyEvent::UserAgent> class.
