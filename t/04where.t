#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

my @positions;
my @wheres;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   main::is( $self->pos,
      $positions[0],
      '->pos before parsing' );
   main::is_deeply( [ $self->where ],
      $wheres[0],
      '->where before parsing' );

   $self->expect( "hello", [ Expect_1 => 1 ] );
   main::is( $self->pos,
      $positions[1],
      '->pos during parsing' );
   main::is_deeply( [ $self->where ],
      $wheres[1],
      '->where during parsing' );

   $self->expect( qr/world/, [ Expect_2 => 1 ] );
   main::is( $self->pos,
      $positions[2],
      '->pos after parsing' );
   main::is_deeply( [ $self->where ],
      $wheres[2],
      '->where after parsing' );

   return 1;
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   main::is( $self->pos,
      $positions[0],
      '->pos before parsing' );
   main::is_deeply( [ $self->where ],
      $wheres[0],
      '->where before parsing' );

   $self->expect( "hello" );
   main::is( $self->pos,
      $positions[1],
      '->pos during parsing' );
   main::is_deeply( [ $self->where ],
      $wheres[1],
      '->where during parsing' );

   $self->expect( qr/world/ );
   main::is( $self->pos,
      $positions[2],
      '->pos after parsing' );
   main::is_deeply( [ $self->where ],
      $wheres[2],
      '->where after parsing' );

   return 1;
}

package main;

my $parser = TestParser->new;

@positions = ( 0, 5, 11 );
@wheres = (
   [ 1, 0, "hello world" ],
   [ 1, 5, "hello world" ],
   [ 1, 11, "hello world" ], );
$parser->from_string( "hello world" );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("hello world" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("hello world" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect_1' ), 1, q("hello world" tag 1 start) );
  is( $tagged->get_tag_at( 4, 'Expect_1' ), 1, q("hello world" tag 1 end) );
  is( $tagged->get_tag_at( 6, 'Expect_2' ), 1, q("hello world" tag 2 start) );
  is( $tagged->get_tag_at( 10, 'Expect_2' ), 1, q("hello world" tag 2 end) );
}

@positions = ( 0, 5, 11 );
@wheres = (
   [ 1, 0, "hello" ],
   [ 1, 5, "hello" ],
   [ 2, 5, "world" ], );
$parser->from_string( "hello\nworld" );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("hello\nworld" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("hello world" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect_1' ), 1, q("hello\nworld" tag 1 start) );
  is( $tagged->get_tag_at( 4, 'Expect_1' ), 1, q("hello\nworld" tag 1 end) );
  is( $tagged->get_tag_at( 6, 'Expect_2' ), 1, q("hello\nworld" tag 2 start) );
  is( $tagged->get_tag_at( 10, 'Expect_2' ), 1, q("hello\nworld" tag 2 end) );
}

$parser = TestParser_NoTag->new;

@positions = ( 0, 5, 11 );
@wheres = (
   [ 1, 0, "hello world" ],
   [ 1, 5, "hello world" ],
   [ 1, 11, "hello world" ], );
$parser->from_string( "hello world" );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("hello world" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("hello world" tags) );

done_testing;
