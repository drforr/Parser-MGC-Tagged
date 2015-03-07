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

   return $self->generic_token( token => $re, $convert, Generic_Token => 1 );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

$re = qr/[A-Z]+/;
is( $parser->from_string( "HELLO" ), "HELLO", 'Simple RE' );
is_deeply( $parser->{spaces}, { }, q("HELLO" spaces) );
is_deeply( $parser->{tags}, [ [ 0, 5, Generic_Token => 1 ] ], q("HELLO" tags) );

ok( !eval { $parser->from_string( "hello" ) }, 'Simple RE fails' );

$re = qr/[A-Z]+/i;
is( $parser->from_string( "Hello" ), "Hello", 'RE with flags' );
is_deeply( $parser->{spaces}, { }, q("Hello" spaces) );
is_deeply( $parser->{tags}, [ [ 0, 5, Generic_Token => 1 ] ], q("Hello" tags) );

$convert = sub { lc $_[1] };
is( $parser->from_string( "Hello" ), "hello", 'Conversion function' );
is_deeply( $parser->{spaces}, { }, q("hello" spaces) );
is_deeply( $parser->{tags}, [ [ 0, 5, Generic_Token => 1 ] ], q("hello" tags) );

done_testing;
