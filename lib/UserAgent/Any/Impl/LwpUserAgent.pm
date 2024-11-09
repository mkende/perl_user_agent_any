package UserAgent::Any::Impl::LwpUserAgent;

use 5.036;

use Carp;
use Moo;

use namespace::clean;

extends 'UserAgent::Any';
with 'UserAgent::Any::Impl';

our $VERSION = 0.01;

sub get ($this, $url, @params) {
  return $this->new_response($this->{ua}->get($url, @params));
}

sub get_cb ($this, $url, @params) {
  croak 'UserAgent::Any async methods are not implemented with LWP::UserAgent';
}

sub get_p ($this, $url, @params) {
  croak 'UserAgent::Any async methods are not implemented with LWP::UserAgent';
}

sub post {
  my ($this, $url, $content, $params) = &UserAgent::Any::Impl::get_post_args;
  return $this->new_response(
    $this->{ua}->post($url, @{$params}, (defined ${$content} ? (Content => ${$content}) : ())));
}

sub post_cb ($this, $url, %params) {
  croak 'UserAgent::Any async methods are not implemented with LWP::UserAgent';
}

sub post_p ($this, $url, %params) {
  croak 'UserAgent::Any async methods are not implemented with LWP::UserAgent';
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Impl::LwpUserAgent

=head1 SYNOPSIS

Implementation of L<UserAgent::Any> for the L<LWP::UserAgent> class.
