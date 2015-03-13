#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->any_of(
      sub { $self->token_int( Int => 1 ) },
      sub {
         $self->scope_of( "(",
            sub {
               $self->commit;
               $self->token_string( String => 1 );
            },
            ")",
           [ Scope_Of => 1 ] );
      },
      [ Any_Of => 1 ]
   );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->any_of(
      sub { $self->token_int },
      sub {
         $self->scope_of( "(",
            sub {
               $self->commit;
               $self->token_string;
            },
            ")" );
      }
   );
}

package IntStringPairsParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->sequence_of( sub {
      my $int = $self->token_int( Int => 1 );
      $self->commit;

      my $str = $self->token_string( String => 1 );

      [ $int, $str ];
   },
  [ Sequence_Of => 1 ] );
}

package main;

my $parser = TestParser->new;

is( $parser->from_string( "123" ), 123, '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("123" tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'Any_Of' ), 1, q("123" tag end) );
}

is( $parser->from_string( '("hi")' ), "hi", '("hi")' );
is_deeply( $parser->{spaces}, { }, q['("hi")' spaces] );
is_deeply( $parser->{delimiters},
  [ [ 0, 1 ],
    [ 5, 6 ] ],
  q['("hi")' delimiters] );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q(("hi")) tagged) );
  is( $tagged->get_tag_at( 1, 'String' ), 1, q(q("("hi")) tag start) );
  is( $tagged->get_tag_at( 4, 'String' ), 1, q(q("("hi")) tag end) );
  is( $tagged->get_tag_at( 0, 'Scope_Of' ), 1, q(q("("hi")) tag start) );
  is( $tagged->get_tag_at( 5, 'Scope_Of' ), 1, q(q("("hi")) tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q(q("("hi")) tag start) );
  is( $tagged->get_tag_at( 5, 'Any_Of' ), 1, q(q("("hi")) tag end) );
}

ok( !eval { $parser->from_string( "(456)" ) }, '"(456)" fails' );
is( $@,
   qq[Expected string delimiter on line 1 at:\n].
   qq[(456)\n].
   qq[ ^\n],
   'Exception from "(456)" failure' );

$parser = IntStringPairsParser->new;

is_deeply( $parser->from_string( "1 'one' 2 'two'" ),
           [ [ 1, "one" ], [ 2, "two" ] ],
           "1 'one' 2 'two'" );
is_deeply( $parser->{spaces},
  { 1 => 2, 7 => 8, 9 => 10 },
  q("1 'one' 2 'two'" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q(("1 'one' 2 'two')) tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q(q("("1 'one' 2 'two')) tag start) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q(q("("1 'one' 2 'two')) tag end) );
  is( $tagged->get_tag_at( 2, 'String' ), 1,
      q(q("("1 'one' 2 'two')) tag start) );
  is( $tagged->get_tag_at( 6, 'String' ), 1,
      q(q("("1 'one' 2 'two')) tag end) );
  is( $tagged->get_tag_at( 8, 'Int' ), 1, q(q("("1 'one' 2 'two')) tag start) );
  is( $tagged->get_tag_at( 8, 'Int' ), 1, q(q("("1 'one' 2 'two')) tag end) );
  is( $tagged->get_tag_at( 10, 'String' ), 1,
      q(q("("1 'one' 2 'two')) tag start) );
  is( $tagged->get_tag_at( 14, 'String' ), 1,
      q(q("("1 'one' 2 'two')) tag end) );
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1,
      q(q("("1 'one' 2 'two')) tag start) );
  is( $tagged->get_tag_at( 14, 'Sequence_Of' ), 1,
      q(q("("1 'one' 2 'two')) tag end) );
}

ok( !eval { $parser->from_string( "1 'one' 2" ) }, "1 'one' 2 fails" );
is( $@,
    qq[Expected string on line 1 at:\n].
    qq[1 'one' 2\n].
    qq[         ^\n],
    'Exception from 1 \'one\' 2 failure' );

$parser = TestParser_NoTag->new;

is( $parser->from_string( "123" ), 123, '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("123" tags) );

done_testing;
