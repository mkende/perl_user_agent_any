use strict;
use warnings;
use utf8;

use Encode 'encode';
use Test2::V0 -target => 'UserAgent::Any';

my $fake = bless {}, 'UserAgent::Any';

my $r = CLASS()->new($fake);

isa_ok($r, ['UserAgent::Any']);

is($r, exact_ref($fake), 'passthrough constructor');

done_testing;
