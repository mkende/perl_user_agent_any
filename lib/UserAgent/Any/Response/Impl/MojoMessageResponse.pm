package UserAgent::Any::Response::Impl::MojoMessageResponse;

use v5.36;

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
  return $this->{res}->body;
}

sub decoded_content ($this) {
  return $this->{res}->text;
}

sub headers ($this) {
  return map { my $k = $_; map { ($k, $_) } $this->header($k) } @{$this->{res}->headers->names};
}

sub header ($this, $header) {
  return @{$this->{res}->headers->every_header($header)} if wantarray;
  return $this->{res}->headers->header($header);
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

UserAgent::Any::Response::Impl::MojoMessageResponse

=head1 SYNOPSIS

Implementation of L<UserAgent::Any::Response> for the L<Mojo::Message::Response>
class.
