#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_kw( qw( foo bar ) );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( "foo" ), "foo", 'Keyword' );
is_deeply( $parser->{spaces}, { }, q("foo" spaces) );

ok( !eval { $parser->from_string( "splot" ) }, '"splot" fails' );
is( $@,
   qq[Expected any of foo, bar on line 1 at:\n] .
   qq[splot\n] .
   qq[^\n],
   'Exception from "splot" failure' );

done_testing;
