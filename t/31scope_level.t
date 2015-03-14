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
        sub { $self->expect( qr/[a-z]+/, [ Expect => 1 ] ) .
                             "/" . $self->scope_level },
        sub { $self->scope_of( "(", \&parse, ")", [ Scope_Of => 1 ] ) },
        [ Any_Of => 1 ]
      );
    },
    [ Sequence_Of => 1 ]
  );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
  my $self = shift;

  $self->sequence_of( 
    sub {
      $self->any_of(
        sub { $self->expect( qr/[a-z]+/ ) . "/" . $self->scope_level },
        sub { $self->scope_of( "(", \&parse, ")" ) }
      );
    }
  );
}

package main;

my $parser = TestParser->new;

is_deeply( $parser->from_string( "a" ), [ "a/0" ], 'a' );
is_deeply( $parser->{spaces}, { }, q("a" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("a" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("a" tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("a" tag end) );
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1, q("a" tag end) );
}

is_deeply( $parser->from_string( "(b)" ), [ [ "b/1" ] ], '(b)' );
is_deeply( $parser->{spaces}, { }, q("(b)" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("a" tagged) );
  is( $tagged->get_tag_at( 1, 'Expect' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 1, 'Expect' ), 1, q("a" tag end) );
  is( $tagged->get_tag_at( 1, 'Any_Of' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 1, 'Any_Of' ), 1, q("a" tag end) );
  is( $tagged->get_tag_at( 1, 'Sequence_Of' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 1, 'Sequence_Of' ), 1, q("a" tag end) );
  is( $tagged->get_tag_at( 0, 'Scope_Of' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 2, 'Scope_Of' ), 1, q("a" tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 2, 'Any_Of' ), 1, q("a" tag end) );
  is( $tagged->get_tag_at( 0, 'Sequence_Of' ), 1, q("a" tag start) );
  is( $tagged->get_tag_at( 2, 'Sequence_Of' ), 1, q("a" tag end) );
}
is_deeply( $parser->{delimiters},
  [ [ 0, 1 ],
    [ 2, 3 ] ],
  q("(b)" tags) );

is_deeply( $parser->from_string( "c (d) e" ),
  [ "c/0", [ "d/1" ], "e/0" ],
  'c (d) e' );
is_deeply( $parser->{spaces},
  { 1 => 2, 5 => 6 },
  q("c (d) e" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("c (d) e" tagged) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 0, 'Expect' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 0, 'Any_Of' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 3, 'Expect' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 3, 'Expect' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 3, 'Any_Of' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 3, 'Any_Of' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 3, 'Sequence_Of' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 3, 'Sequence_Of' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 2, 'Scope_Of' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 4, 'Scope_Of' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 2, 'Any_Of' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 4, 'Any_Of' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 6, 'Expect' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 6, 'Expect' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 6, 'Any_Of' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 6, 'Any_Of' ), 1, q("c (d) e" tag end) );
  is( $tagged->get_tag_at( 6, 'Sequence_Of' ), 1, q("c (d) e" tag start) );
  is( $tagged->get_tag_at( 6, 'Sequence_Of' ), 1, q("c (d) e" tag end) );
}
is_deeply( $parser->{delimiters},
  [ [ 2, 3 ],
    [ 4, 5 ] ],
  q("c (d) e" delimiters) );
#use YAML;die Dump $parser->{tags};

$parser = TestParser_NoTag->new;

is_deeply( $parser->from_string( "a" ), [ "a/0" ], 'a' );
is_deeply( $parser->{spaces}, { }, q("a" spaces) );
is_deeply( $parser->{tags}, [ ], q("a" tags) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q("a" tags) );

done_testing;
