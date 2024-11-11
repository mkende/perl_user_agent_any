package UserAgent::Any::Impl;

use 5.036;

use List::Util 'pairs';
use Moo;
use UserAgent::Any::Response;

use namespace::clean;

our $VERSION = 0.01;

sub get_post_args {  ## no critic (RequireArgUnpacking)
  my ($this, $url) = (shift, shift);
  my $content;
  $content = pop if @_ % 2;
  return ($this, $url, \$content, \@_);
}

sub new_response {
  my (undef, $r) = @_;  # The undef is $this that we are not using.
  return UserAgent::Any::Response->new($r);
}

sub params_to_hash (@params) {
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
