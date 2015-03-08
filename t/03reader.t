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
   push @tokens, $self->expect( qr/[a-z]+/, [ Expect => 1 ] ) while !$self->at_eos;

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
is_deeply( $parser->{tags},
  [ [ 0, 4, Expect => 1 ],
    [ 4, 7, Expect => 1 ],
    [ 7, 9, Expect => 1 ],
    [ 9, 14, Expect => 1 ], # "here is a list "
    [ 14, 17, Expect => 1 ],
    [ 17, 22, Expect => 1 ],
    [ 22, 27, Expect => 1 ], # "of some more "
    [ 27, 34, Expect => 1 ], # "tokens"
  ],
  q("here is a list", "of some more ", "tokens" tags) );

done_testing;
