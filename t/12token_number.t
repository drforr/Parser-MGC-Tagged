#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_number( Number => 1 );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_number;
}

package main;

my $parser = TestParser->new;

# We're going to be testing floating point values.
sub approx
{
   my ( $got, $exp, $name ) = @_;

   ok( abs( $got - $exp ) < 1E-12, $name ) or
      diag( "Expected approximately $exp, got $got" );
}

is( $parser->from_string( "123" ), 123, 'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Number => 1 ] ],
  q("123" tags) );
#use YAML;die Dump $parser->{tags};

approx( $parser->from_string( "123.0" ), 123,    'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123.0" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 5, Number => 1 ] ],
  q("123.0" tags) );

approx( $parser->from_string( "0.0" ),     0,    'Zero' );
is_deeply( $parser->{spaces}, { }, q("0.0" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Number => 1 ] ],
  q("0.0" tags) );

approx( $parser->from_string( "12." ),    12,    'Trailing DP' );
is_deeply( $parser->{spaces}, { }, q("12" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Number => 1 ] ],
  q("12." tags) );

approx( $parser->from_string( ".34" ),     0.34, 'Leading DP' );
is_deeply( $parser->{spaces}, { }, q(".34" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Number => 1 ] ],
  q(".34" tags) );

approx( $parser->from_string( "8.9" ),     8.9,  'Infix DP' );
is_deeply( $parser->{spaces}, { }, q("8.9" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Number => 1 ] ],
  q("8.9" tags) );

ok( !eval { $parser->from_string( "hello" ) }, '"hello" fails' );

$parser = TestParser_NoTag->new;

is( $parser->from_string( "123" ), 123, 'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags}, [ ], q("123" tags) );

done_testing;
