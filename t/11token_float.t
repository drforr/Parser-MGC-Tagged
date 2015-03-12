#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_float( Float => 1 );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_float;
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

approx( $parser->from_string( "123.0" ), 123,    'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123.0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123.0" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("123.0" tag start) );
  is( $tagged->get_tag_at( 4, 'Float' ), 1, q("123.0" tag end) );
}

approx( $parser->from_string( "0.0" ),     0,    'Zero' );
is_deeply( $parser->{spaces}, { }, q("0.0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("0.0" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("0.0" tag start) );
  is( $tagged->get_tag_at( 2, 'Float' ), 1, q("0.0" tag end) );
}

approx( $parser->from_string( "12." ),    12,    'Trailing DP' );
is_deeply( $parser->{spaces}, { }, q("12." spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("12." tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("12." tag start) );
  is( $tagged->get_tag_at( 2, 'Float' ), 1, q("12." tag end) );
}

approx( $parser->from_string( ".34" ),     0.34, 'Leading DP' );
is_deeply( $parser->{spaces}, { }, q(".34" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(".34" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q(".34" tag start) );
  is( $tagged->get_tag_at( 2, 'Float' ), 1, q(".34" tag end) );
}

approx( $parser->from_string( "8.9" ),     8.9,  'Infix DP' );
is_deeply( $parser->{spaces}, { }, q("8.9" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("8.9" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("8.9" tag start) );
  is( $tagged->get_tag_at( 2, 'Float' ), 1, q("8.9" tag end) );
}

approx( $parser->from_string( "-4.0" ),   -4,    'Negative decimal' );
is_deeply( $parser->{spaces}, { }, q("-4.0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("-4.0" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("-4.0" tag start) );
  is( $tagged->get_tag_at( 3, 'Float' ), 1, q("-4.0" tag end) );
}

approx( $parser->from_string( "1E0" ),     1, 'Scientific without DP' );
is_deeply( $parser->{spaces}, { }, q("1E0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("1E0" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("1E0" tag start) );
  is( $tagged->get_tag_at( 2, 'Float' ), 1, q("1E0" tag end) );
}

approx( $parser->from_string( "2.0E0" ),   2, 'Scientific with DP' );
is_deeply( $parser->{spaces}, { }, q("2.0E0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("2.0E0" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("2.0E0" tag start) );
  is( $tagged->get_tag_at( 4, 'Float' ), 1, q("2.0E0" tag end) );
}

approx( $parser->from_string( "3.E0" ),    3, 'Scientific with trailing DP' );
is_deeply( $parser->{spaces}, { }, q("3.E0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("3.E0" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("3.E0" tag start) );
  is( $tagged->get_tag_at( 3, 'Float' ), 1, q("3.E0" tag end) );
}

approx( $parser->from_string( ".4E1" ),    4, 'Scientific with leading DP' );
is_deeply( $parser->{spaces}, { }, q(".4E1" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(".4E1" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q(".4E1" tag start) );
  is( $tagged->get_tag_at( 3, 'Float' ), 1, q(".4E1" tag end) );
}

approx( $parser->from_string( "50E-1" ),   5, 'Scientific with negative exponent without DP' );
is_deeply( $parser->{spaces}, { }, q("50E-1" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("50E-1" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("50E-1" tag start) );
  is( $tagged->get_tag_at( 4, 'Float' ), 1, q("50E-1" tag end) );
}

approx( $parser->from_string( "60.0E-1" ), 6, 'Scientific with DP with negative exponent' );
is_deeply( $parser->{spaces}, { }, q("60.0E-1" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("60.0E-1" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("60.0E-1" tag start) );
  is( $tagged->get_tag_at( 6, 'Float' ), 1, q("60.0E-1" tag end) );
}

approx( $parser->from_string( "1e0" ), 1, 'Scientific with lowercase e' );
is_deeply( $parser->{spaces}, { }, q("1e0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("1e0" tagged) );
  is( $tagged->get_tag_at( 0, 'Float' ), 1, q("1e0" tag start) );
  is( $tagged->get_tag_at( 2, 'Float' ), 1, q("1e0" tag end) );
}

$parser = TestParser_NoTag->new;

approx( $parser->from_string( "123.0" ), 123,    'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123.0" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("123.0" tags) );

done_testing;
