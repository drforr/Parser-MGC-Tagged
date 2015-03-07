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
      return $self->token_int;
   } );
}

package IntThenStringParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   [ $self->sequence_of( sub {
         return $self->token_int;
      } ),

      $self->sequence_of( sub {
         return $self->token_string;
      } ),
   ];
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;
 
is_deeply( $parser->from_string( "123" ), [ 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->from_string( "4 5 6" ), [ 4, 5, 6 ], '"4 5 6"' );
is_deeply( $parser->{spaces},
  { 1 => 2, 3 => 4 },
  q("4 5 6" spaces) );

is_deeply( $parser->from_string( "" ), [], '""' );
is_deeply( $parser->{spaces}, { }, q("" spaces) );

$parser = IntThenStringParser->new;

is_deeply( $parser->from_string( "10 20 'ab' 'cd'" ),
           [ [ 10, 20 ], [ 'ab', 'cd' ] ], q("10 20 'ab' 'cd'") );
is_deeply( $parser->{spaces},
  { 2 => 3, 5 => 6, 10 => 11 },
  q("10 20 'ab' 'cd'" spaces) );

is_deeply( $parser->from_string( "10 20" ),
           [ [ 10, 20 ], [] ], q("10 20") );
is_deeply( $parser->{spaces},
  { 2 => 3 },
  q("10 20" spaces) );

is_deeply( $parser->from_string( "'ab' 'cd'" ),
           [ [], [ 'ab', 'cd' ] ], q("'ab' 'cd'") );
is_deeply( $parser->{spaces},
  { 4 => 5 },
  q("'ab' 'cd'" spaces) );

done_testing;
