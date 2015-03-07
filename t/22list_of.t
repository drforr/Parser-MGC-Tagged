#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->list_of( ",", sub {
      return $self->token_int;
   } );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is_deeply( $parser->from_string( "123" ), [ 123 ], '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->from_string( "4,5,6" ), [ 4, 5, 6 ], '"4,5,6"' );
is_deeply( $parser->{spaces}, { }, q("4,5,6" spaces) );
is_deeply( $parser->from_string( "7, 8" ), [ 7, 8 ], '"7, 8"' );
is_deeply( $parser->{spaces},
  { 2 => 3 },
  q("7, 8" spaces) );

done_testing;
