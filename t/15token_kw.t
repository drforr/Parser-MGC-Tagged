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

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( "foo" ), "foo", 'Keyword' );
is_deeply( $parser->{spaces}, { }, q("foo" spaces) );
is_deeply( $parser->{tags}, [ [ 0, 3, Kw => 1 ] ], q("foo" tags) );

ok( !eval { $parser->from_string( "splot" ) }, '"splot" fails' );
is( $@,
   qq[Expected any of foo, bar on line 1 at:\n] .
   qq[splot\n] .
   qq[^\n],
   'Exception from "splot" failure' );

done_testing;
