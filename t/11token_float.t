#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_float;
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

# We're going to be testing floating point values.
sub approx
{
   my ( $got, $exp, $name ) = @_;

   ok( abs( $got - $exp ) < 1E-12, $name ) or
      diag( "Expected approximately $exp, got $got" );
}

approx( $parser->from_string( "123.0" ), 123,    'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123.0" spaces) );
approx( $parser->from_string( "0.0" ),     0,    'Zero' );
is_deeply( $parser->{spaces}, { }, q("0.0" spaces) );
approx( $parser->from_string( "12." ),    12,    'Trailing DP' );
is_deeply( $parser->{spaces}, { }, q("12" spaces) );
approx( $parser->from_string( ".34" ),     0.34, 'Leading DP' );
is_deeply( $parser->{spaces}, { }, q(".34" spaces) );
approx( $parser->from_string( "8.9" ),     8.9,  'Infix DP' );
is_deeply( $parser->{spaces}, { }, q("8.9" spaces) );

approx( $parser->from_string( "-4.0" ),   -4,    'Negative decimal' );
is_deeply( $parser->{spaces}, { }, q("-4.0" spaces) );

approx( $parser->from_string( "1E0" ),     1, 'Scientific without DP' );
is_deeply( $parser->{spaces}, { }, q("1E0" spaces) );
approx( $parser->from_string( "2.0E0" ),   2, 'Scientific with DP' );
is_deeply( $parser->{spaces}, { }, q("2.0E0" spaces) );
approx( $parser->from_string( "3.E0" ),    3, 'Scientific with trailing DP' );
is_deeply( $parser->{spaces}, { }, q("3.E0" spaces) );
approx( $parser->from_string( ".4E1" ),    4, 'Scientific with leading DP' );
is_deeply( $parser->{spaces}, { }, q(".4E1" spaces) );
approx( $parser->from_string( "50E-1" ),   5, 'Scientific with negative exponent without DP' );
is_deeply( $parser->{spaces}, { }, q("50E-1" spaces) );
approx( $parser->from_string( "60.0E-1" ), 6, 'Scientific with DP with negative exponent' );
is_deeply( $parser->{spaces}, { }, q("60.0E-1" spaces) );

approx( $parser->from_string( "1e0" ), 1, 'Scientific with lowercase e' );
is_deeply( $parser->{spaces}, { }, q("1e0" spaces) );

done_testing;
