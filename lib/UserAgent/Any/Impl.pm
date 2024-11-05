package UserAgent::Any::Impl;

use v5.36;

use Moo::Role;
use UserAgent::Any::Response;

use namespace::clean;

has ua => (
  is => 'ro',
  required => 1,
);

requires qw(get get_cb get_p post post_cb post_p);

sub _get_post_args {
  my ($this, $url) = (shift, shift);
  my $content = pop if @_ % 2;
  my %params = @_;
  return ($this, $url, \$content, \%params);
}

sub _new_response {
  my (undef, $r) = @_;  # The undef is $this that we are not using.
  return UserAgent::Any::Response->new($r);
}

1;
