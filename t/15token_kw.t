#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_kw( qw( foo bar ), [ Kw => 1 ] );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_kw( qw( foo bar ) );
}

package TestParser2;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return [ $self->token_kw( qw( foo bar ), [ Kw_1 => 1 ] ),
            $self->token_kw( qw( foo bar ), [ Kw_2 => 1 ] ) ];
}

package main;

my $parser = TestParser->new;

is( $parser->from_string( "foo" ), "foo", 'Keyword' );
is_deeply( $parser->{spaces}, { }, q("foo" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("foo" tagged) );
  is( $tagged->get_tag_at( 0, 'Kw' ), 1, q("foo" tag start) );
  is( $tagged->get_tag_at( 2, 'Kw' ), 1, q("foo" tag end) );
}

ok( !eval { $parser->from_string( "splot" ) }, '"splot" fails' );
is( $@,
   qq[Expected any of foo, bar on line 1 at:\n] .
   qq[splot\n] .
   qq[^\n],
   'Exception from "splot" failure' );

$parser = TestParser2->new;

is_deeply( $parser->from_string( "foo bar" ), [ "foo", "bar" ], 'Keyword with spaces' );
is_deeply( $parser->{spaces}, { 3 => 4 }, q("foo bar" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("foo bar" tagged) );
  is( $tagged->get_tag_at( 0, 'Kw_1' ), 1, q("foo bar" tag start) );
  is( $tagged->get_tag_at( 2, 'Kw_1' ), 1, q("foo bar" tag end) );
  is( $tagged->get_tag_at( 4, 'Kw_2' ), 1, q("foo bar" tag start) );
  is( $tagged->get_tag_at( 6, 'Kw_2' ), 1, q("foo bar" tag end) );
}

$parser = TestParser_NoTag->new;

is( $parser->from_string( "foo" ), "foo", 'Keyword' );
is_deeply( $parser->{spaces}, { }, q("foo" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("foo" tags) );

done_testing;
