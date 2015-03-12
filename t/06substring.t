#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   [ $self->substring_before( "!" ), $self->expect( "!", [ Expect => 1 ] ) ];
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   [ $self->substring_before( "!" ), $self->expect( "!" ) ];
}

package main;

my $parser = TestParser->new;

is_deeply( $parser->from_string( "Hello, world!" ),
   [ "Hello, world", "!" ],
   '"Hello, world!"' );
is_deeply( $parser->{spaces},
  { },
  q("Hello, world!" spaces) );
is_deeply( $parser->{tags},
  [ [ 12, 13, Expect => 1 ] ],
  q("Hello, world!" tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("Hello, world!" tagged) );
  is( $tagged->get_tag_at( 12, 'Expect' ), 1, q("Hello, world!" tag start) );
  is( $tagged->get_tag_at( 12, 'Expect' ), 1, q("Hello, world!" tag end) );
}

is_deeply( $parser->from_string( "!" ),
   [ "", "!" ],
   '"Hello, world!"' );
is_deeply( $parser->{spaces},
  { },
  q("!" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Expect => 1 ] ],
  q("!" tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("!" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("!" tag start) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("!" tag end) );
}

$parser = TestParser_NoTag->new;

is_deeply( $parser->from_string( "Hello, world!" ),
   [ "Hello, world", "!" ],
   '"Hello, world!"' );
is_deeply( $parser->{spaces},
  { },
  q("Hello, world!" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("Hello, world!" tags) );

done_testing;
