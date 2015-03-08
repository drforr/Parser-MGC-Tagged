#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->sequence_of( 
      sub {
         $self->any_of(
            sub { $self->expect( qr/[a-z]+/, [ Expect => 1 ] ) . "/" . $self->scope_level },
            sub { $self->scope_of( "(", \&parse, ")", [ Scope => 1 ] ) },
           [ Any_Of => 1 ]
         );
      },
     [ Sequence_Of => 1 ]
   );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is_deeply( $parser->from_string( "a" ), [ "a/0" ], 'a' );
is_deeply( $parser->{spaces}, { }, q("a" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Expect => 1 ], [ 0, 1, Any_Of => 1 ], [ 0, 1, Sequence_Of => 1 ] ],
  q("a" tags) );

is_deeply( $parser->from_string( "(b)" ), [ [ "b/1" ] ], '(b)' );
is_deeply( $parser->{spaces}, { }, q("(b)" spaces) );

is_deeply( $parser->from_string( "c (d) e" ), [ "c/0", [ "d/1" ], "e/0" ], 'c (d) e' );
is_deeply( $parser->{spaces},
  { 1 => 2, 5 => 6 },
  q("c (d) e" spaces) );

done_testing;
