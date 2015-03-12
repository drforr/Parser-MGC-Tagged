#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   my @tokens;
   push @tokens,
     $self->expect( qr/[a-z]+/, [ Expect => 1 ] ) while !$self->at_eos;

   return \@tokens;
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   my @tokens;
   push @tokens,
     $self->expect( qr/[a-z]+/ ) while !$self->at_eos;

   return \@tokens;
}

package main;

my $parser = TestParser->new;

my @strings = (
   "here is a list ",
   "of some more ",
   "tokens"
);

is_deeply( $parser->from_reader( sub { return shift @strings } ),
   [qw( here is a list of some more tokens )],
   'tokens from reader' );
is_deeply( $parser->{spaces},
  { 4 => 5, 7 => 8, 9 => 10, # "here is a list "
    14 => 15, 17 => 18, 22 => 23, 27 => 28 # "of some more "
  },
  q("here is a list ", "of some more ", "tokens" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("here is a list..." tagged) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("here is a ..." tag 1 start) );
  is( $tagged->get_tag_at( 3, 'Expect' ), 1, q("here is a ..." tag 1 end) );
  is( $tagged->get_tag_at( 5, 'Expect' ), 1, q("here is a ..." tag 2 start) );
  is( $tagged->get_tag_at( 6, 'Expect' ), 1, q("here i a ..." tag 2 end) );
  is( $tagged->get_tag_at( 8, 'Expect' ), 1, q("here i a ..." tag 3) );
  is( $tagged->get_tag_at( 10, 'Expect' ), 1, q("here is a ..." tag 4 start) );
  is( $tagged->get_tag_at( 13, 'Expect' ), 1, q("here i a ..." tag 4 end) );
  is( $tagged->get_tag_at( 15, 'Expect' ), 1, q("here is a ..." tag 5 start) );
  is( $tagged->get_tag_at( 16, 'Expect' ), 1, q("here i a ..." tag 5 end) );
  # ... And so on, as long as I've gotten over a boundary I'm happy.
}

$parser = TestParser_NoTag->new;

@strings = (
   "here is a list ",
   "of some more ",
   "tokens"
);

is_deeply( $parser->from_reader( sub { return shift @strings } ),
   [qw( here is a list of some more tokens )],
   'tokens from reader' );
is_deeply( $parser->{spaces},
  { 4 => 5, 7 => 8, 9 => 10, # "here is a list "
    14 => 15, 17 => 18, 22 => 23, 27 => 28 # "of some more "
  },
  q("here is a list ", "of some more ", "tokens" spaces) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("here is a list..." tags) );

done_testing;
