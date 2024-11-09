package UserAgent::Any::Response::Impl::MojoMessageResponse;

use 5.036;

use Moo;

use namespace::clean;

extends 'UserAgent::Any::Response';
with 'UserAgent::Any::Response::Impl';

our $VERSION = 0.01;

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
  my @all_headers;
  for my $k (@{$this->{res}->headers->names}) {
    push @all_headers, map { ($k, $_) } $this->header($k);
  }
  return @all_headers;
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
