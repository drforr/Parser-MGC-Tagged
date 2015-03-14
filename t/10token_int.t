#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  return $self->token_int( Int => 1 );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  return $self->token_int;
}

package main;

my $parser = TestParser->new;

is( $parser->from_string( "123" ), 123, 'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Int => 1 ] ],
  q("123" tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("123" tag end) );
}

is( $parser->from_string( "0" ),     0, 'Zero' );
is_deeply( $parser->{spaces}, { }, q("0" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("0" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("0" tag start) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("0" tag end) );
}

is( $parser->from_string( "0x20" ), 32, 'Hexadecimal integer' );
is_deeply( $parser->{spaces}, { }, q("0x20" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("0x20" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("0x20" tag start) );
  is( $tagged->get_tag_at( 3, 'Int' ), 1, q("0x20" tag end) );
}

is( $parser->from_string( "010" ),   8, 'Octal integer' );
is_deeply( $parser->{spaces}, { }, q("010" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("010" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("010" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("010" tag end) );
}

ok( !eval { $parser->from_string( "0o20" ) }, '0o prefix fails' );

is( $parser->from_string( "-4" ), -4, 'Negative decimal' );
is_deeply( $parser->{spaces}, { }, q("-4" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("-4" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("-4" tag start) );
  is( $tagged->get_tag_at( 1, 'Int' ), 1, q("-4" tag end) );
}

ok( !eval { $parser->from_string( "hello" ) }, '"hello" fails' );

$parser = TestParser->new( accept_0o_oct => 1 );
is( $parser->from_string( "0o20" ), 16, 'Octal integer with 0o prefix' );
is_deeply( $parser->{spaces}, { }, q("0o20" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("0o20" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("0o20" tag start) );
  is( $tagged->get_tag_at( 3, 'Int' ), 1, q("0o20" tag end) );
}

$parser = TestParser_NoTag->new;

is( $parser->from_string( "123" ), 123, 'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("123" tags) );

done_testing;
