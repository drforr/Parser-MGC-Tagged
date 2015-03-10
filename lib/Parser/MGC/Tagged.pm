use strict;
use warnings;
package Parser::MGC::Tagged;

use base 'Parser::MGC';

use String::Tagged;

# ABSTRACT: foo

our $VERSION = '0.12';

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

sub _init {
  my $self = shift;

  $self->{spaces} = { };
  $self->{tags} = [ ];
  $self->{delimiters} = [ ];
  $self->{tag_stack} = [ ];
}

sub tagged {
  my $self = shift;
  
  my $str = String::Tagged->new( $self->{str} );
  for my $tag ( @{ $self->{tags} } ) {
    my @tag = @$tag;
    $tag[1] = $tag[1] - $tag[0];
    $str->apply_tag( @tag );
  }
  return $str;
}

sub from_string {
  my $self = shift;
  $self->_init;

  return $self->SUPER::from_string( @_ );
}

#
# from_file() wraps from_string().
#

sub from_reader {
  my $self = shift;
  $self->_init;

  return $self->SUPER::from_reader( @_ );
}

#
# pos() is an accessor.
#

#
# where() is an accessor.
#

#
# fail() simply dies in fail_from()
#

#
# fail_from() simply dies.
#

#
# at_eos() is an accessor.
#

#
# scope_level() is an accessor.
#

#
# maybe() shouldn't tag stuff.
#

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

sub sequence_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::sequence_of( @_ );
}

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

sub token_int {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_int( @_ );
}

sub token_float {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_float( @_ );
}

sub token_number {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_number( @_ );
}

sub token_string {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;

  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_string( @_ );
  $self->_push_tag( $start_pos, $tag_name, $tag_value );
  return $result;
}

sub token_ident {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  ( $tag_name, $tag_value ) = @{ $self->{tag_stack} }
    if !defined $tag_name;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_ident( @_ );
}

sub token_kw {
  my $self = shift;
  my ( $tag_name, $tag_value );
  ( $tag_name, $tag_value ) = @{ pop() }
    if ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY';
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  return $self->SUPER::token_kw( @_ );
}

1;
