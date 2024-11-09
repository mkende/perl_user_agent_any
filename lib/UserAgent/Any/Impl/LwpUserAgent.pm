package UserAgent::Any::Impl::LwpUserAgent;

use v5.36;

use Moo;

use namespace::clean;

extends 'UserAgent::Any';
with 'UserAgent::Any::Impl';

sub get ($this, $url, @params) {
  return $this->_new_response($this->{ua}->get($url, @params));
}

sub get_cb ($this, $url, @params) {
  ...;
}

sub get_p ($this, $url, @params) {
  ...;
}

sub post {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::_get_post_args;
  return $this->_new_response(
    $this->{ua}->post($url, @{$params}, (defined ${$content} ? (Content => ${$content}) : ())));
}

sub post_cb ($this, $url, %params) {
  ...;
}

sub post_p ($this, $url, %params) {
  ...;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Impl::LwpUserAgent

=head1 SYNOPSIS

Implementation of L<UserAgent::Any> for the L<LWP::UserAgent> class.
