#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
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
is( $parser->from_string( "0" ),     0, 'Zero' );
is_deeply( $parser->{spaces}, { }, q("0" spaces) );
is( $parser->from_string( "0x20" ), 32, 'Hexadecimal integer' );
is_deeply( $parser->{spaces}, { }, q("0x20" spaces) );
is( $parser->from_string( "010" ),   8, 'Octal integer' );
is_deeply( $parser->{spaces}, { }, q("010" spaces) );
ok( !eval { $parser->from_string( "0o20" ) }, '0o prefix fails' );
is_deeply( $parser->{spaces}, { }, q("0o20" spaces) );

is( $parser->from_string( "-4" ), -4, 'Negative decimal' );
is_deeply( $parser->{spaces}, { }, q("-4" spaces) );

ok( !eval { $parser->from_string( "hello" ) }, '"hello" fails' );

$parser = TestParser->new( accept_0o_oct => 1 );
is( $parser->from_string( "0o20" ), 16, 'Octal integer with 0o prefix' );
is_deeply( $parser->{spaces}, { }, q("0o20" spaces) );

done_testing;
