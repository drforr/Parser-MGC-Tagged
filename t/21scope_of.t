#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  $self->scope_of(
    "(",
    sub { return $self->token_int( Int => 1 ) },
    ")",
    [ Scope_Of => 1 ]
  );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  $self->scope_of(
    "(",
    sub { return $self->token_int },
    ")"
  );
}

package TestParser2;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  return [
    $self->scope_of(
      "(",
      sub { return $self->token_int( Int => 1 ) },
      ")",
      [ Scope_Of => 1 ]
    ),
    $self->scope_of(
      "(",
      sub { return $self->token_int( Int => 1 ) },
      ")",
      [ Scope_Of => 1 ]
    ),
  ];
}

package DynamicDelimParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  my $delim = $self->expect( qr/[\(\[]/, [ Expect => 1 ] );
  $delim =~ tr/([/)]/;

  $self->scope_of(
    undef,
    sub { return $self->token_int( Int => 1 ) },
    $delim,
    [ Scope_Of => 1 ]
  );
}

package main;

my $parser = TestParser->new;

is( $parser->from_string( "(123)" ), 123, '"(123)"' );
is_deeply( $parser->{spaces}, { }, q("(123)" spaces) );
is_deeply( $parser->{delimiters},
  [ [ 0, 1 ],
    [ 4, 5 ] ],
  q("(123)" delimiters) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("(123)" tagged) );
  is( $tagged->get_tag_at( 1, 'Int' ), 1, q("(123)" tag start) );
  is( $tagged->get_tag_at( 3, 'Int' ), 1, q("(123)" tag end) );
  is( $tagged->get_tag_at( 0, 'Scope_Of' ), 1, q("(123)" tag start) );
  is( $tagged->get_tag_at( 4, 'Scope_Of' ), 1, q("(123)" tag end) );
}

ok( !eval { $parser->from_string( "(abc)" ) }, '"(abc)"' );

ok( !eval { $parser->from_string( "456" ) }, '"456"' );

$parser = TestParser2->new;

is_deeply( $parser->from_string( "(123) (456)" ),
   [ 123, 456 ],
   '"(123) (456)"' );
is_deeply( $parser->{spaces}, { 5 => 6 }, q("(123)" spaces) );
is_deeply( $parser->{delimiters},
  [ [ 0, 1 ],
    [ 4, 5 ],
    [ 6, 7 ],
    [ 10, 11 ] ],
  q("(123) (456)" delimiters) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("(123)" tagged) );
  is( $tagged->get_tag_at( 1, 'Int' ), 1, q("(123)" tag start) );
  is( $tagged->get_tag_at( 3, 'Int' ), 1, q("(123)" tag end) );
  is( $tagged->get_tag_at( 0, 'Scope_Of' ), 1, q("(123)" tag start) );
  is( $tagged->get_tag_at( 4, 'Scope_Of' ), 1, q("(123)" tag end) );
  is( $tagged->get_tag_at( 7, 'Int' ), 1, q("(123)" tag start) );
  is( $tagged->get_tag_at( 9, 'Int' ), 1, q("(123)" tag end) );
  is( $tagged->get_tag_at( 6, 'Scope_Of' ), 1, q("(123)" tag start) );
  is( $tagged->get_tag_at( 10, 'Scope_Of' ), 1, q("(123)" tag end) );
}

$parser = DynamicDelimParser->new;

is( $parser->from_string( "(45)" ), 45, '"(45)"' );
is_deeply( $parser->{spaces}, { }, q("(45)" spaces) );
is_deeply( $parser->{delimiters},
  [ [ 3, 4 ] ],
  q("(45)" delimiters) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("(45)" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("(45)" tag start) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("(45)" tag end) );
  is( $tagged->get_tag_at( 1, 'Int' ), 1, q("(45)" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("(45)" tag end) );
  is( $tagged->get_tag_at( 1, 'Scope_Of' ), 1, q("(45)" tag start) );
  is( $tagged->get_tag_at( 3, 'Scope_Of' ), 1, q("(45)" tag end) );
}

is( $parser->from_string( "[45]" ), 45, '"[45]"' );
is_deeply( $parser->{spaces}, { }, q("[45]" spaces) );
is_deeply( $parser->{delimiters},
  [ [ 3, 4 ] ],
  q("[45]" delimiters) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("[45]" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("[45]" tag start) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("[45]" tag end) );
  is( $tagged->get_tag_at( 1, 'Int' ), 1, q("[45]" tag start) );
  is( $tagged->get_tag_at( 2, 'Int' ), 1, q("[45]" tag end) );
  is( $tagged->get_tag_at( 1, 'Scope_Of' ), 1, q("[45]" tag start) );
  is( $tagged->get_tag_at( 3, 'Scope_Of' ), 1, q("[45]" tag end) );
}

ok( !eval { $parser->from_string( "(45]" ) }, '"(45]" fails' );

$parser = TestParser_NoTag->new;

is( $parser->from_string( "(123)" ), 123, '"(123)"' );
is_deeply( $parser->{spaces}, { }, q("(123)" spaces) );
is_deeply( $parser->{tags}, [ ], q("(123)" tags) );
is_deeply( $parser->{delimiters},
  [ [ 0, 1 ],
    [ 4, 5 ] ],
  q("(123)" delimiters) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("(123)" tags) );

done_testing;
