#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->sequence_of( sub {
      return $self->token_int( Int => 1 );
   },
   [ Sequence_Of => 1 ] );
}

package IntThenStringParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   [ $self->sequence_of( sub {
         return $self->token_int( Int => 1 );
      },
      [ Sequence_Of => 1 ] ),

      $self->sequence_of( sub {
         return $self->token_string( String => 1 );
      },
      [ Sequence_Of => 1 ] ),
   ];
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;
 
is_deeply( $parser->from_string( "123" ), [ 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Int => 1 ],
    [ 0, 3, Sequence_Of => 1 ] ],
  q("123" tags) );

is_deeply( $parser->from_string( "4 5 6" ), [ 4, 5, 6 ], '"4 5 6"' );
is_deeply( $parser->{spaces},
  { 1 => 2, 3 => 4 },
  q("4 5 6" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Int => 1 ],
    [ 2, 3, Int => 1 ],
    [ 4, 5, Int => 1 ],
    [ 0, 5, Sequence_Of => 1 ] ],
  q("4 5 6" tags) );

is_deeply( $parser->from_string( "" ), [], '""' );
is_deeply( $parser->{spaces}, { }, q("" spaces) );
is_deeply( $parser->{tags}, [ ], q("" tags) );

$parser = IntThenStringParser->new;

is_deeply( $parser->from_string( "10 20 'ab' 'cd'" ),
           [ [ 10, 20 ], [ 'ab', 'cd' ] ], q("10 20 'ab' 'cd'") );
is_deeply( $parser->{spaces},
  { 2 => 3, 5 => 6, 10 => 11 },
  q("10 20 'ab' 'cd'" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 2, Int => 1 ],
    [ 3, 5, Int => 1 ],
    [ 0, 5, Sequence_Of => 1 ],
    [ 5, 10, String => 1 ],
    [ 10, 15, String => 1 ],
    [ 5, 15, Sequence_Of => 1 ] ],
  q("10 20 'ab' 'cd'" tags) );

is_deeply( $parser->from_string( "10 20" ),
           [ [ 10, 20 ], [] ], q("10 20") );
is_deeply( $parser->{spaces},
  { 2 => 3 },
  q("10 20" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 2, Int => 1 ],
    [ 3, 5, Int => 1 ],
    [ 0, 5, Sequence_Of => 1 ] ],
  q("10 20" tags) );

is_deeply( $parser->from_string( "'ab' 'cd'" ),
           [ [], [ 'ab', 'cd' ] ], q("'ab' 'cd'") );
is_deeply( $parser->{spaces},
  { 4 => 5 },
  q("'ab' 'cd'" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 4, String => 1 ],
    [ 4, 9, String => 1 ],
    [ 0, 9, Sequence_Of => 1 ] ],
  q("'ab' 'cd'" tags) );

done_testing;
