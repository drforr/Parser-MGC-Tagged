use strict;
use warnings;
package Parser::MGC::Tagged;

use base 'Parser::MGC';

# ABSTRACT: foo

our $VERSION = '0.12';

sub _push_delimiters {
  my $self = shift;
  my ( $start_pos, $end_pos ) = @_;

  if ( $self->{spaces}{$start_pos} ) {
    $start_pos = $self->{spaces}{$start_pos};
  }
  push @{ $self->{delimiters} },
    [ $start_pos, $end_pos ];
}

sub _push_tag {
  my $self = shift;
  my ( $start_pos, $tag_name, $tag_value ) = @_;
  my $end_pos = $self->pos;
  if ( !defined $tag_name ) {
    ( $tag_name, $tag_value ) = @{ $self->{tag_stack} };
  }

  if ( $self->{spaces}{$start_pos} ) {
    $start_pos = $self->{spaces}{$start_pos};
  }
  my %rev_spaces = reverse %{ $self->{spaces} }; # XXX This might be brittle
  if ( $rev_spaces{$end_pos} ) {
    $end_pos = $rev_spaces{$end_pos};
  }
  push @{ $self->{tags} },
    [ $start_pos, $end_pos, $tag_name, $tag_value ]
      if defined $tag_name and $start_pos != $end_pos;
}

sub new {
  my $class = shift;
  my $rv = $class->SUPER::new( @_ );
  return $rv;
}

sub _init {
  my $self = shift;

  $self->{spaces} = { };
  $self->{tags} = [ ]; # There could be multiple tags starting at a given offset
  $self->{delimiters} = [ ]; # Save these for later?
  $self->{tag_stack} = [ ];
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
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ pop() };
  }

  my $start_pos = $self->pos;
  my $result = $self->SUPER::scope_of( @_ );
  $self->_push_tag( $start_pos, $tag_name, $tag_value );
  return $result;
}

sub list_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ pop() };
  }

  my $start_pos = $self->pos;
  my $result = $self->SUPER::list_of( @_ );
  $self->_push_tag( $start_pos, $tag_name, $tag_value );
  return $result;
}

sub sequence_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ pop() };
  }
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  my $result = $self->SUPER::sequence_of( @_ );
  return $result;
}

sub any_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ pop() };
  }

  my $start_pos = $self->pos;
  my $result = $self->SUPER::any_of( @_ );
  if ( (caller(1))[3] ne 'Parser::MGC::token_number' ) {
    $self->_push_tag( $start_pos, $tag_name, $tag_value );
  }
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
  if ( $start_pos != $end_pos ) {
    $self->{spaces}{$start_pos} = $end_pos;
  }
  return $result;
}

sub maybe_expect {
  my $self = shift;
  my ( $tag_name, $tag_value );
  my $in_scope_of = (caller(3))[3] eq 'Parser::MGC::scope_of';
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ pop() };
  }

  my $start_pos = $self->pos;
  if ( wantarray ) {
    my @result = $self->SUPER::maybe_expect( @_ );
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
    return @result;
  }
  else {
    my $result = $self->SUPER::maybe_expect( @_ );
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
    return $result;
  }
}

sub expect {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ pop() };
  }
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  if ( wantarray ) {
    my @result = $self->SUPER::expect( @_ );
    return @result;
  }
  else {
    my $result = $self->SUPER::expect( @_ );
    return $result;
  }
}

#
# substring_before() is an accessor.
#

sub generic_token {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ pop() };
  }

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

  my $result = $self->SUPER::token_int( @_ );
  return $result;
}

sub token_float {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  my $result = $self->SUPER::token_float( @_ );
  return $result;
}

sub token_number {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  my $result = $self->SUPER::token_number( @_ );
  return $result;
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
  if ( !defined $tag_name ) {
    ( $tag_name, $tag_value ) = @{ $self->{tag_stack} };
  }
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_ident( @_ );
  if ( $self->{spaces}{$start_pos} and
       $self->{tags}[-1][0] == $start_pos ) {
    $self->{tags}[-1][0] = $self->{spaces}{$start_pos};
  }
  return $result;
}

sub token_kw {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ pop() };
  }
  local $self->{tag_stack} = [ $tag_name, $tag_value ];

  my $result = $self->SUPER::token_kw( @_ );
  return $result;
}

1;
