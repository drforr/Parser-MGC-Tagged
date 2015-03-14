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
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123" tagged) );
  is( $tagged->get_tag_at( 0, 'Number' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'Number' ), 1, q("123" tag end) );
}
#use YAML;die Dump $parser->{tags};

approx( $parser->from_string( "123.0" ), 123,    'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123.0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123.0" tagged) );
  is( $tagged->get_tag_at( 0, 'Number' ), 1, q("123.0" tag start) );
  is( $tagged->get_tag_at( 4, 'Number' ), 1, q("123.0" tag end) );
}


approx( $parser->from_string( "0.0" ),     0,    'Zero' );
is_deeply( $parser->{spaces}, { }, q("0.0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("0.0" tagged) );
  is( $tagged->get_tag_at( 0, 'Number' ), 1, q("0.0" tag start) );
  is( $tagged->get_tag_at( 2, 'Number' ), 1, q("0.0" tag end) );
}

approx( $parser->from_string( "12." ),    12,    'Trailing DP' );
is_deeply( $parser->{spaces}, { }, q("12" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("12." tagged) );
  is( $tagged->get_tag_at( 0, 'Number' ), 1, q("12." tag start) );
  is( $tagged->get_tag_at( 2, 'Number' ), 1, q("12." tag end) );
}

approx( $parser->from_string( ".34" ),     0.34, 'Leading DP' );
is_deeply( $parser->{spaces}, { }, q(".34" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Number => 1 ] ],
  q(".34" tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(".34" tagged) );
  is( $tagged->get_tag_at( 0, 'Number' ), 1, q(".34" tag start) );
  is( $tagged->get_tag_at( 2, 'Number' ), 1, q(".34" tag end) );
}

approx( $parser->from_string( "8.9" ),     8.9,  'Infix DP' );
is_deeply( $parser->{spaces}, { }, q("8.9" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Number => 1 ] ],
  q("8.9" tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("8.9" tagged) );
  is( $tagged->get_tag_at( 0, 'Number' ), 1, q("8.9" tag start) );
  is( $tagged->get_tag_at( 2, 'Number' ), 1, q("8.9" tag end) );
}

ok( !eval { $parser->from_string( "hello" ) }, '"hello" fails' );

$parser = TestParser_NoTag->new;

is( $parser->from_string( "123" ), 123, 'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("123" tags) );

done_testing;
