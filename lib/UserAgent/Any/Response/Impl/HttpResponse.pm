package UserAgent::Any::Response::Impl::HttpResponse;

use strict;
use warnings;
use v5.36;
use utf8;

use Moo;

use namespace::clean;

extends 'UserAgent::Any::Response';
with 'UserAgent::Any::Response::Impl';

sub status_code ($this) {
  return $this->{res}->code;
}

sub status_text ($this) {
  return $this->{res}->message;
}

sub content ($this) {
  return $this->{res}->content;
}

sub decoded_content ($this) {
  return $this->{res}->decoded_content;
}

sub headers ($this) {
  return $this->{res}->flatten();
}

sub header ($this, $header) {
  return $this->{res}->header($header);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Response::Impl::HttpResponse

=head1 SYNOPSIS

Implementation of L<UserAgent::Any::Response> for the L<HTTP::Response> class.
