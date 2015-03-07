#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

my $re;
my $convert;

sub parse
{
   my $self = shift;

   return $self->generic_token( token => $re, $convert );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

$re = qr/[A-Z]+/;
is( $parser->from_string( "HELLO" ), "HELLO", 'Simple RE' );
is_deeply( $parser->{spaces}, { }, q("HELLO" spaces) );
ok( !eval { $parser->from_string( "hello" ) }, 'Simple RE fails' );

$re = qr/[A-Z]+/i;
is( $parser->from_string( "Hello" ), "Hello", 'RE with flags' );
is_deeply( $parser->{spaces}, { }, q("Hello" spaces) );

$convert = sub { lc $_[1] };
is( $parser->from_string( "Hello" ), "hello", 'Conversion function' );
is_deeply( $parser->{spaces}, { }, q("Hello" spaces) );

done_testing;
