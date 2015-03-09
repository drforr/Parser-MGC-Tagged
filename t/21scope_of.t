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
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( "(123)" ), 123, '"(123)"' );
is_deeply( $parser->{spaces}, { }, q("(123)" spaces) );
is_deeply( $parser->{tags},
  [ [ 1, 4, Int => 1 ],
    [ 0, 5, Scope_Of => 1 ] ],
  q("(123)" tags) );
is_deeply( $parser->{delimiters},
  [ [ 0, 1 ],
    [ 4, 5 ] ],
  q("(123)" delimiters) );

ok( !eval { $parser->from_string( "(abc)" ) }, '"(abc)"' );

ok( !eval { $parser->from_string( "456" ) }, '"456"' );

$parser = TestParser2->new;

is_deeply( $parser->from_string( "(123) (456)" ),
   [ 123, 456 ],
   '"(123) (456)"' );
is_deeply( $parser->{spaces}, { 5 => 6 }, q("(123)" spaces) );
is_deeply( $parser->{tags},
  [ [ 1, 4, Int => 1 ],
    [ 0, 5, Scope_Of => 1 ],
    [ 7, 10, Int => 1 ],
    [ 6, 11, Scope_Of => 1 ] ],
  q("(123) (456)" tags) );
is_deeply( $parser->{delimiters},
  [ [ 0, 1 ],
    [ 4, 5 ],
    [ 6, 7 ],
    [ 10, 11 ] ],
  q("(123) (456)" delimiters) );

$parser = DynamicDelimParser->new;

is( $parser->from_string( "(45)" ), 45, '"(45)"' );
is_deeply( $parser->{spaces}, { }, q("(45)" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Expect => 1 ],
    [ 1, 3, Int => 1 ],
    [ 1, 4, Scope_Of => 1 ] ], # Not a bug.
  q("(45)" tags) );
is_deeply( $parser->{delimiters},
  [ [ 3, 4 ] ],
  q("(45)" delimiters) );

is( $parser->from_string( "[45]" ), 45, '"[45]"' );
is_deeply( $parser->{spaces}, { }, q("[45]" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Expect => 1 ],
    [ 1, 3, Int => 1 ],
    [ 1, 4, Scope_Of => 1 ] ], # Not a bug.
  q("[45]" tags) );
is_deeply( $parser->{delimiters},
  [ [ 3, 4 ] ],
  q("[45]" delimiters) );

ok( !eval { $parser->from_string( "(45]" ) }, '"(45]" fails' );

done_testing;
