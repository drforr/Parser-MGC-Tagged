#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_kw( qw( foo bar ), [ Kw => 1 ] );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_kw( qw( foo bar ) );
}

package TestParser2;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return [ $self->token_kw( qw( foo bar ), [ Kw_1 => 1 ] ),
            $self->token_kw( qw( foo bar ), [ Kw_2 => 1 ] ) ];
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( "foo" ), "foo", 'Keyword' );
is_deeply( $parser->{spaces}, { }, q("foo" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Kw => 1 ] ],
  q("foo" tags) );

ok( !eval { $parser->from_string( "splot" ) }, '"splot" fails' );
is( $@,
   qq[Expected any of foo, bar on line 1 at:\n] .
   qq[splot\n] .
   qq[^\n],
   'Exception from "splot" failure' );

$parser = TestParser2->new;

is_deeply( $parser->from_string( "foo bar" ), [ "foo", "bar" ], 'Keyword with spaces' );
is_deeply( $parser->{spaces}, { 3 => 4 }, q("foo bar" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Kw_1 => 1 ],
    [ 4, 7, Kw_2 => 1 ] ],
  q("foo bar" tags) );

$parser = TestParser_NoTag->new;

is( $parser->from_string( "foo" ), "foo", 'Keyword' );
is_deeply( $parser->{spaces}, { }, q("foo" spaces) );
is_deeply( $parser->{tags}, [ ], q("foo" tags) );

done_testing;
