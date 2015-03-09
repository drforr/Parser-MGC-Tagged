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
#$ENV{DEBUG} = 1;

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

is_deeply( $parser->from_string( "!" ),
   [ "", "!" ],
   '"Hello, world!"' );
is_deeply( $parser->{spaces},
  { },
  q("!" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Expect => 1 ] ],
  q("!" tags) );

$parser = TestParser_NoTag->new;

is_deeply( $parser->from_string( "Hello, world!" ),
   [ "Hello, world", "!" ],
   '"Hello, world!"' );
is_deeply( $parser->{spaces},
  { },
  q("Hello, world!" spaces) );
is_deeply( $parser->{tags}, [ ], q("Hello, world!" tags) );

done_testing;
