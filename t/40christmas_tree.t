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
    $self->any_of( sub { $self->token_int ( Int_9 => 1 ) },
      [ Any_Of_10 => 1 ]
    ),

    # 'fail'
    # Alternation with fallthrough ('fail' does not match token_int())
    $self->any_of(
      sub { $self->token_int ( Int_11 => 1 ) },
      sub { $self->token_string ( String_12 => 1 ) },
      [ Any_Of_13 => 1 ]
    ),

    # 'commit'
    # Alternation with fallthrough and commit
    $self->any_of(
      sub { $self->token_int ( Int_14 => 1 ) },
      sub {
        $self->commit;
        $self->token_string ( String_15 => 1 )
      },
      [ Any_Of_16 => 1 ]
    ),

    # '6', '7'
    $self->list_of(
      ',',
      sub { $self->token_int ( Int_17 => 1 ) },
      [ List_Of_18 => 1 ]
    ),

    # '8'
    # scope_of() calls expect() internally, so call it inside.
    $self->scope_of(
      '(',
      sub { $self->expect( '8', [ Expect_19 => 1 ] ) },
      ')',
      [ Scope_Of_20 => 1 ]
    ),

    # '9', '10'
    $self->sequence_of(
      sub { $self->token_int ( Int_21 => 1 ) },
      [ Sequence_Of_22 => 1 ]
    ),

    # '' (pos() at 'a' but token_int() fails to match)
    # maybe() failing
    $self->maybe( sub { $self->token_int ( Int_23 => 1 ) } ),

    # 'a'
    # maybe() passing
    $self->maybe( sub { $self->expect( 'a', [ Expect_24 => 1 ] ) } ),

    # 'b'
    # expect() on its own.
    $self->expect( 'b', [ Expect_25 => 1 ] ),

    # ''
    # maybe_expect() on its own failing
    $self->maybe_expect( 'b', [ Maybe_Expect_21 => 1 ] ),

    # 'c'
    # maybe_expect() passing
    $self->maybe_expect( 'c', [ Maybe_Expect_27 => 1 ] ),
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
  { 1 => 2, 5 => 6, 9 => 10, 13 => 14, 22 => 23, 28 => 29, 36 => 37, 44 => 45,
    46 => 47, 53 => 54, 62 => 63, 65 => 66, 67 => 68, 69 => 70, 71 => 72,
    73 => 74, 75 => 76, 78 => 79, 80 => 81, 82 => 83  },
  q("$parse_me" spaces) );
{
  my $tagged = $parser->tagged;
  isa_ok( $tagged, 'String::Tagged', q("foo" tagged) );
  is( $tagged->get_tag_at( 0, 'Int_1' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 0, 'Int_1' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 2, 'Float_2' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 4, 'Float_2' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 6, 'Float_3' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 8, 'Float_3' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 10, 'Number_4' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 12, 'Number_4' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 14, 'String_5' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 20, 'String_5' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 23, 'Ident_6' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 27, 'Ident_6' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 29, 'Keyword_7' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 35, 'Keyword_7' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 37, 'Generic_Token_8' ), 1,
      q(Christmas tree start) );
  is( $tagged->get_tag_at( 43, 'Generic_Token_8' ), 1,
      q(Christmas tree end) );
  is( $tagged->get_tag_at( 45, 'Int_9' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 45, 'Int_9' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 45, 'Any_Of_10' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 45, 'Any_Of_10' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 47, 'String_12' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 52, 'String_12' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 47, 'Any_Of_13' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 52, 'Any_Of_13' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 54, 'String_15' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 61, 'String_15' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 54, 'Any_Of_16' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 61, 'Any_Of_16' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 63, 'Int_17' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 66, 'Int_17' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 63, 'List_Of_18' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 66, 'List_Of_18' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 70, 'Expect_19' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 70, 'Expect_19' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 68, 'Scope_Of_20' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 72, 'Scope_Of_20' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 74, 'Int_21' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 74, 'Int_21' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 76, 'Int_21' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 77, 'Int_21' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 74, 'Sequence_Of_22' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 77, 'Sequence_Of_22' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 79, 'Expect_24' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 79, 'Expect_24' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 81, 'Expect_25' ), 1, q(Christmas tree start) );
  is( $tagged->get_tag_at( 81, 'Expect_25' ), 1, q(Christmas tree end) );
  is( $tagged->get_tag_at( 83, 'Maybe_Expect_27' ), 1,
      q(Christmas tree start) );
  is( $tagged->get_tag_at( 83, 'Maybe_Expect_27' ), 1, 
     q(Christmas tree end) );
}
is_deeply( $parser->{delimiters},
  [ [ 68, 69 ],
    [ 72, 73 ],
  ],
  q("$parse_me" delimiters) );

done_testing;
