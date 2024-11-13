package UserAgent::Any::Impl::MojoUserAgent;

use 5.036;

use Moo;

use namespace::clean;

with 'UserAgent::Any';
extends 'UserAgent::Any::Impl';

our $VERSION = 0.01;

sub get ($this, $url, @params) {
  return $this->new_response(
    $this->{ua}->get($url, UserAgent::Any::Impl::params_to_hash(@params))->res);
}

sub get_cb ($this, $url, @params) {
  return sub ($cb) {
    $this->{ua}->get(
      $url,
      UserAgent::Any::Impl::params_to_hash(@params),
      sub ($, $tx) { $cb->($this->new_response($tx->res)) });
    return;
  };
}

sub get_p ($this, $url, @params) {
  return $this->{ua}->get_p($url, UserAgent::Any::Impl::params_to_hash(@params))
      ->then(sub ($tx) { $this->new_response($tx->res) });
}

sub post {
  my ($this, $url, $params, $content) = &UserAgent::Any::Impl::get_post_args;
  return $this->new_response(
    $this->{ua}->post(
      $url,
      UserAgent::Any::Impl::params_to_hash(@{$params}),
      (defined ${$content} ? ${$content} : ())
    )->res);
}

sub post_cb {
  my ($this, $url, $params, $content) = &UserAgent::Any::Impl::get_post_args;
  return sub ($cb) {
    $this->{ua}->post(
      $url,
      UserAgent::Any::Impl::params_to_hash(@{$params}),
      (defined ${$content} ? ${$content} : ()),
      sub ($, $tx) { $cb->($this->new_response($tx->res)) });
    return;
  };
}

sub post_p {
  my ($this, $url, $params, $content) = &UserAgent::Any::Impl::get_post_args;
  return $this->{ua}->post_p(
    $url,
    UserAgent::Any::Impl::params_to_hash(@{$params}),
    (defined ${$content} ? ${$content} : ())
  )->then(sub ($tx) { $this->new_response($tx->res) });
}

sub delete ($this, $url, @params) {
  return $this->new_response(
    $this->{ua}->delete($url, UserAgent::Any::Impl::params_to_hash(@params))->res);
}

sub delete_cb ($this, $url, @params) {
  return sub ($cb) {
    $this->{ua}->delete(
      $url,
      UserAgent::Any::Impl::params_to_hash(@params),
      sub ($, $tx) { $cb->($this->new_response($tx->res)) });
    return;
  };
}

sub delete_p ($this, $url, @params) {
  return $this->{ua}->delete_p($url, UserAgent::Any::Impl::params_to_hash(@params))
      ->then(sub ($tx) { $this->new_response($tx->res) });
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Impl::MojoUserAgent

=head1 SYNOPSIS

Implementation of L<UserAgent::Any> for the L<Mojo::UserAgent> class.
