use strict;
use warnings;
use utf8;

use v5.36;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test2::V0 -target => 'UserAgent::Any';
use TestSuite;  # From our the t/lib directory.

BEGIN {
  eval 'use AnyEvent::UserAgent';  ## no critic (ProhibitStringyEval, RequireCheckingReturnValueOfEval)
  skip_all('AnyEvent::UserAgent is not installed') if $@;
  eval 'use Promise::XS';  ## no critic (ProhibitStringyEval, RequireCheckingReturnValueOfEval)
  skip_all('Promise::XS is not installed') if $@;
  eval 'use AnyEvent';  ## no critic (ProhibitStringyEval, RequireCheckingReturnValueOfEval)
  skip_all('AnyEvent is not installed') if $@;
}

sub get_ua {
  my $underlying_ua = AnyEvent::UserAgent->new();
  return UserAgent::Any->new($underlying_ua);
}

my $cv;
TestSuite::run(\&get_ua, sub { $cv = AnyEvent->condvar; $cv->recv }, sub { $cv->send });

done_testing;
