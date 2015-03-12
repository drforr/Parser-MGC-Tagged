#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse_hello
{
   my $self = shift;

   [ $self->expect( "hello", [ Expect_1 => 1 ] ),
     $self->expect( qr/world/, [ Expect_2 => 1 ] )
   ];
}

sub parse_hex
{
   my $self = shift;

   return hex +( $self->expect( qr/0x([0-9A-F]+)/i, [ Expect => 1 ] ) )[1];
}

sub parse_foo_or_bar
{
   my $self = shift;

   return $self->maybe_expect( qr/foo/i, [ Maybe_Expect_1 => 1 ] ) ||
          $self->maybe_expect( qr/bar/i, [ Maybe_Expect_2 => 1 ] );
}

sub parse_numrange
{
   my $self = shift;

   return [ ( $self->maybe_expect( qr/(\d+)(?:-(\d+))?/,
                                   [ Maybe_Expect => 1 ] ) )[1,2] ];
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse_hello
{
   my $self = shift;

   [ $self->expect( "hello" ),
     $self->expect( qr/world/ )
   ];
}

package main;

my $parser = TestParser->new( toplevel => "parse_hello" );

is_deeply( $parser->from_string( "hello world" ),
   [ "hello", "world" ],
   '"hello world"' );
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

is_deeply( $parser->from_string( "  hello world  " ),
   [ "hello", "world" ],
   '"  hello world  "' );
is_deeply( $parser->{spaces},
  { 0 => 2,
    7 => 8,
    13 => 15 },
  q("  hello world  " spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("  hello world  " tagged) );
  is( $tagged->get_tag_at( 2, 'Expect_1' ), 1,
      q("  hello world  " tag 1 start) );
  is( $tagged->get_tag_at( 6, 'Expect_1' ), 1,
      q("  hello world  " tag 1 end) );
  is( $tagged->get_tag_at( 8, 'Expect_2' ), 1,
      q("  hello world  " tag 2 start) );
  is( $tagged->get_tag_at( 12, 'Expect_2' ), 1,
      q("  hello world  " tag 2 end) );
}

# Perl 5.13.6 changed the regexp form
# Accept both old and new-style stringification
my $modifiers = (qr/foobar/ =~ /\Q(?^/) ? '^' : '-xism';

ok( !eval { $parser->from_string( "goodbye world" ) }, '"goodbye world" fails' );
is( $@,
   qq[Expected (?$modifiers:hello) on line 1 at:\n] . 
   qq[goodbye world\n] . 
   qq[^\n],
   'Exception from "goodbye world" failure' );

$parser = TestParser->new( toplevel => "parse_hex" );

is( $parser->from_string( "0x123" ), 0x123, "Hex parser captures substring" );
is_deeply( $parser->{spaces}, { }, q("0x123" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("0x123" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("0x123" tag start) );
  is( $tagged->get_tag_at( 4, 'Expect' ), 1, q("0x123" tag end) );
}

$parser = TestParser->new( toplevel => "parse_foo_or_bar" );

is( $parser->from_string( "Foo" ), "Foo", "FooBar parser first case" );
is_deeply( $parser->{spaces}, { }, q("Foo" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("Foo" tagged) );
  is( $tagged->get_tag_at( 0, 'Maybe_Expect_1' ), 1, q("Foo" tag start) );
  is( $tagged->get_tag_at( 2, 'Maybe_Expect_1' ), 1, q("Foo" tag end) );
}

is( $parser->from_string( "Bar" ), "Bar", "FooBar parser first case" );
is_deeply( $parser->{spaces}, { }, q("Bar" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("Bar" tagged) );
  is( $tagged->get_tag_at( 0, 'Maybe_Expect_2' ), 1, q("Bar" tag start) );
  is( $tagged->get_tag_at( 2, 'Maybe_Expect_2' ), 1, q("Bar" tag end) );
}

$parser = TestParser->new( toplevel => "parse_numrange" );

is_deeply( $parser->from_string( "123-456" ), [ 123, 456 ], "Number range parser complete" );
is_deeply( $parser->{spaces}, { }, q("123-456" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("123-456" tagged) );
  is( $tagged->get_tag_at( 0, 'Maybe_Expect' ), 1, q("123-456" tag start) );
  is( $tagged->get_tag_at( 6, 'Maybe_Expect' ), 1, q("123-456" tag end) );
}

{
   my $warnings = "";
   local $SIG{__WARN__} = sub { $warnings .= join "", @_ };

   is_deeply( $parser->from_string( "789" ), [ 789, undef ],   "Number range parser lacking max" );
  is_deeply( $parser->{spaces}, { }, q("789" spaces) );
  {
    my $tagged = $parser->tagged;
    isa_ok( $tagged, 'String::Tagged', q("789" tagged) );
    is( $tagged->get_tag_at( 0, 'Maybe_Expect' ), 1, q("789" tag start) );
    is( $tagged->get_tag_at( 2, 'Maybe_Expect' ), 1, q("789" tag end) );
  }
   is( $warnings, "", "Number range lacking max yields no warnings" );
}

$parser = TestParser_NoTag->new( toplevel => "parse_hello" );

is_deeply( $parser->from_string( "hello world" ),
   [ "hello", "world" ],
   '"hello world"' );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("hello world" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("hello world" tags) );

done_testing;
