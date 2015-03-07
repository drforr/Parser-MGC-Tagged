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

package StringPairParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   return [ $self->token_string( String1 => 1 ),
            $self->token_string( String2 => 1 ) ];
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( q['single'] ), "single", 'Single quoted string' );
is_deeply( $parser->{spaces}, { }, q(q['single'] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 8, String => 1 ] ],
  q(q['single'] tags) );

is( $parser->from_string( q["double"] ), "double", 'Double quoted string' );
is_deeply( $parser->{spaces}, { }, q(q["double"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 8, String => 1 ] ],
  q(q["double"] tags) );

is( $parser->from_string( q["foo 'bar'"] ), "foo 'bar'", 'Double quoted string containing single substr' );
is_deeply( $parser->{spaces}, { }, q(q["foo 'bar'"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 11, String => 1 ] ],
  q(q["foo 'bar'"] tags) );

is( $parser->from_string( q['foo "bar"'] ), 'foo "bar"', 'Single quoted string containing double substr' );
is_deeply( $parser->{spaces}, { }, q(q['foo "bar"'] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 11, String => 1 ] ],
  q(q['foo "bar"'] tags) );

is( $parser->from_string( q["tab \t"]       ), "tab \t",       '\t' );
is_deeply( $parser->{spaces}, { }, q(q["tab \t"] spaces) );
is_deeply( $parser->{tags}, [ [ 0, 8, String => 1 ] ], q(q["tab \t"] tags) );

is( $parser->from_string( q["newline \n"]   ), "newline \n",   '\n' );
is_deeply( $parser->{spaces}, { }, q(q["newline \n"] spaces) );
is_deeply( $parser->{tags}, [ [ 0, 12, String => 1 ] ], q(q["newline \n"] tags) );

is( $parser->from_string( q["return \r"]    ), "return \r",    '\r' );
is_deeply( $parser->{spaces}, { }, q(q["return \r"] spaces) );
is_deeply( $parser->{tags}, [ [ 0, 11, String => 1 ] ], q(q["return \r"] tags) );

is( $parser->from_string( q["form feed \f"] ), "form feed \f", '\f' );
is_deeply( $parser->{spaces}, { }, q(q["tform feed \f"] spaces) );
is_deeply( $parser->{tags}, [ [ 0, 14, String => 1 ] ], q(q["form feed \f"] tags) );

is( $parser->from_string( q["backspace \b"] ), "backspace \b", '\b' );
is_deeply( $parser->{spaces}, { }, q(q["backspace \b"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 14, String => 1 ] ],
  q(q["backspace \b"] tags) );

is( $parser->from_string( q["bell \a"]      ), "bell \a",      '\a' );
is_deeply( $parser->{spaces}, { }, q(q["bell \a"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 9, String => 1 ] ],
  q(q["bell \a"] tags) );

is( $parser->from_string( q["escape \e"]    ), "escape \e",    '\e' );
is_deeply( $parser->{spaces}, { }, q(q["escape \e"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 11, String => 1 ] ],
  q(q["escape \e"] tags) );

# ord('A') == 65 == 0101 == 0x41 
#  TODO: This is ASCII dependent. If anyone on EBCDIC cares, do let me know...
is( $parser->from_string( q["null \0"] ),         "null \0",         'Octal null' );
is_deeply( $parser->{spaces}, { }, q(q["null \0"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 9, String => 1 ] ],
  q(q["null \0"] tags) );

is( $parser->from_string( q["octal \101BC"] ),    "octal ABC",       'Octal' );
is_deeply( $parser->{spaces}, { }, q(q["octal \101BC"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 14, String => 1 ] ],
  q(q["octal \101BC"] tags) );

is( $parser->from_string( q["hex \x41BC"] ),      "hex ABC",         'Hexadecimal' );
is_deeply( $parser->{spaces}, { }, q(q["hex \x41BC"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 12, String => 1 ] ],
  q(q["hex \x41BC"] tags) );

is( $parser->from_string( q["unihex \x{263a}"] ), "unihex \x{263a}", 'Unicode hex' );
is_deeply( $parser->{spaces}, { }, q(q["unihex \x{263a}] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 17, String => 1 ] ],
  q(q["unihex \x{263a}"] tags) );

$parser = TestParser->new(
   patterns => { string_delim => qr/"/ }
);

is( $parser->from_string( q["double"] ), "double", 'Double quoted string still passes' );
is_deeply( $parser->{spaces}, { }, q(q["double"] spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 8, String => 1 ] ],
  q(q["double"] tags) );

ok( !eval { $parser->from_string( q['single'] ) }, 'Single quoted string now fails' );
is_deeply( $parser->{spaces}, { }, q(q['single'] spaces) );
is_deeply( $parser->{tags}, [ ], q(q['single'] tags) );

$parser = StringPairParser->new;

is_deeply( $parser->from_string( q["foo" "bar"] ),
           [ "foo", "bar" ],
           'String-matching pattern is non-greedy' );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("foo" "bar" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 5, String1 => 1 ], [ 5, 11, String2 => 1 ] ],
  q(q["foo" "bar"] tags) );

done_testing;
