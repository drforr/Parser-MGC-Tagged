use strict;
use warnings;
package Parser::MGC::Tagged;

use base 'Parser::MGC';

# ABSTRACT: foo

our $VERSION = '0.12';

sub _push_tag {
  my $self = shift;
  my ( $start_pos, $end_pos, $tag_name, $tag_value ) = @_;
  if ( !defined $tag_name ) {
    $tag_name = $self->{tag_name};
    $tag_value = $self->{tag_value};
  }

  if ( $self->{spaces}{$start_pos} ) {
    $start_pos = $self->{spaces}{$start_pos};
  }
  push @{ $self->{tags} },
    [ $start_pos, $end_pos, $tag_name, $tag_value ]
      if defined $tag_name;
}

sub new {
  my $class = shift;
  my $rv = $class->SUPER::new( @_ );
  return $rv;
}

sub from_string {
  my $self = shift;
  $self->{spaces} = { };
  $self->{tags} = [ ]; # There could be multiple tags starting at a given offset
  $self->{delimiters} = [ ]; # Save these for later?

   my $result = $self->SUPER::from_string( @_ );
   return $result;
}

#
# from_file() wraps from_string().
#

sub from_reader {
  my $self = shift;
  $self->{spaces} = { };
  $self->{tags} = [ ]; # There could be multiple tags starting at a given offset
  $self->{delimiters} = [ ]; # Save these for later?

   my $result = $self->SUPER::from_reader( @_ );
   return $result;
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
  my $has_aref = 0;
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    $has_aref = 1;
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }

  my $start_pos = $self->pos;
  my $result;
  if ( $has_aref ) {
    $result = $self->SUPER::scope_of( @_[ 0 .. $#_-1 ] );
  }
  else {
    $result = $self->SUPER::scope_of( @_ );
  }
  my $end_pos = $self->pos;
  if ( $start_pos != $end_pos ) {
    $self->_push_tag( $start_pos, $end_pos, $tag_name, $tag_value );
  }
  return $result;
}

sub list_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  my $has_aref = 0;
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    $has_aref = 1;
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }

  my $start_pos = $self->pos;
  my $result;
  if ( $has_aref ) {
    $result = $self->SUPER::list_of( @_[ 0 .. $#_-1 ] );
  }
  else {
    $result = $self->SUPER::list_of( @_ );
  }
  my $end_pos = $self->pos;
  my %rev_spaces = reverse %{ $self->{spaces} };
  if ( $rev_spaces{$end_pos} ) {
    $end_pos = $rev_spaces{$end_pos};
  }
  if ( $start_pos != $end_pos ) {
    $self->_push_tag( $start_pos, $end_pos, $tag_name, $tag_value );
  }
  return $result;
}

sub sequence_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

  my $result = $self->SUPER::sequence_of( @_ );
  return $result;
}

sub any_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  my $in_token_number = (caller(1))[3] eq 'Parser::MGC::token_number';
  my $has_aref = 0;
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    $has_aref = 1;
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }

  my $start_pos = $self->pos;
  my $result;
  if ( $has_aref ) {
    $result = $self->SUPER::any_of( @_[ 0 .. $#_-1 ] );
  }
  else {
    $result = $self->SUPER::any_of( @_ );
  }
  my $end_pos = $self->pos;
  if ( !$in_token_number and $start_pos != $end_pos ) {
    $self->_push_tag( $start_pos, $end_pos, $tag_name, $tag_value );
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
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }

  if ( wantarray ) {
    my $start_pos = $self->pos;
    my @result = $self->SUPER::maybe_expect( @_ );
    my $end_pos = $self->pos;
    if ( $start_pos != $end_pos ) {
      if ( $in_scope_of ) {
        if ( $self->{spaces}{$start_pos} ) {
          $start_pos = $self->{spaces}{$start_pos};
        }
        push @{ $self->{delimiters} },
          [ $start_pos, $end_pos ];
      }
      else {
        if ( $self->{spaces}{$start_pos} and
             $self->{spaces}{$start_pos} == $end_pos ) {
        }
        else {
          $self->_push_tag( $start_pos, $end_pos, $tag_name, $tag_value );
        }
      }
    }
    return @result;
  }
  else {
    my $start_pos = $self->pos;
    my $result = $self->SUPER::maybe_expect( @_ );
    my $end_pos = $self->pos;
    if ( $start_pos != $end_pos ) {
      if ( $in_scope_of ) {
        if ( $self->{spaces}{$start_pos} ) {
          $start_pos = $self->{spaces}{$start_pos};
        }
        push @{ $self->{delimiters} },
          [ $start_pos, $end_pos ];
      }
      else {
        if ( $self->{spaces}{$start_pos} and
             $self->{spaces}{$start_pos} == $end_pos ) {
        }
        else {
          $self->_push_tag( $start_pos, $end_pos, $tag_name, $tag_value );
        }
      }
    }
    return $result;
  }
}

sub expect {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

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
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }

  my $start_pos = $self->pos;
  my $result = $self->SUPER::generic_token( @_ );
  my $end_pos = $self->pos;
  if ( $start_pos != $end_pos ) {
    $self->_push_tag( $start_pos, $end_pos, $tag_name, $tag_value );
  }
  return $result;
}

#
# _token_generic() is an internal method.
#

sub token_int {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

  my $result = $self->SUPER::token_int( @_ );
  return $result;
}

sub token_float {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

  my $result = $self->SUPER::token_float( @_ );
  return $result;
}

sub token_number {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

  my $result = $self->SUPER::token_number( @_ );
  return $result;
}

sub token_string {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;

  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_string( @_ );
  my $end_pos = $self->pos;
  $self->_push_tag( $start_pos, $end_pos, $tag_name, $tag_value );
  return $result;
}

sub token_ident {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  if ( !defined $tag_name ) {
    $tag_name = $self->{tag_name};
    $tag_value = $self->{tag_value};
  }
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

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
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_kw( @_[ 0 .. $#_ - 1 ] );
  return $result;
}

1;
