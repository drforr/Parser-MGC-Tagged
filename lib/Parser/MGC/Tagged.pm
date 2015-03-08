use strict;
use warnings;
package Parser::MGC::Tagged;

use base 'Parser::MGC';

# ABSTRACT: foo

our $VERSION = '0.12';

sub DEBUG() { $ENV{DEBUG} }
sub DEBUG_IN {
  my $str = (caller(1))[3];
  $str =~ s/^Parser\::MGC\::Tagged\:://;
  DEBUG and warn ' ' x $_[0]->{_depth_} . "$str>\n";
}
sub DEBUG_OUT {
  my $txt = defined $_[1] ? " $_[1]" : '';
  my $str = (caller(1))[3];
  $str =~ s/^Parser\::MGC\::Tagged\:://;
  DEBUG and warn ' ' x $_[0]->{_depth_} . "$str$txt<\n";
}

sub new {
  my $class = shift;
  my $rv = $class->SUPER::new( @_ );
$rv->{_depth_} = 0;
  return $rv;
}

sub from_string {
  my $self = shift;
$self->{spaces} = { };
$self->{tags} = [ ]; # There could be multiple tags starting at a given offset
$self->{delimiters} = [ ]; # Save these for later?

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
   my $result = $self->SUPER::from_string( @_ );
$self->DEBUG_OUT;
   return $result;
}

