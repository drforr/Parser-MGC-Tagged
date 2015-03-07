#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

package TestParser;
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

   return [ $self->token_string, $self->token_string ];
}

package main;
#$ENV{DEBUG} = 1;

my $parser = TestParser->new;

is( $parser->from_string( q['single'] ), "single", 'Single quoted string' );
is_deeply( $parser->{spaces}, { }, q(q['single] spaces) );
is( $parser->from_string( q["double"] ), "double", 'Double quoted string' );
is_deeply( $parser->{spaces}, { }, q(q["double"] spaces) );

is( $parser->from_string( q["foo 'bar'"] ), "foo 'bar'", 'Double quoted string containing single substr' );
is_deeply( $parser->{spaces}, { }, q(q["foo 'bar'"] spaces) );
is( $parser->from_string( q['foo "bar"'] ), 'foo "bar"', 'Single quoted string containing double substr' );
is_deeply( $parser->{spaces}, { }, q(q['foo "bar"'] spaces) );

is( $parser->from_string( q["tab \t"]       ), "tab \t",       '\t' );
is_deeply( $parser->{spaces}, { }, q(q["tab \t"] spaces) );
is( $parser->from_string( q["newline \n"]   ), "newline \n",   '\n' );
is_deeply( $parser->{spaces}, { }, q(q["newline \n"] spaces) );
is( $parser->from_string( q["return \r"]    ), "return \r",    '\r' );
is_deeply( $parser->{spaces}, { }, q(q["return \r"] spaces) );
is( $parser->from_string( q["form feed \f"] ), "form feed \f", '\f' );
is_deeply( $parser->{spaces}, { }, q(q["tform feed \f"] spaces) );
is( $parser->from_string( q["backspace \b"] ), "backspace \b", '\b' );
is_deeply( $parser->{spaces}, { }, q(q["backspace \b"] spaces) );
is( $parser->from_string( q["bell \a"]      ), "bell \a",      '\a' );
is_deeply( $parser->{spaces}, { }, q(q["bell \a"] spaces) );
is( $parser->from_string( q["escape \e"]    ), "escape \e",    '\e' );
is_deeply( $parser->{spaces}, { }, q(q["escape \e"] spaces) );

# ord('A') == 65 == 0101 == 0x41 
#  TODO: This is ASCII dependent. If anyone on EBCDIC cares, do let me know...
is( $parser->from_string( q["null \0"] ),         "null \0",         'Octal null' );
is_deeply( $parser->{spaces}, { }, q(q["null \0"] spaces) );
is( $parser->from_string( q["octal \101BC"] ),    "octal ABC",       'Octal' );
is_deeply( $parser->{spaces}, { }, q(q["octal \101BC"] spaces) );
is( $parser->from_string( q["hex \x41BC"] ),      "hex ABC",         'Hexadecimal' );
is_deeply( $parser->{spaces}, { }, q(q["hex \x41BC"] spaces) );
is( $parser->from_string( q["unihex \x{263a}"] ), "unihex \x{263a}", 'Unicode hex' );
is_deeply( $parser->{spaces}, { }, q(q["unihex \x{263a}] spaces) );

$parser = TestParser->new(
   patterns => { string_delim => qr/"/ }
);

is( $parser->from_string( q["double"] ), "double", 'Double quoted string still passes' );
is_deeply( $parser->{spaces}, { }, q(q["double"] spaces) );
ok( !eval { $parser->from_string( q['single'] ) }, 'Single quoted string now fails' );
is_deeply( $parser->{spaces}, { }, q(q['single'] spaces) );

$parser = StringPairParser->new;

is_deeply( $parser->from_string( q["foo" "bar"] ),
           [ "foo", "bar" ],
           'String-matching pattern is non-greedy' );
is_deeply( $parser->{spaces},
  { 5 => 6 },
  q("foo" "bar" spaces) );

done_testing;
