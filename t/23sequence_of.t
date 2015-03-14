#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  $self->sequence_of( sub {
     return $self->token_int( Int => 1 );
  },
  [ Sequence_Of => 1 ] );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  $self->sequence_of( sub {
    return $self->token_int
  } );
}

package IntThenStringParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  [ $self->sequence_of( sub {
      return $self->token_int( Int => 1 ) },
      [ Sequence_Of => 1 ] ),

    $self->sequence_of( sub {
      return $self->token_string( String => 1 ) },
      [ Sequence_Of => 1 ] ),
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
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'Sequence_Of' ), 1, q("123" tag end) );
}

is_deeply( $parser->from_string( "4 5 6" ), [ 4, 5, 6 ], '"4 5 6"' );
is_deeply( $parser->{spaces},
  { 1 => 2, 3 => 4 },
  q("4 5 6" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("4 5 6" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("4 5 6" tag start) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("4 5 6" tag end) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("4 5 6" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("4 5 6" tag end) );
  is( $tagged->get_tag_at( 4, 'Int' ), 1, q("4 5 6" tag start) );
  is( $tagged->get_tag_at( 4, 'Int' ), 1, q("4 5 6" tag end) );
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1, q("4 5 6" tag start) );
  is( $tagged->get_tag_at( 4, 'Sequence_Of' ), 1, q("4 5 6" tag end) );
}

is_deeply( $parser->from_string( "" ), [], '""' );
is_deeply( $parser->{spaces}, { }, q("" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("" tags) );

$parser = IntThenStringParser->new;

is_deeply( $parser->from_string( "10 20 'ab' 'cd'" ),
           [ [ 10, 20 ], [ 'ab', 'cd' ] ], q("10 20 'ab' 'cd'") );
is_deeply( $parser->{spaces},
  { 2 => 3, 5 => 6, 10 => 11 },
  q("10 20 'ab' 'cd'" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("10 20 'ab' 'cd'" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("10 20 'ab' 'cd'" tag start) );
  is( $tagged->get_tag_at( 1, 'Int' ), 1, q("10 20 'ab' 'cd'" tag end) );
  is( $tagged->get_tag_at( 3, 'Int' ), 1, q("10 20 'ab' 'cd'" tag start) );
  is( $tagged->get_tag_at( 4, 'Int' ), 1, q("10 20 'ab' 'cd'" tag end) );
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1,
      q("10 20 'ab' 'cd'" tag start) );
  is( $tagged->get_tag_at( 4, 'Sequence_Of' ), 1,
      q("10 20 'ab' 'cd'" tag end) );
  is( $tagged->get_tag_at( 6, 'String' ), 1, q("10 20 'ab' 'cd'" tag start) );
  is( $tagged->get_tag_at( 9, 'String' ), 1, q("10 20 'ab' 'cd'" tag end) );
  is( $tagged->get_tag_at( 11, 'String' ), 1, q("10 20 'ab' 'cd'" tag start) );
  is( $tagged->get_tag_at( 14, 'String' ), 1, q("10 20 'ab' 'cd'" tag end) );
  is( $tagged->get_tag_at( 6, 'Sequence_Of' ), 1,
      q("10 20 'ab' 'cd'" tag start) );
  is( $tagged->get_tag_at( 14, 'Sequence_Of' ), 1,
      q("10 20 'ab' 'cd'" tag end) );
}

is_deeply( $parser->from_string( "10 20" ),
           [ [ 10, 20 ], [] ], q("10 20") );
is_deeply( $parser->{spaces},
  { 2 => 3 },
  q("10 20" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("10 20" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("10 20" tag start) );
  is( $tagged->get_tag_at( 1, 'Int' ), 1, q("10 20" tag start) );
  is( $tagged->get_tag_at( 3, 'Int' ), 1, q("10 20" tag start) );
  is( $tagged->get_tag_at( 4, 'Int' ), 1, q("10 20" tag end) );
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1, q("10 20" tag end) );
  is( $tagged->get_tag_at( 4, 'Sequence_Of' ), 1, q("10 20" tag end) );
}

is_deeply( $parser->from_string( "'ab' 'cd'" ),
           [ [], [ 'ab', 'cd' ] ], q("'ab' 'cd'") );
is_deeply( $parser->{spaces},
  { 4 => 5 },
  q("'ab' 'cd'" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 4, String => 1 ],
    [ 5, 9, String => 1 ],
    [ 0, 9, Sequence_Of => 1 ] ],
  q("'ab' 'cd'" tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("10 20" tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q("10 20" tag start) );
  is( $tagged->get_tag_at( 3, 'String' ), 1, q("10 20" tag start) );
  is( $tagged->get_tag_at( 5, 'String' ), 1, q("10 20" tag start) );
  is( $tagged->get_tag_at( 8, 'String' ), 1, q("10 20" tag end) );
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1, q("10 20" tag end) );
  is( $tagged->get_tag_at( 8, 'Sequence_Of' ), 1, q("10 20" tag end) );
}

$parser = TestParser_NoTag->new;
 
is_deeply( $parser->from_string( "123" ), [ 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("123" tags) );

done_testing;
