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

   return $self->generic_token(
     token => $re, $convert, [ Generic_Token => 1 ] );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

my $re_NoTag;
my $convert_NoTag;

sub parse
{
   my $self = shift;

   return $self->generic_token( token => $re_NoTag, $convert_NoTag );
}

package main;

my $parser = TestParser->new;

$re = qr/[A-Z]+/;
is( $parser->from_string( "HELLO" ), "HELLO", 'Simple RE' );
is_deeply( $parser->{spaces}, { }, q("HELLO" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("HELLO" tagged) );
  is( $tagged->get_tag_at( 0, 'Generic_Token' ), 1, q("HELLO" tag 1 start) );
  is( $tagged->get_tag_at( 4, 'Generic_Token' ), 1, q("HELLO" tag 1 end) );
}

ok( !eval { $parser->from_string( "hello" ) }, 'Simple RE fails' );

$re = qr/[A-Z]+/i;
is( $parser->from_string( "Hello" ), "Hello", 'RE with flags' );
is_deeply( $parser->{spaces}, { }, q("Hello" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("Hello" tagged) );
  is( $tagged->get_tag_at( 0, 'Generic_Token' ), 1, q("Hello" tag 1 start) );
  is( $tagged->get_tag_at( 4, 'Generic_Token' ), 1, q("Hello" tag 1 end) );
}

$convert = sub { lc $_[1] };
is( $parser->from_string( "Hello" ), "hello", 'Conversion function' );
is_deeply( $parser->{spaces}, { }, q("Hello" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("Hello" tagged) );
  is( $tagged->get_tag_at( 0, 'Generic_Token' ), 1, q("Hello" tag 1 start) );
  is( $tagged->get_tag_at( 4, 'Generic_Token' ), 1, q("Hello" tag 1 end) );
}

$parser = TestParser_NoTag->new;

$re_NoTag = qr/[A-Z]+/;
is( $parser->from_string( "HELLO" ), "HELLO", 'Simple RE' );
is_deeply( $parser->{spaces}, { }, q("HELLO" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("HELLO" tags) );

done_testing;
