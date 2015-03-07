#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   my @tokens;
   push @tokens, $self->expect( qr/[a-z]+/ ) while !$self->at_eos;

   return \@tokens;
}

package main;
#$ENV{DEBUG}=1;

my $parser = TestParser->new;

my @strings = (
   "here is a list ",
   "of some more ",
   "tokens"
);

is_deeply( $parser->from_reader( sub { return shift @strings } ),
   [qw( here is a list of some more tokens )],
   'tokens from reader' );
is_deeply( $parser->{spaces},
  { 4 => 5, 7 => 8, 9 => 10, # "here is a list "
    14 => 15, 17 => 18, 22 => 23, 27 => 28 # "of some more "
  },
  q("here is a list", "of some more ", "tokens" spaces) );

done_testing;
