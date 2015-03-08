#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->list_of( ",", sub {
      return $self->token_int( Int => 1 );
   },
   [ List_Of => 1 ] );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is_deeply( $parser->from_string( "123" ), [ 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Int => 1 ], [ 0, 3, List_Of => 1 ] ],
  q("123" tags) );

is_deeply( $parser->from_string( "4,5,6" ), [ 4, 5, 6 ], '"4,5,6"' );
is_deeply( $parser->{spaces}, { }, q("4,5,6" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Int => 1 ],
    [ 2, 3, Int => 1 ],
    [ 4, 5, Int => 1 ],
    [ 0, 5, List_Of => 1 ] ],
  q("4,5,6" tags) );

is_deeply( $parser->from_string( "7, 8" ), [ 7, 8 ], '"7, 8"' );
is_deeply( $parser->{spaces},
  { 2 => 3 },
  q("7, 8" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Int => 1 ],
    [ 2, 4, Int => 1 ],
    [ 0, 4, List_Of => 1 ] ],
  q("7, 8" tags) );

done_testing;
