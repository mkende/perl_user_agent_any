package UserAgent::Any::Impl::AnyEventUserAgent;

use v5.36;

use Moo;

use namespace::clean;

extends 'UserAgent::Any';
with 'UserAgent::Any::Impl';

sub get ($this, $url, @params) {
  return $this->_new_response($this->{ua}->get($url, \@params)->res);
}

sub get_cb ($this, $url, @params) {
  return sub {
    my ($cb) = @_;
    $this->{ua}->get($url, \@params, sub ($res) { $cb->($this->_new_response($res)) });
    return;
  };
}

sub get_p ($this, $url, @params) {
  return $this->{ua}->get_p($url, \@params)->then(sub ($tx) { $this->_new_response($tx->res) });
}

sub post {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return $this->_new_response($this->{ua}->post($url, $params, (defined ${$content} ? (Content => ${$content}) : ()))->res);
}

sub post_cb {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return sub {
    my ($cb) = @_;
    $this->{ua}->post(
      $url, $params, (defined ${$content} ? (Content => ${$content}) : ()), sub ($res) { $cb->($this->_new_response($res)) });
    return;
  };
}

sub post_p {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return $this->{ua}->post_p($url, $params, (defined ${$content} ? (Content => ${$content}) : ()))
      ->then(sub ($tx) { $this->_new_response($tx->res) });
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Impl::AnyEventUserAgent

=head1 SYNOPSIS

Implementation of L<UserAgent::Any> for the L<AnyEvent::UserAgent> class.
