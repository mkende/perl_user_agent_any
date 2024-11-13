package UserAgent::Any::Impl;

use 5.036;

use Exporter 'import';
use List::Util 'pairs';
use Moo;
use UserAgent::Any::Response;

use namespace::clean -except => ['import'];

our @EXPORT_OK = qw(get_call_args generate_methods new_response);

our $VERSION = 0.01;

sub get_call_args {  ## no critic (RequireArgUnpacking)
  my ($this, $method, $url) = (shift, shift, shift);
  my $content;
  $content = pop if @_ % 2;
  return ($this, $method, $url, \@_, \$content,);
}

sub generate_methods {
  my $dest_pkg = caller(0);

  my @methods = qw(get post delete);

  for my $m (@methods) {
    no strict 'refs';  ## no critic (ProhibitNoStrict)
    *{"${dest_pkg}::${m}"} = sub ($this, @args) { $this->call($m, @args) };
    *{"${dest_pkg}::${m}_cb"} = sub ($this, @args) { $this->call_cb($m, @args) };
    *{"${dest_pkg}::${m}_p"} = sub ($this, @args) { $this->call_p($m, @args) };
  }
  return;
}

sub new_response {
  my ($r) = @_;  # The undef is $this that we are not using.
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
