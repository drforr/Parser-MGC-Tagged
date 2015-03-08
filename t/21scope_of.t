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
      ")"
   );
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
   );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( "(123)" ), 123, '"(123)"' );
is_deeply( $parser->{spaces}, { }, q("(123)" spaces) );

ok( !eval { $parser->from_string( "(abc)" ) }, '"(abc)"' );
is_deeply( $parser->{spaces}, { }, q("(abc)" spaces) );

ok( !eval { $parser->from_string( "456" ) }, '"456"' );
is_deeply( $parser->{spaces}, { }, q("456" spaces) );

$parser = DynamicDelimParser->new;

is( $parser->from_string( "(45)" ), 45, '"(45)"' );
is_deeply( $parser->{spaces}, { }, q("(45)" spaces) );
is_deeply( $parser->{tags}, [ [ 0, 1, Expect => 1 ], [ 1, 3, Int => 1 ] ], q("(45)" tags) );

is( $parser->from_string( "[45]" ), 45, '"[45]"' );
is_deeply( $parser->{spaces}, { }, q("[45]" spaces) );

ok( !eval { $parser->from_string( "(45]" ) }, '"(45]" fails' );

done_testing;
