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
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( "123" ), 123, 'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Int => 1 ] ],
  q("123" tags) );

is( $parser->from_string( "0" ),     0, 'Zero' );
is_deeply( $parser->{spaces}, { }, q("0" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Int => 1 ] ],
  q("0" tags) );

is( $parser->from_string( "0x20" ), 32, 'Hexadecimal integer' );
is_deeply( $parser->{spaces}, { }, q("0x20" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 4, Int => 1 ] ],
  q("0x20" tags) );

is( $parser->from_string( "010" ),   8, 'Octal integer' );
is_deeply( $parser->{spaces}, { }, q("010" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Int => 1 ] ],
  q("010" tags) );

ok( !eval { $parser->from_string( "0o20" ) }, '0o prefix fails' );

is( $parser->from_string( "-4" ), -4, 'Negative decimal' );
is_deeply( $parser->{spaces}, { }, q("-4" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 2, Int => 1 ] ],
  q("-4" tags) );

ok( !eval { $parser->from_string( "hello" ) }, '"hello" fails' );

$parser = TestParser->new( accept_0o_oct => 1 );
is( $parser->from_string( "0o20" ), 16, 'Octal integer with 0o prefix' );
is_deeply( $parser->{spaces}, { }, q("0o20" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 4, Int => 1 ] ],
  q("0o20" tags) );

$parser = TestParser_NoTag->new;

is( $parser->from_string( "123" ), 123, 'Decimal integer' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags}, [ ], q("123" tags) );

done_testing;
