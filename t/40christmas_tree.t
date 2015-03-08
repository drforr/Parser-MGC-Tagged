#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

############################################################333
#
# X from_string
# X scope_level
# X maybe
# X scope_of
# X list_of
# X sequence_of
# X any_of
# X commit
# X maybe_expect # wantarray
# X expect # wantarray
# X generic_token
# X _token_generic
# X token_int
# X token_float
# X token_number
# X token_string
# X token_ident
# X token_kw
#
############################################################333

package ChristmasTree;
use base qw( Parser::MGC::Tagged );

sub parse {
  my $self = shift;

  [
    # The basic token types
    # '1'
    $self->token_int ( Int_1 => 1 ),

    # '2.3'
    $self->token_float ( Float_2 => 1 ),

    # '2.0'
    $self->token_float ( Float_3 => 1 ),

    # '0x4'
    $self->token_number ( Number_4 => 1 ),

    # q{'string'}
    $self->token_string ( String_5 => 1 ),

    # 'ident'
    $self->token_ident ( Ident_6 => 1 ),

    # 'keyword'
    $self->token_kw( qw( keyword ), [ Keyword_7 => 1 ] ),

    # 'generic'
    $self->generic_token( generic => qr/generic/, sub { $_[1] },
      [ Generic_Token_8 => 1 ]
    ),

    # '5'
    # Alternation with no fallthrough
    $self->any_of( sub { $self->token_int ( Int_9 => 1 ) }, [ Any_Of => 1 ] ),

    # 'fail'
    # Alternation with fallthrough ('fail' does not match token_int())
    $self->any_of(
      sub { $self->token_int ( Int_10 => 1 ) },
      sub { $self->token_string ( String_11 => 1 ) },
      [ Any_Of => 1 ]
    ),

    # 'commit'
    # Alternation with fallthrough and commit
    $self->any_of(
      sub { $self->token_int ( Int_12 => 1 ) },
      sub {
        $self->commit;
        $self->token_string ( String_13 => 1 )
      },
      [ Any_Of => 1 ]
    ),

    # '6', '7'
    $self->list_of(
      ',',
      sub { $self->token_int ( Int_14 => 1 ) },
      [ List_Of => 1 ]
    ),

    # '8'
    # scope_of() calls expect() internally, so call it inside.
    $self->scope_of(
        '(',
        sub { $self->expect( '8', [ Expect_15 => 1 ] ) },
        ')',
      [ Scope_Of => 1 ]
    ),

    # '9', '10'
    $self->sequence_of(
       sub { $self->token_int ( Int_16 => 1 ) },
      [ Sequence_Of => 1 ]
    ),

    # '' (pos() at 'a' but token_int() fails to match)
    # maybe() failing
    $self->maybe( sub { $self->token_int ( Int_17 => 1 ) } ),

    # 'a'
    # maybe() passing
    $self->maybe( sub { $self->expect( 'a', [ Expect_18 => 1 ] ) } ),

    # 'b'
    # expect() on its own.
    $self->expect( 'b', [ Expect_19 => 1 ] ),

    # ''
    # maybe_expect() on its own failing
    $self->maybe_expect( 'b', [ Maybe_Expect_20 => 1 ] ),

    # 'c'
    # maybe_expect() passing
    $self->maybe_expect( 'c', [ Maybe_Expect_21 => 1 ] ),
  ]
}

package main;

my $parser = ChristmasTree->new;

#
# All Parser::MGC base methods in a single invocation
#
#1 2.3 2.0 0x4 'string' ident keyword generic 5 'fail' 'commit' 6, 7 ( 8 ) 9 10 a b c";
my $parse_me = 
  "1 2.3 2.0 0x4 'string' ident keyword generic 5 'fail' 'commit' 6, 7 ( 8 ) 9 10 a b c";
is_deeply(
  $parser->from_string( $parse_me ),
  [ 1, 2.3, 2.0, 0x4,
    'string', 'ident', 'keyword', 'generic', 5, 'fail', 'commit',
    [ 6, 7 ], 8, [ 9, 10 ], undef, 'a', 'b', 'c'
  ],
  "(Christmas Tree test)"
);

is_deeply( $parser->{spaces},
  { 1 => 2, 5 => 6, 9 => 10, 13 => 14, 22 => 23, 28 => 29, 36 => 37, 44 => 45, 46 => 47, 53 => 54, 62 => 63, 65 => 66, 67 => 68, 69 => 70, 71 => 72, 73 => 74, 75 => 76, 78 => 79, 80 => 81, 82 => 83  },
  q("$parse_me" spaces) );
is_deeply( $parser->{tags},
  [ [ 0, 1, Int_1 => 1 ],
    [ 2, 5, Float_2 => 1 ],
    [ 6, 9, Float_3 => 1 ],
    [ 10, 13, Number_4 => 1 ],
    [ 14, 22, String_5 => 1 ],
    [ 23, 28, Ident_6 => 1 ],
    [ 29, 36, Keyword_7 => 1 ],
    [ 37, 44, Generic_Token_8 => 1 ],
    [ 45, 46, Int_9 => 1 ],
    [ 44, 46, Any_Of => 1 ],
    [ 47, 53, String_11 => 1 ],
    [ 46, 53, Any_Of => 1 ],
    [ 54, 62, String_13 => 1 ],
    [ 53, 62, Any_Of => 1 ],
    [ 63, 64, Int_14 => 1 ],
    [ 66, 67, Int_14 => 1 ],
    [ 63, 67, List_Of => 1 ],
    [ 69, 71, Expect_15 => 1 ],
    [ 68, 73, Scope_Of => 1 ],
    [ 74, 75, Int_16 => 1 ],
    [ 76, 78, Int_16 => 1 ],
    [ 74, 78, Sequence_Of => 1 ],
    [ 78, 80, Expect_18 => 1 ],
    [ 81, 82, Expect_19 => 1 ],
    [ 83, 84, Maybe_Expect_21 => 1 ] ],
  q("$parse_me" tags) );
is_deeply( $parser->{delimiters},
  [ [ 68, 69 ],
    [ 71, 73 ],
  ],
  q("$parse_me" delimiters) );

done_testing;
