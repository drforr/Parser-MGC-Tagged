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
      $self->token_ident( Ident => 1 );
   } ) ||
      $self->token_int( Int => 1 );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->maybe( sub {
      die $die if $die;
      $self->token_ident;
   } ) ||
      $self->token_int;
}

package main;

my $parser = TestParser->new;

is( $parser->from_string( "hello" ), "hello", '"hello"' );
is_deeply( $parser->{spaces}, { }, q("hello" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("hello" tagged) );
  is( $tagged->get_tag_at( 0, 'Ident' ), 1, q("hello" tag start) );
  is( $tagged->get_tag_at( 4, 'Ident' ), 1, q("hello" tag end) );
}

is( $parser->from_string( "123" ), 123, '"123"' );
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

$parser = TestParser_NoTag->new;

is( $parser->from_string( "hello" ), "hello", '"hello"' );
is_deeply( $parser->{spaces}, { }, q("hello" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("hello" tags) );

$die = "Now have to fail\n";
ok( !eval { $parser->from_string( "456" ) }, '"456" with $die fails' );
is( $@, "Now have to fail\n", 'Exception from failure' );

done_testing;
