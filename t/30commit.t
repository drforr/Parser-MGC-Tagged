#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->any_of(
      sub { $self->token_int( Int => 1 ) },
      sub {
         $self->scope_of( "(",
            sub {
               $self->commit;
               $self->token_string( String => 1 );
            },
            ")",
           [ Scope_Of => 1 ] );
      },
      [ Any_Of => 1 ]
   );
}

package IntStringPairsParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->sequence_of( sub {
      my $int = $self->token_int( Int => 1 );
      $self->commit;

      my $str = $self->token_string( String => 1 );

      [ $int, $str ];
   },
  [ Sequence_Of => 1 ] );
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( "123" ), 123, '"123"' );
is_deeply( $parser->{spaces}, { }, q("123" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 3, Int => 1 ],
    [ 0, 3, Any_Of => 1 ] ],
  q("123" tags) );

is( $parser->from_string( '("hi")' ), "hi", '("hi")' );
is_deeply( $parser->{spaces}, { }, q['("hi")' spaces] );
is_deeply( $parser->{tags},
  [ [ 1, 5, String => 1 ],
    [ 0, 6, Scope_Of => 1 ],
    [ 0, 6, Any_Of => 1 ] ],
  q['("hi")' tags] );
is_deeply( $parser->{delimiters},
  [ [ 0, 1 ],
    [ 5, 6 ] ],
  q['("hi")' delimiters] );

ok( !eval { $parser->from_string( "(456)" ) }, '"(456)" fails' );
is( $@,
   qq[Expected string delimiter on line 1 at:\n].
   qq[(456)\n].
   qq[ ^\n],
   'Exception from "(456)" failure' );

$parser = IntStringPairsParser->new;

is_deeply( $parser->from_string( "1 'one' 2 'two'" ),
           [ [ 1, "one" ], [ 2, "two" ] ],
           "1 'one' 2 'two'" );
is_deeply( $parser->{spaces},
  { 1 => 2, 7 => 8, 9 => 10 },
  q("1 'one' 2 'two'" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Int => 1 ],
    [ 1, 7, String => 1 ],
    [ 8, 9, Int => 1 ],
    [ 9, 15, String => 1 ],
    [ 0, 15, Sequence_Of => 1 ] ],
  q("1 'one' 2 'two'" tags) );

ok( !eval { $parser->from_string( "1 'one' 2" ) }, "1 'one' 2 fails" );
is( $@,
    qq[Expected string on line 1 at:\n].
    qq[1 'one' 2\n].
    qq[         ^\n],
    'Exception from 1 \'one\' 2 failure' );

done_testing;