sub from_file {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::from_file( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub from_reader {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::from_reader( @_ );
$self->DEBUG_OUT;
  return $result;
}

#
# pos() is an accessor.
#

sub where {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my @result = $self->SUPER::where( @_ );
$self->DEBUG_OUT;
  return @result;
}

#
# fail() simply dies in fail_from()
#

#
# fail_from() simply dies.
#

sub at_eos {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::at_eos( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub scope_level {
   my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::scope_level( @_ );
$self->DEBUG_OUT;
  return $result;
}

#
# maybe() shouldn't tag stuff.
#
sub maybe {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::maybe( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub scope_of {
  my $self = shift;
  my ( $tag_name, $tag_value );
  my $has_aref = 0;
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    $has_aref = 1;
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }
  if ( !defined $tag_name ) {
    $tag_name = $self->{tag_name};
    $tag_value = $self->{tag_value};
  }

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
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
    push @{ $self->{tags} },
      [ $start_pos, $end_pos, $tag_name, $tag_value ];
  }
$self->DEBUG_OUT;
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
  if ( !defined $tag_name ) {
    $tag_name = $self->{tag_name};
    $tag_value = $self->{tag_value};
  }

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $start_pos = $self->pos;
  my $result;
  if ( $has_aref ) {
    $result = $self->SUPER::list_of( @_[ 0 .. $#_-1 ] );
  }
  else {
    $result = $self->SUPER::list_of( @_ );
  }
  my $end_pos = $self->pos;
  if ( $start_pos != $end_pos ) {
    push @{ $self->{tags} },
      [ $start_pos, $end_pos, $tag_name, $tag_value ];
  }
$self->DEBUG_OUT;
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

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::sequence_of( @_ );
$self->DEBUG_OUT;
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

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $start_pos = $self->pos;
  my $result;
  if ( $has_aref ) {
    $result = $self->SUPER::any_of( @_[ 0 .. $#_-1 ] );
  }
  else {
    $result = $self->SUPER::any_of( @_ );
  }
  my $end_pos = $self->pos;
DEBUG and warn ' ' x $self->{_depth_} . "any_of call(1): [" . (caller(1))[3] . "\n";
  if ( !$in_token_number and $start_pos != $end_pos ) {
    push @{ $self->{tags} },
      [ $start_pos, $end_pos, $tag_name, $tag_value ];
  }
$self->DEBUG_OUT;
  return $result;
}

sub commit {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::commit( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub skip_ws {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $start_pos = $self->pos;
  my $result = $self->SUPER::skip_ws( @_ );
  my $end_pos = $self->pos;
  if ( $start_pos != $end_pos ) {
    $self->{spaces}{$start_pos} = $end_pos;
  }
$self->DEBUG_OUT;
  return $result;
}

sub maybe_expect {
  my $self = shift;
  my ( $tag_name, $tag_value );
  my $in_scope_of = (caller(3))[3] eq 'Parser::MGC::scope_of';
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }
  if ( !defined $tag_name ) {
    $tag_name = $self->{tag_name};
    $tag_value = $self->{tag_value};
  }

local $self->{_depth_} = $self->{_depth_} + 1;
  if ( wantarray ) {
DEBUG and warn ' ' x $self->{_depth_} . "maybe_expect call(3): [" . (caller(3))[3] . "\n";
DEBUG and warn ' ' x $self->{_depth_} . "maybe_expect call(2): [" . (caller(2))[3] . "\n";
DEBUG and warn ' ' x $self->{_depth_} . "maybe_expect call(1): [" . (caller(1))[3] . "\n";
$self->DEBUG_IN;
    my $start_pos = $self->pos;
    my @result = $self->SUPER::maybe_expect( @_ );
    my $end_pos = $self->pos;
DEBUG and warn "[" . substr( $self->{str}, $start_pos, $end_pos - $start_pos ) . "]\n";
    if ( $start_pos != $end_pos ) {
      if ( $in_scope_of ) {
        push @{ $self->{delimiters} },
          [ $start_pos, $end_pos ];
      }
      else {
        if ( $self->{spaces}{$start_pos} and
             $self->{spaces}{$start_pos} == $end_pos ) {
DEBUG and warn "*** edge case hit\n";
        }
        else {
          if ( $self->{spaces}{$start_pos} ) {
            $start_pos = $self->{spaces}{$start_pos};
          }
          push @{ $self->{tags} },
            [ $start_pos, $end_pos, $tag_name, $tag_value ];
        }
      }
    }
$self->DEBUG_OUT( 'A' );
    return @result;
  }
  else {
DEBUG and warn ' ' x $self->{_depth_} . "maybe_expect call(3): [" . (caller(3))[3] . "\n";
DEBUG and warn ' ' x $self->{_depth_} . "maybe_expect call(2): [" . (caller(2))[3] . "\n";
DEBUG and warn ' ' x $self->{_depth_} . "maybe_expect call(1): [" . (caller(1))[3] . "\n";
DEBUG and warn ' ' x $self->{_depth_} . "maybe_expect>\n";
    my $start_pos = $self->pos;
    my $result = $self->SUPER::maybe_expect( @_ );
    my $end_pos = $self->pos;
DEBUG and warn "[" . substr( $self->{str}, $start_pos, $end_pos - $start_pos ) . "]\n";
    if ( $start_pos != $end_pos ) {
      if ( $in_scope_of ) {
        push @{ $self->{delimiters} },
          [ $start_pos, $end_pos ];
      }
      else {
        if ( $self->{spaces}{$start_pos} and
             $self->{spaces}{$start_pos} == $end_pos ) {
DEBUG and warn "*** edge case hit\n";
        }
        else {
          push @{ $self->{tags} },
            [ $start_pos, $end_pos, $tag_name, $tag_value ];
        }
      }
    }
$self->DEBUG_OUT( 'S' );
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

local $self->{_depth_} = $self->{_depth_} + 1;
  if ( wantarray ) {
$self->DEBUG_IN;
    my @result = $self->SUPER::expect( @_ );
$self->DEBUG_OUT( 'A' );
    return @result;
  }
  else {
$self->DEBUG_IN;
    my $result = $self->SUPER::expect( @_ );
$self->DEBUG_OUT( 'S' );
    return $result;
  }
}

sub substring_before {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::substring_before( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub generic_token {
  my $self = shift;
  my ( $tag_name, $tag_value );
  if ( ref( $_[-1] ) and ref( $_[-1] ) eq 'ARRAY' ) {
    ( $tag_name, $tag_value ) = @{ $_[-1] };
  }
  if ( !defined $tag_name ) {
    $tag_name = $self->{tag_name};
    $tag_value = $self->{tag_value};
  }

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $start_pos = $self->pos;
  my $result = $self->SUPER::generic_token( @_ );
  my $end_pos = $self->pos;
  if ( $start_pos != $end_pos ) {
    if ( $self->{spaces}{$start_pos} ) {
      $start_pos = $self->{spaces}{$start_pos};
    }
    push @{ $self->{tags} },
      [ $start_pos, $end_pos, $tag_name, $tag_value ];
  }
$self->DEBUG_OUT;
  return $result;
}

sub _token_generic {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::_token_generic( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub token_int {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::token_int( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub token_float {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::token_float( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub token_number {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $result = $self->SUPER::token_number( @_ );
$self->DEBUG_OUT;
  return $result;
}

sub token_string {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_string( @_ );
  my $end_pos = $self->pos;
  if ( $self->{spaces}{$start_pos} ) {
    $start_pos = $self->{spaces}{$start_pos};
  }
  push @{ $self->{tags} }, [ $start_pos, $end_pos, $tag_name, $tag_value ];
$self->DEBUG_OUT;
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

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_ident( @_ );
  if ( $self->{spaces}{$start_pos} and
       $self->{tags}[-1][0] == $start_pos ) {
    $self->{tags}[-1][0] = $self->{spaces}{$start_pos};
  }
$self->DEBUG_OUT;
  return $result;
}

sub token_kw {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @{ $_[-1] };
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

local $self->{_depth_} = $self->{_depth_} + 1;
$self->DEBUG_IN;
  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_kw( @_[ 0 .. $#_ - 1 ] );
$self->DEBUG_OUT;
  return $result;
}

1;
