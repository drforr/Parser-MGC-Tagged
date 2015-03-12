#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_ident( Ident => 1 );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_ident;
}

package main;

my $parser = TestParser->new;

is( $parser->from_string( "foo" ), "foo", 'Identifier' );
is_deeply( $parser->{spaces}, { }, q("foo" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("foo" tagged) );
  is( $tagged->get_tag_at( 0, 'Ident' ), 1, q("foo" tag start) );
  is( $tagged->get_tag_at( 2, 'Ident' ), 1, q("foo" tag end) );
}

is( $parser->from_string( "x" ), "x", 'Single-letter identifier' );
is_deeply( $parser->{spaces}, { }, q("x" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("x" tagged) );
  is( $tagged->get_tag_at( 0, 'Ident' ), 1, q("x" tag start) );
  is( $tagged->get_tag_at( 0, 'Ident' ), 1, q("x" tag end) );
}

ok( !eval { $parser->from_string( "123" ) }, '"123" fails' );
is( $@,
   qq[Expected ident on line 1 at:\n] .
   qq[123\n] .
   qq[^\n],
   'Exception from "123" failure' );

ok( !eval { $parser->from_string( "some-ident" ) }, '"some-ident" fails on default identifier' );

$parser = TestParser->new(
   patterns => { ident => qr/[[:alpha:]_][\w-]+/ },
);

is( $parser->from_string( "some-ident" ),
    "some-ident",
    '"some-ident" passes with new token pattern' );
is_deeply( $parser->{spaces}, { }, q("some-ident" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 10, Ident => 1 ] ],
  q("some-ident" tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("some-ident" tagged) );
  is( $tagged->get_tag_at( 0, 'Ident' ), 1, q("some-ident" tag start) );
  is( $tagged->get_tag_at( 9, 'Ident' ), 1, q("some-ident" tag end) );
}

$parser = TestParser_NoTag->new;

is( $parser->from_string( "foo" ), "foo", 'Identifier' );
is_deeply( $parser->{spaces}, { }, q("foo" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("foo" tags) );

done_testing;
