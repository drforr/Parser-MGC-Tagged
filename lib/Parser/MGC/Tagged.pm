use strict;
use warnings;
package Parser::MGC::Tagged;

use base 'Parser::MGC';

use String::Tagged;

# ABSTRACT: foo

our $VERSION = '0.12';

=head1 NAME

C<Parser::MGC::Tagged> - Tag the parsed string with String;:Tagged

=head1 SYNOPSIS

 package My::Grammar::Parser::Tagged
 use base qw( Parser::MGC::Tagged );

 sub parse
 {
    my $self = shift;

    $self->sequence_of( sub {
       $self->any_of(
          sub { $self->token_int( Integer => 0 ) },
          sub { $self->token_string( String => 0 ) },
          sub { \$self->token_ident( Ident => 0 ) },
          sub { $self->scope_of( "(", \&parse, ")", [ Scope => 0 ] ) }
       );
    } );
 }

 my $parser = My::Grammar::Parser->new;

 my $tree = $parser->from_file( $ARGV[0] );

 my $tagged_output = $tree->tagged;

 ...

 $tagged_output->iter_substr_nooverlap( sub {
   my ( $substring, %tags ) = @_;

   print $tags{Integer} ? "<div id='Integer'>$substring</div>" : 
          $tags{String} ? "<div id='String'>$substring</div>" :
           $tags{Ident} ? "<div id='Ident'>$substring</div>" :
                        : $substring;
 } );

 ...

=head1 DESCRIPTION

This class is meant to be a drop-in replacement for L<Parser::MGC>, offering
the ability to tag your output with L<String::Tagged> markers. You can use
C<tagged()> in order to access this tagged string, and methods from there
such as C<iter_substr_nooverlap()> in order to walk the string and read the
tags therein.

The token-parsing methods are augmented to add token name and value pairs.
Methods for tokens such as C<token_int> can take an optional argument of
C<token_int( $tag_name, $tag_value )>, which tags an integer with a given
token name and value.

Methods that already take arguments are augmented with an array reference
such as C<scope_of( '(', sub { }, ')', [ $tag_name, $tag_value ] )>.

=cut

sub _push_delimiters {
  my $self = shift;
  my ( $start_pos, $end_pos ) = @_;

  $start_pos = $self->{spaces}{$start_pos}
    if $self->{spaces}{$start_pos};
  push @{ $self->{delimiters} },
    [ $start_pos, $end_pos ];
}

sub _push_tag {
  my $self = shift;
  my ( $start_pos, $tag_name, $tag_value ) = @_;
  my $end_pos = $self->pos;
  ( $tag_name, $tag_value ) = @{ $self->{tag_stack} }
    if !defined $tag_name;
  return unless defined $tag_name;

  $start_pos = $self->{spaces}{$start_pos}
    if $self->{spaces}{$start_pos};
  my %rev_spaces = reverse %{ $self->{spaces} }; # XXX This might be brittle
  $end_pos = $rev_spaces{$end_pos}
    if $rev_spaces{$end_pos};
  push @{ $self->{tags} },
    [ $start_pos, $end_pos, $tag_name, $tag_value ]
      if $start_pos != $end_pos;
}

=head1 CONSTRUCTOR

=cut

=head2 $parser = Parser::MGC::Tagged->new( %args )

Returns a new instance of a C<Parser::MGC::Tagged> object. Users of this class
should never invoke this method directly, instead they should call the subclass
constructor method. Please see C<Parser::MGC> for the list of named arguments
this method accepts.

=cut

sub _init {
  my $self = shift;

  $self->{spaces} = { };
  $self->{tags} = [ ];
  $self->{delimiters} = [ ];
  $self->{tag_stack} = [ ];
}

=head1 METHODS

=cut

=head2 $result = $parser->tagged

Returns a C<String::Tagged> object with tags specified in the token parsing
methods.

=cut

sub tagged {
  my $self = shift;

  unless( ref $self->{str} ) {
    $self->{str} = String::Tagged->new( $self->{str} );
    for my $tag ( @{ $self->{tags} } ) {
      my @tag = @$tag;
      $tag[1] = $tag[1] - $tag[0];
      $self->{str}->apply_tag( @tag );
    }
  }
  return $self->{str};
}

=head2 $result = $parser->from_string( $str )

Parse the given literal string and return the result from the toplevel method.

=cut

sub from_string {
  my $self = shift;
  $self->_init;

  return $self->SUPER::from_string( @_ );
}

#
# from_file() wraps from_string().
#

=head2 $result = $parser->from_file( $file, %opts )

Parse the given file, which may be a pathname in a string, or an opened IO
handle, and return the result from the toplevel method.

