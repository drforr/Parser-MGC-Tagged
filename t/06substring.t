#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
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

is_deeply( $parser->from_string( "!" ),
   [ "", "!" ],
   '"Hello, world!"' );
is_deeply( $parser->{spaces},
  { },
  q("!" spaces) );

done_testing;
