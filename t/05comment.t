#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->expect( "hello", [ Expect_1 => 1 ] );
   $self->expect( qr/world/, [ Expect_2 => 1 ] );

   return 1;
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->expect( "hello" );
   $self->expect( qr/world/ );

   return 1;
}

package main;

my $parser = TestParser->new;

ok( $parser->from_string( "hello world" ), '"hello world"' );
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

ok( $parser->from_string( "hello\nworld" ), '"hello\nworld"' );
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

ok( !eval { $parser->from_string( "hello\n# Comment\nworld" ) },
    '"hello world" with comment fails' );

$parser = TestParser->new(
   patterns => { comment => qr/#.*\n/ },
);

ok( $parser->from_string( "hello\n# Comment\nworld" ),
    '"hello world" with comment passes' );
is_deeply( $parser->{spaces},
  { 5 => 16 },
  q("hello\n# Comment\nworld") );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("hello\nworld" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect_1' ), 1,
     q("hello\n# Comment\nworld" tag 1 start) );
  is( $tagged->get_tag_at( 4, 'Expect_1' ), 1,
     q("hello\n# Comment\nworld" tag 1 end) );
  is( $tagged->get_tag_at( 16, 'Expect_2' ), 1,
     q("hello\n# Comment\nworld" tag 2 start) );
  is( $tagged->get_tag_at( 20, 'Expect_2' ), 1,
     q("hello\n# Comment\nworld" tag 2 end) );
}

$parser = TestParser_NoTag->new;

ok( $parser->from_string( "hello world" ), '"hello world"' );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("hello world" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("hello world" tags) );

done_testing;
