#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  $self->list_of( ",", sub {
     return $self->token_int( Int => 1 );
  },
  [ List_Of => 1 ] );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  $self->list_of( ",", sub {
    return $self->token_int
  } );
}

package TestParser2;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  return [
    $self->list_of( ",", sub {
       return $self->token_int( Int => 1 );
    },
    [ List_Of => 1 ] ),
    $self->list_of( ",", sub {
       return $self->token_int( Int => 1 );
    },
    [ List_Of => 1 ] ),
 ];
}

package main;

my $parser = TestParser->new;

is_deeply( $parser->from_string( "123" ), [ 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("123" tag end) );
  is( $tagged->get_tag_at( 0, 'List_Of' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'List_Of' ), 1, q("123" tag end) );
}

is_deeply( $parser->from_string( "4,5,6" ), [ 4, 5, 6 ], '"4,5,6"' );
is_deeply( $parser->{spaces}, { }, q("4,5,6" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("4,5,6" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("4,5,6" tag start) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("4,5,6" tag end) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("4,5,6" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("4,5,6" tag end) );
  is( $tagged->get_tag_at( 4, 'Int' ), 1, q("4,5,6" tag start) );
  is( $tagged->get_tag_at( 4, 'Int' ), 1, q("4,5,6" tag end) );
  is( $tagged->get_tag_at( 0, 'List_Of' ), 1, q("4,5,6" tag start) );
  is( $tagged->get_tag_at( 4, 'List_Of' ), 1, q("4,5,6" tag end) );
}

is_deeply( $parser->from_string( "7, 8" ), [ 7, 8 ], '"7, 8"' );
is_deeply( $parser->{spaces},
  { 2 => 3 },
  q("7, 8" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("7, 8" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("7, 8" tag start) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("7, 8" tag end) );
  is( $tagged->get_tag_at( 3, 'Int' ), 1, q("7, 8" tag start) );
  is( $tagged->get_tag_at( 3, 'Int' ), 1, q("7, 8" tag end) );
  is( $tagged->get_tag_at( 0, 'List_Of' ), 1, q("7, 8" tag start) );
  is( $tagged->get_tag_at( 3, 'List_Of' ), 1, q("7, 8" tag end) );
}

$parser = TestParser2->new;

is_deeply( $parser->from_string( "123 456" ), [ [ 123 ], [ 456 ] ], '"123"' );
is_deeply( $parser->{spaces}, { 3 => 4 }, q("123 456" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123 456" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("123 456" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("123 456" tag end) );
  is( $tagged->get_tag_at( 0, 'List_Of' ), 1, q("123 456" tag start) );
  is( $tagged->get_tag_at( 2, 'List_Of' ), 1, q("123 456" tag end) );
  is( $tagged->get_tag_at( 4, 'Int' ), 1, q("123 456" tag start) );
  is( $tagged->get_tag_at( 6, 'Int' ), 1, q("123 456" tag end) );
  is( $tagged->get_tag_at( 4, 'List_Of' ), 1, q("123 456" tag start) );
  is( $tagged->get_tag_at( 6, 'List_Of' ), 1, q("123 456" tag end) );
}

$parser = TestParser_NoTag->new;

is_deeply( $parser->from_string( "123" ), [ 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags}, [ ], q("123" tags) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("123" tags) );

done_testing;
