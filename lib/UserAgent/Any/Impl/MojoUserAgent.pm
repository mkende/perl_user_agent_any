package UserAgent::Any::Impl::MojoUserAgent;

use v5.36;

use List::Util 'pairs';
use Moo;

use namespace::clean;

extends 'UserAgent::Any';
with 'UserAgent::Any::Impl';

sub _params_to_hash (@params) {
  my %hash;
  for my $kv (pairs @params) {
    push @{$hash{$kv->key}}, $kv->value;
  }
  return \%hash;
}

sub get ($this, $url, @params) {
  return $this->_new_response($this->{ua}->get($url, _params_to_hash(@params))->res);
}

sub get_cb ($this, $url, @params) {
  return sub {
    my ($cb) = @_;
    $this->{ua}->get($url, _params_to_hash(@params), sub ($, $tx) { $cb->($this->_new_response($tx->res)) });
    return;
  };
}

sub get_p ($this, $url, @params) {
  return $this->{ua}->get_p($url, _params_to_hash(@params))->then(sub ($tx) { $this->_new_response($tx->res) });
}

sub post {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return $this->_new_response($this->{ua}->post($url, _params_to_hash(@{$params}), (defined ${$content} ? ${$content} : ()))->res);
}

sub post_cb {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return sub {
    my ($cb) = @_;
    $this->{ua}->post(
      $url, _params_to_hash(@{$params}), (defined ${$content} ? ${$content} : ()), sub ($, $tx) { $cb->($this->_new_response($tx->res)) });
    return;
  };
}

sub post_p {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return $this->{ua}->post_p($url, _params_to_hash(@{$params}), (defined ${$content} ? ${$content} : ()))
      ->then(sub ($tx) { $this->_new_response($tx->res) });
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Impl::MojoUserAgent

=head1 SYNOPSIS

Implementation of L<UserAgent::Any> for the L<Mojo::UserAgent> class.
