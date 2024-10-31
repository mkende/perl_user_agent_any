package UserAgent::Any::Impl;

use v5.36;

use Moo::Role;

has ua => (
  is => 'ro',
  required => 1,
);

requires qw(get get_cb get_p post post_cb post_p);

sub _get_post_args {
  my $this = shift;
  my $content = pop if @_ % 2;
  my %params = @_;
  return ($this, \$content, \%params);
}

1;
