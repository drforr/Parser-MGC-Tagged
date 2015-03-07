#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse_hello
{
   my $self = shift;

   [ $self->expect( "hello" ), $self->expect( qr/world/ ) ];
}

sub parse_hex
{
   my $self = shift;

   return hex +( $self->expect( qr/0x([0-9A-F]+)/i ) )[1];
}

sub parse_foo_or_bar
{
   my $self = shift;

   return $self->maybe_expect( qr/foo/i ) ||
          $self->maybe_expect( qr/bar/i );
}

sub parse_numrange
{
   my $self = shift;

   return [ ( $self->maybe_expect( qr/(\d+)(?:-(\d+))?/ ) )[1,2] ];
}

package main;
#$ENV{DEBUG}=1;

my $parser = TestParser->new( toplevel => "parse_hello" );

is_deeply( $parser->from_string( "hello world" ),
   [ "hello", "world" ],
   '"hello world"' );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("hello world" spaces) );

is_deeply( $parser->from_string( "  hello world  " ),
   [ "hello", "world" ],
   '"  hello world  "' );
is_deeply( $parser->{spaces},
  { 0 => 2,
    7 => 8,
    13 => 15 },
  q("  hello world  " spaces) );

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

$parser = TestParser->new( toplevel => "parse_foo_or_bar" );

is( $parser->from_string( "Foo" ), "Foo", "FooBar parser first case" );
is_deeply( $parser->{spaces}, { }, q("Foo" spaces) );
is( $parser->from_string( "Bar" ), "Bar", "FooBar parser first case" );
is_deeply( $parser->{spaces}, { }, q("Bar" spaces) );

$parser = TestParser->new( toplevel => "parse_numrange" );

is_deeply( $parser->from_string( "123-456" ), [ 123, 456 ], "Number range parser complete" );
is_deeply( $parser->{spaces}, { }, q("123-456" spaces) );

{
   my $warnings = "";
   local $SIG{__WARN__} = sub { $warnings .= join "", @_ };

   is_deeply( $parser->from_string( "789" ), [ 789, undef ],   "Number range parser lacking max" );
  is_deeply( $parser->{spaces}, { }, q("789" spaces) );
   is( $warnings, "", "Number range lacking max yields no warnings" );
}

done_testing;
