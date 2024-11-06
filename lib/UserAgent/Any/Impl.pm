package UserAgent::Any::Impl;

use v5.36;

use List::Util 'pairs';
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
  return ($this, $url, \$content, \@_);
}

sub _new_response {
  my (undef, $r) = @_;  # The undef is $this that we are not using.
  return UserAgent::Any::Response->new($r);
}

sub _params_to_hash (@params) {
  my %hash;
  for my $kv (pairs @params) {
    my $v = $hash{$kv->key};
    if (defined $v) {
      if (ref($v)) {
        push @{$v}, $kv->value;
      } else {
        $hash{$kv->key} = [$v, $kv->value];
      }
    } else {
      $hash{$kv->key} = $kv->value;
    }
  }
  return \%hash;
}

1;
