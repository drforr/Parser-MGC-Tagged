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
    sub { [ int => $self->token_int( Int => 1 ) ] },
    sub { [ str => $self->token_string( String => 1 ) ] },
    sub { [ ident => $self->token_ident( Ident => 1 ) ] },
    sub { $self->expect( "@", [ Expect => 1 ] ); die "Here I fail\n" },
    [ Any_Of => 1 ]
  );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  $self->any_of(
    sub { [ int => $self->token_int ] },
    sub { [ str => $self->token_string ] },
    sub { [ ident => $self->token_ident ] },
    sub { $self->expect( "@" ); die "Here I fail\n" }
  );
}

package TestParser2;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return [
     $self->any_of(
       sub { [ int => $self->token_int( Int => 1 ) ] },
       sub { [ str => $self->token_string( String => 1 ) ] },
       sub { [ ident => $self->token_ident( Ident => 1 ) ] },
       sub { $self->expect( "@", [ Expect => 1 ] ); die "Here I fail\n" },
       [ Any_Of => 1 ]
     ),
     $self->any_of(
       sub { [ int => $self->token_int( Int => 1 ) ] },
       sub { [ str => $self->token_string( String => 1 ) ] },
       sub { [ ident => $self->token_ident( Ident => 1 ) ] },
       sub { $self->expect( "@", [ Expect => 1 ] ); die "Here I fail\n" },
       [ Any_Of => 1 ]
     ),
  ];
}

package main;

my $parser = TestParser->new;

is_deeply( $parser->from_string( "123" ), [ int => 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("123" tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("123" tag start) );
  is( $tagged->get_tag_at( 2, 'Any_Of' ), 1, q("123" tag end) );
}

is_deeply( $parser->from_string( q["hi"] ), [ str => "hi" ], '"hi"' );
is_deeply( $parser->{spaces}, { }, q(q["hi"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["hi"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["hi"] tag start) );
  is( $tagged->get_tag_at( 3, 'String' ), 1, q(q["hi"] tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q(q["hi"] tag start) );
  is( $tagged->get_tag_at( 3, 'Any_Of' ), 1, q(q["hi"] tag end) );
}

is_deeply( $parser->from_string( "foobar" ),
  [ ident => "foobar" ],
  '"foobar"' );
is_deeply( $parser->{spaces}, { }, q("foobar" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("foobar" tagged) );
  is( $tagged->get_tag_at( 0, 'Ident' ), 1, q("foobar" tag start) );
  is( $tagged->get_tag_at( 5, 'Ident' ), 1, q("foobar" tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("foobar" tag start) );
  is( $tagged->get_tag_at( 5, 'Any_Of' ), 1, q("foobar" tag end) );
}

ok( !eval { $parser->from_string( "@" ) }, '"@" fails' );
is( $@, "Here I fail\n", 'Exception from "@" failure' );

ok( !eval { $parser->from_string( "+" ) }, '"+" fails' );

$parser = TestParser2->new;

is_deeply( $parser->from_string( "123 456" ),
  [ [ int => 123 ], [ int => 456 ] ],
  '"123"' );
is_deeply( $parser->{spaces}, { 3 => 4 }, q("123 456" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123 456" tagged) );
  is( $tagged->get_tag_at( 0, 'Int' ), 1, q("123 456" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("123 456" tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("123 456" tag start) );
  is( $tagged->get_tag_at( 2, 'Any_Of' ), 1, q("123 456" tag end) );
  is( $tagged->get_tag_at( 4, 'Int' ), 1, q("123 456" tag start) );
  is( $tagged->get_tag_at( 6, 'Int' ), 1, q("123 456" tag end) );
  is( $tagged->get_tag_at( 4, 'Any_Of' ), 1, q("123 456" tag start) );
  is( $tagged->get_tag_at( 6, 'Any_Of' ), 1, q("123 456" tag end) );
}

$parser = TestParser_NoTag->new;

is_deeply( $parser->from_string( "123" ), [ int => 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags}, [ ], q("123" tags) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("123" tags) );

done_testing;