Please see C<Parser::MGC> for the list of options this method accepts.

=cut

=head2 $result = $parser->from_reader( \&reader )

Parse the input which is read by the C<reader> function. This function will be
called in scalar context to generate portions of string to parse, being passed
the C<$parser> object. The function should return C<undef> when it has no more
string to return.

=cut

sub from_reader {
  my $self = shift;
  $self->_init;

  return $self->SUPER::from_reader( @_ );
}

#
# pos() is an accessor.
#

=head2 $pos = $parser->pos

Returns the current parse position, as a character offset from the beginning
of the file or string.

=cut

#
# where() is an accessor.
#

=head2 ( $lineno, $col, $text ) = $parser->where

Returns the current parse position, as a line and column number, and
the entire current line of text. The first line is numbered 1, and the first
column is numbered 0.

=cut

#
# fail() simply dies in fail_from()
#

#
# fail_from() simply dies.
#

=head2 $parser->fail( $message )

=head2 $parser->fail_from( $pos, $message )

Aborts the current parse attempt with the given message string. The failure
message will include the line and column position, and the line of input that
failed at the current parse position, or a position earlier obtained using the
C<pos> method.

=cut

#
# at_eos() is an accessor.
#

=head2 $eos = $parser->at_eos

Returns true if the input string is at the end of the string.

=cut

#
# scope_level() is an accessor.
#

=head2 $level = $parser->scope_level

Returns the number of nested C<scope_of> calls that have been made.

=cut

=head1 STRUCTURE-FORMING METHODS

The following methods may be used to build a grammatical structure out of the
defined basic token-parsing methods. Each takes at least one code reference,
which will be passed the actual C<$parser> object as its first argument.

=cut

#
# maybe() shouldn't tag stuff.
#

=head2 $ret = $parser->maybe( $code )

Attempts to execute the given C<$code> reference in scalar context, and
returns what it returned. If the code fails to parse by calling the C<fail>
method then none of the input string will be consumed; the current parsing
position will be restored. C<undef> will be returned in this case.

Please see C<Parser::MGC> for more details.

=cut

=head2 $ret = $parser->scope_of( $start, $code, $stop, [ $tag_name, $tag_value ] )

Expects to find the C<$start> pattern, then attempts to execute the given
C<$code> reference, then expects to find the C<$stop> pattern. Returns
whatever the code reference returned.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub scope_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';

  my $start_pos = $self->pos;
  my $result = $self->SUPER::scope_of( @_ );
  $self->_push_tag( $start_pos, $tag_name, $tag_value );
  return $result;
}

=head2 $ret = $parser->list_of( $sep, $code )

Expects to find a list of instances of something parsed by C<$code>,
separated by the C<$sep> pattern. Returns an ARRAY ref containing a list of
the return values from the C<$code>.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub list_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';

  my $start_pos = $self->pos;
  my $result = $self->SUPER::list_of( @_ );
  $self->_push_tag( $start_pos, $tag_name, $tag_value );
  return $result;
}

=head2 $ret = $parser->sequence_of( $code, [ $tag_name, $tag_value ] )

A shortcut for calling C<list_of> with an empty string as separator; expects
to find at least one instance of something parsed by C<$code>, separated only
by skipped whitespace.

This may be considered to be similar to the C<+> or C<*> regexp qualifiers.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub sequence_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';

  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::sequence_of( @_ );
}

=head2 $ret = $parser->any_of( @codes, [ $tag_name, $tag_value ] )

Expects that one of the given code references can parse something from the
input, returning what it returned. Each code reference may indicate a failure
to parse by calling the C<fail> method.

This may be considered to be similar to the C<|> regexp operator for forming
alternations of possible parse trees.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub any_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';

  my $start_pos = $self->pos;
  my $result = $self->SUPER::any_of( @_ );
  $self->_push_tag( $start_pos, $tag_name, $tag_value )
    if (caller(1))[3] ne 'Parser::MGC::token_number';
  return $result;
}

#
# commit() is a leaf.
#

=head2 $parser->commit

Calling this method will cancel the backtracking behaviour of the innermost
C<maybe>, C<list_of>, C<sequence_of>, or C<any_of> structure forming method.
That is, if later code then calls C<fail>, the exception will be propagated
out of C<maybe>, and no further code blocks will be attempted by C<any_of>.

Please see C<Parser::MGC> for more details.

=cut

=head1 TOKEN PARSING METHODS

The following methods attempt to consume some part of the input string, to be
used as part of the parsing process.

=cut

