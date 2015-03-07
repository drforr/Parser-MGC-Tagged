#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my $die;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->maybe( sub {
      die $die if $die;
      $self->token_ident;
   } ) ||
      $self->token_int( Int => 1 );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( "hello" ), "hello", '"hello"' );
is_deeply( $parser->{spaces}, { }, q("hello" spaces) );

is( $parser->from_string( "123" ), 123, '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags}, [ [ 0, 3, Int => 1 ] ], q("123" tags) );

$die = "Now have to fail\n";
ok( !eval { $parser->from_string( "456" ) }, '"456" with $die fails' );
is( $@, "Now have to fail\n", 'Exception from failure' );

done_testing;
