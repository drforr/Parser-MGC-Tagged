#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->expect( "hello" );
   $self->expect( qr/world/ );

   return 1;
}

package main;
#$ENV{DEBUG}=1;

my $parser = TestParser->new;

ok( $parser->from_string( "hello world" ), '"hello world"' );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("hello world") );
ok( $parser->from_string( "hello\nworld" ), '"hello\nworld"' );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("hello\nworld") );
ok( !eval { $parser->from_string( "hello\n# Comment\nworld" ) }, '"hello world" with comment fails' );

$parser = TestParser->new(
   patterns => { comment => qr/#.*\n/ },
);

ok( $parser->from_string( "hello\n# Comment\nworld" ), '"hello world" with comment passes' );
is_deeply( $parser->{spaces},
  { 5 => 16 },
  q("hello\n# Comment\nworld") );

done_testing;
