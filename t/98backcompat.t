#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package OneOfParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->one_of(
      sub { [ int => $self->token_int( Int => 1 ) ] },
      sub { [ str => $self->token_string( String => 1 ) ] },
   );
}

package main;

my $parser = OneOfParser->new;

is_deeply( $parser->from_string( "123" ), [ int => 123 ], 'one_of integer' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags}, [ [ 0, 3, Int => 1 ] ], q("123" tags) );

is_deeply( $parser->from_string( q["hi"] ), [ str => "hi" ], 'one_of string' );
is_deeply( $parser->{spaces}, { }, q(q["hi"] spaces) );
is_deeply( $parser->{tags}, [ [ 0, 4, String => 1 ] ], q(q["hi"] tags) );

done_testing;
