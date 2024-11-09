package UserAgent::Any::Impl::HttpPromise;

use v5.36;

use HTTP::Promise;
use Moo;
use Promise::Me;

use namespace::clean;

extends 'UserAgent::Any';
with 'UserAgent::Any::Impl';

sub get ($this, $url, @params) {
  my $p = $this->{ua}->get($url, %{UserAgent::Any::Impl::_params_to_hash(@params)})
      ->then(sub { return $_[0] });
  my @r = await($p);
  return $this->_new_response(@r);
}

sub get_cb ($this, $url, @params) {
  return sub ($cb) {
    $this->{ua}->get($url, %{UserAgent::Any::Impl::_params_to_hash(@params)})
      ->then(sub { $cb->($this->_new_response($_[0])) });
    return;
  }
}

sub get_p ($this, $url, @params) {
  return $this->{ua}->get($url, %{UserAgent::Any::Impl::_params_to_hash(@params)})
      ->then(sub { $this->_new_response($_[0]) });
}

sub post {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  my $p = $this->{ua}->post(
    $url,
    %{UserAgent::Any::Impl::_params_to_hash(@{$params})},
    (defined ${$content} ? (Content => ${$content}) : ())
  )->then(sub { return $_[0] });
  my @r = await($p);
  return $this->_new_response(@r);
}

sub post_cb {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return sub ($cb) {
    $this->{ua}->post($url, %{UserAgent::Any::Impl::_params_to_hash(@{$params})},
      (defined ${$content} ? (Content => ${$content}) : ()))
      ->then(sub { $cb->($this->_new_response($_[0])) });
    return;
  }
}

sub post_p {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return $this->{ua}->post($url, %{UserAgent::Any::Impl::_params_to_hash(@{$params})},
  (defined ${$content} ? (Content => ${$content}) : ()))
      ->then(sub { $this->_new_response($_[0]) });
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Impl::HttpPromise

=head1 SYNOPSIS

Implementation of L<UserAgent::Any> for the L<HTTP::Promise> class.