sub skip_ws {
  my $self = shift;

  my $start_pos = $self->pos;
  my $result = $self->SUPER::skip_ws( @_ );
  my $end_pos = $self->pos;
  $self->{spaces}{$start_pos} = $end_pos
    if $start_pos != $end_pos;
  return $result;
}

sub _push_contents {
  my $self = shift;
  my ( $start_pos, $in_scope_of, $tag_name, $tag_value ) = @_;

  my $end_pos = $self->pos;
  if ( $in_scope_of ) {
    $self->_push_delimiters( $start_pos, $end_pos );
  }
  else {
    unless ( $self->{spaces}{$start_pos} and
             $self->{spaces}{$start_pos} == $end_pos ) {
      $self->_push_tag( $start_pos, $tag_name, $tag_value );
    }
  }
}

=head2 $str = $parser->expect( $literal, [ $tag_name, $tag_value ] )

=head2 $str = $parser->expect( qr/pattern/, [ $tag_name, $tag_value ] )

=head2 @groups = $parser->expect( qr/pattern/, [ $tag_name, $tag_value ] )

=head2 $str = $parser->maybe_expect( ..., [ $tag_name, $tag_value ] )

=head2 @groups = $parser->maybe_expect( ..., [ $tag_name, $tag_value ] )

Expects to find a literal string or regexp pattern match, and consumes it.
In scalar context, this method returns the string that was captured. In list
context it returns the matching substring and the contents of any subgroups
contained in the pattern.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub maybe_expect {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';

  my $in_scope_of = (caller(3))[3] eq 'Parser::MGC::scope_of';

  my $start_pos = $self->pos;
  if ( wantarray ) {
    my @result = $self->SUPER::maybe_expect( @_ );
    $self->_push_contents( $start_pos, $in_scope_of, $tag_name, $tag_value );
    return @result;
  }
  else {
    my $result = $self->SUPER::maybe_expect( @_ );
    $self->_push_contents( $start_pos, $in_scope_of, $tag_name, $tag_value );
    return $result;
  }
}

sub expect {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';

  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::expect( @_ );
}

#
# substring_before() is an accessor.
#

=head2 $str = $parser->substring_before( $literal )

=head2 $str = $parser->substring_before( qr/pattern/ )

Expects to possibly find a literal string or regexp pattern match. If it finds
such, consume all the input text before but excluding this match, and return
it. If it fails to find a match before the end of the current scope, consumes
all the input text until the end of scope and return it.

Since this doesn't consume text, it doesn't accept tag name/value.

Please see C<Parser::MGC> for more details.

=cut

sub generic_token {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';

  my $start_pos = $self->pos;
  my $result = $self->SUPER::generic_token( @_ );
  $self->_push_tag( $start_pos, $tag_name, $tag_value );
  return $result;
}

#
# _token_generic() is an internal method.
#

=head2 $int = $parser->token_int( [ $tag_name, $tag_value ] )

Expects to find an integer in decimal, octal or hexadecimal notation, and
consumes it. Negative integers, preceeded by C<->, are also recognised.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub token_int {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_int( @_ );
}

=head2 $float = $parser->token_float( [ $tag_name, $tag_value ] )

Expects to find a number expressed in floating-point notation; a sequence of
digits possibly prefixed by C<->, possibly containing a decimal point,
possibly followed by an exponent specified by C<e> followed by an integer. The
numerical value is then returned.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub token_float {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_float( @_ );
}

=head2 $number = $parser->token_number( [ $tag_name, $tagvalue ] )

Expects to find a number expressed in either of the above forms.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub token_number {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_number( @_ );
}

=head2 $str = $parser->token_string( [ $tag_name, $tag_value ] )

Expects to find a quoted string, and consumes it. The string should be quoted
using C<"> or C<'> quote marks.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub token_string {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;

  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_string( @_ );
  $self->_push_tag( $start_pos, $tag_name, $tag_value );
  return $result;
}

=head2 $ident = $parser->token_ident( [ $tag_name, $tag_value ] )

Expects to find an identifier, and consumes it.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub token_ident {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  ( $tag_name, $tag_value ) = @{ $self->{tag_stack} }
    if !defined $tag_name;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_ident( @_ );
}

=head2 $keyword = $parser->token_kw( @keywords, [ $tag_nane, $tag_value ] )

Expects to find a keyword, and consumes it. A keyword is defined as an
identifier which is exactly one of the literal values passed in.

C<$tag_name> and C<$tag_value> are optional.

If the method finds a block of text, then the substring will be tagged with
C<$tag_name> and C<$tag_value>.

Please see C<Parser::MGC> for more details.

=cut

sub token_kw {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';

  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_kw( @_ );
}

1;
