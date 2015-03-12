#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_string( String => 1 );
}

package TestParser_NoTag;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return $self->token_string;
}

package StringPairParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return [ $self->token_string( String_1 => 1 ),
            $self->token_string( String_2 => 1 ) ];
}

package main;

my $parser = TestParser->new;

is( $parser->from_string( q['single'] ), "single", 'Single quoted string' );
is_deeply( $parser->{spaces}, { }, q(q['single'] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 8, String => 1 ] ],
  q(q['single'] tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q['single'] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q['single'] tag start) );
  is( $tagged->get_tag_at( 7, 'String' ), 1, q(q['single'] tag end) );
}

is( $parser->from_string( q["double"] ), "double", 'Double quoted string' );
is_deeply( $parser->{spaces}, { }, q(q["double"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 8, String => 1 ] ],
  q(q["double"] tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["double"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["double"] tag start) );
  is( $tagged->get_tag_at( 7, 'String' ), 1, q(q["double"] tag end) );
}

is( $parser->from_string( q["foo 'bar'"] ),
    "foo 'bar'",
    'Double quoted string containing single substr' );
is_deeply( $parser->{spaces}, { }, q(q["foo 'bar'"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 11, String => 1 ] ],
  q(q["foo 'bar'"] tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["foo 'bar'"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["foo 'bar'"] tag start) );
  is( $tagged->get_tag_at( 10, 'String' ), 1, q(q["foo 'bar'"] tag end) );
}

is( $parser->from_string( q['foo "bar"'] ),
    'foo "bar"', 
    'Single quoted string containing double substr' );
is_deeply( $parser->{spaces}, { }, q(q['foo "bar"'] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q['foo "bar"'] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q['foo "bar"'] tag start) );
  is( $tagged->get_tag_at( 10, 'String' ), 1, q(q['foo "bar"'] tag end) );
}

is( $parser->from_string( q["tab \t"] ), "tab \t", '\t' );
is_deeply( $parser->{spaces}, { }, q(q["tab \t"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["tab \t"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["tab \t"] tag start) );
  is( $tagged->get_tag_at( 7, 'String' ), 1, q(q["tab \t"] tag end) );
}

is( $parser->from_string( q["newline \n"] ), "newline \n", '\n' );
is_deeply( $parser->{spaces}, { }, q(q["newline \n"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 12, String => 1 ] ],
  q(q["newline \n"] tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["newline \n"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["newline \n"] tag start) );
  is( $tagged->get_tag_at( 11, 'String' ), 1, q(q["newline \n"] tag end) );
}

is( $parser->from_string( q["return \r"] ), "return \r", '\r' );
is_deeply( $parser->{spaces}, { }, q(q["return \r"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["return \r"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["return \r"] tag start) );
  is( $tagged->get_tag_at( 10, 'String' ), 1, q(q["return \r"] tag end) );
}

is( $parser->from_string( q["form feed \f"] ), "form feed \f", '\f' );
is_deeply( $parser->{spaces}, { }, q(q["tform feed \f"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 14, String => 1 ] ],
  q(q["form feed \f"] tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["form feed \f"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["form feed \f"] tag start) );
  is( $tagged->get_tag_at( 13, 'String' ), 1, q(q["form feed \f"] tag end) );
}

is( $parser->from_string( q["backspace \b"] ), "backspace \b", '\b' );
is_deeply( $parser->{spaces}, { }, q(q["backspace \b"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["backspace \b"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["backspace \b"] tag start) );
  is( $tagged->get_tag_at( 13, 'String' ), 1, q(q["backspace \b"] tag end) );
}

is( $parser->from_string( q["bell \a"] ), "bell \a", '\a' );
is_deeply( $parser->{spaces}, { }, q(q["bell \a"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["bell \a"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["bell \a"] tag start) );
  is( $tagged->get_tag_at( 8, 'String' ), 1, q(q["bell \a"] tag end) );
}

is( $parser->from_string( q["escape \e"] ), "escape \e", '\e' );
is_deeply( $parser->{spaces}, { }, q(q["escape \e"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["escape \e"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["escape \e"] tag start) );
  is( $tagged->get_tag_at( 10, 'String' ), 1, q(q["escape \e"] tag end) );
}

# ord('A') == 65 == 0101 == 0x41 
#  TODO: This is ASCII dependent. If anyone on EBCDIC cares, do let me know...
is( $parser->from_string( q["null \0"] ), "null \0", 'Octal null' );
is_deeply( $parser->{spaces}, { }, q(q["null \0"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["null \0"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["null \0"] tag start) );
  is( $tagged->get_tag_at( 8, 'String' ), 1, q(q["null \0"] tag end) );
}

is( $parser->from_string( q["octal \101BC"] ), "octal ABC", 'Octal' );
is_deeply( $parser->{spaces}, { }, q(q["octal \101BC"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["octal \101BC"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["octal \101BC"] tag start) );
  is( $tagged->get_tag_at( 13, 'String' ), 1, q(q["octal \101BC"] tag end) );
}

is( $parser->from_string( q["hex \x41BC"] ), "hex ABC", 'Hexadecimal' );
is_deeply( $parser->{spaces}, { }, q(q["hex \x41BC"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["hex \x41BC"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["hex \x41BC"] tag start) );
  is( $tagged->get_tag_at( 11, 'String' ), 1, q(q["hex \x41BC"] tag end) );
}

is( $parser->from_string( q["unihex \x{263a}"] ),
    "unihex \x{263a}",
    'Unicode hex' );
is_deeply( $parser->{spaces}, { }, q(q["unihex \x{263a}] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["unihex \x{263a}"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1,
      q(q["unihex \x{263a}"] tag start) );
  is( $tagged->get_tag_at( 16, 'String' ), 1,
      q(q["unihex \x{263a}"] tag end) );
}

$parser = TestParser->new(
   patterns => { string_delim => qr/"/ }
);

is( $parser->from_string( q["double"] ), "double", 'Double quoted string still passes' );
is_deeply( $parser->{spaces}, { }, q(q["double"] spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q["double"] tagged) );
  is( $tagged->get_tag_at( 0, 'String' ), 1, q(q["double"] tag start) );
  is( $tagged->get_tag_at( 7, 'String' ), 1, q(q["double"] tag end) );
}

ok( !eval { $parser->from_string( q['single'] ) }, 'Single quoted string now fails' );

$parser = StringPairParser->new;

is_deeply( $parser->from_string( q["foo" "bar"] ),
           [ "foo", "bar" ],
           'String-matching pattern is non-greedy' );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("foo" "bar" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 5, String_1 => 1 ],
    [ 6, 11, String_2 => 1 ] ],
  q(q["foo" "bar"] tags) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q(q[""foo", "bar""] tagged) );
  is( $tagged->get_tag_at( 0, 'String_1' ), 1, q(q[""foo", "bar""] tag start) );
  is( $tagged->get_tag_at( 4, 'String_1' ), 1, q(q[""foo", "bar""] tag end) );
  is( $tagged->get_tag_at( 6, 'String_2' ), 1, q(q[""foo", "bar""] tag start) );
  is( $tagged->get_tag_at( 10, 'String_2' ), 1, q(q[""foo", "bar""] tag end) );
}

$parser = TestParser_NoTag->new;

is( $parser->from_string( q['single'] ), "single", 'Single quoted string' );
is_deeply( $parser->{spaces}, { }, q(q['single'] spaces) );
is_deeply( $parser->{tags}, [ ], q(q['single'] tags) );
is_deeply( $parser->tagged->get_tags_at( 0 ), { }, q(q['single"] tags) );

done_testing;
