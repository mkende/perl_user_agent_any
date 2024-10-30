package UserAgent::Any::Response::Impl;

use strict;
use warnings;
use v5.36;
use utf8;

use Moo::Role;

has res => (
  is => 'ro',
  required => 1,
);

requires qw(status_code status_text content decoded_content headers header);

1;
