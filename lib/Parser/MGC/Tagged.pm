use strict;
use warnings;
package Parser::MGC::Tagged;

use base 'Parser::MGC';

# ABSTRACT: foo

our $VERSION = '0.12';

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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "from_string>\n";
   my $result = $self->SUPER::from_string( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "from_string<\n";
   return $result;
}

sub from_file {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "from_file>\n";
  my $result = $self->SUPER::from_file( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "from_file<\n";
  return $result;
}

sub from_reader {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "from_reader>\n";
  my $result = $self->SUPER::from_reader( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "from_reader<\n";
  return $result;
}

#
# pos() is an accessor.
#

sub where {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "where>\n";
  my @result = $self->SUPER::where( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "where<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "at_eos>\n";
  my $result = $self->SUPER::at_eos( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "at_eos<\n";
  return $result;
}

sub scope_level {
   my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "scope_level>\n";
  my $result = $self->SUPER::scope_level( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "scope_level<\n";
  return $result;
}

#
# maybe() shouldn't tag stuff.
#
sub maybe {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe>\n";
  my $result = $self->SUPER::maybe( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "scope_of>\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "scope_of<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "list_of>\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "list_of<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "sequence_of>\n";
  my $result = $self->SUPER::sequence_of( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "sequence_of<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "any_of>\n";
  my $start_pos = $self->pos;
  my $result;
  if ( $has_aref ) {
    $result = $self->SUPER::any_of( @_[ 0 .. $#_-1 ] );
  }
  else {
    $result = $self->SUPER::any_of( @_ );
  }
  my $end_pos = $self->pos;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "any_of call(1): [" . (caller(1))[3] . "\n";
  if ( !$in_token_number and $start_pos != $end_pos ) {
    push @{ $self->{tags} },
      [ $start_pos, $end_pos, $tag_name, $tag_value ];
  }
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "any_of<\n";
  return $result;
}

sub commit {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "commit>\n";
  my $result = $self->SUPER::commit( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "commit<\n";
  return $result;
}

sub skip_ws {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "skip_ws>\n";
  my $start_pos = $self->pos;
  my $result = $self->SUPER::skip_ws( @_ );
  my $end_pos = $self->pos;
  if ( $start_pos != $end_pos ) {
    $self->{spaces}{$start_pos} = $end_pos;
  }
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "skip_ws<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect call(3): [" . (caller(3))[3] . "\n";
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect call(2): [" . (caller(2))[3] . "\n";
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect call(1): [" . (caller(1))[3] . "\n";
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect>\n";
    my $start_pos = $self->pos;
    my @result = $self->SUPER::maybe_expect( @_ );
    my $end_pos = $self->pos;
    if ( defined $tag_name and $start_pos != $end_pos ) {
      if ( $in_scope_of ) {
        push @{ $self->{delimiters} },
          [ $start_pos, $end_pos ];
      }
      else {
        push @{ $self->{tags} },
          [ $start_pos, $end_pos, $tag_name, $tag_value ];
      }
    }
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect A<\n";
    return @result;
  }
  else {
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect call(3): [" . (caller(3))[3] . "\n";
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect call(2): [" . (caller(2))[3] . "\n";
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect call(1): [" . (caller(1))[3] . "\n";
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect>\n";
    my $start_pos = $self->pos;
    my $result = $self->SUPER::maybe_expect( @_ );
    my $end_pos = $self->pos;
    if ( $start_pos != $end_pos ) {
      if ( $in_scope_of ) {
        push @{ $self->{delimiters} },
          [ $start_pos, $end_pos ];
      }
      else {
        push @{ $self->{tags} },
          [ $start_pos, $end_pos, $tag_name, $tag_value ];
      }
    }
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "maybe_expect S<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "expect>\n";
    my @result = $self->SUPER::expect( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "expect a<\n";
    return @result;
  }
  else {
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "expect>\n";
    my $result = $self->SUPER::expect( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "expect S<\n";
    return $result;
  }
}

sub substring_before {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "substring_before>\n";
  my $result = $self->SUPER::substring_before( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "substring_before<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "generic_token>\n";
  my $start_pos = $self->pos;
  my $result = $self->SUPER::generic_token( @_ );
  my $end_pos = $self->pos;
  if ( $start_pos != $end_pos ) {
    push @{ $self->{tags} },
      [ $start_pos, $end_pos, $tag_name, $tag_value ];
  }
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "generic_token<\n";
  return $result;
}

sub _token_generic {
  my $self = shift;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "_token_generic>\n";
  my $result = $self->SUPER::_token_generic( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "_token_generic<\n";
  return $result;
}

sub token_int {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_int>\n";
  my $result = $self->SUPER::token_int( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_int<\n";
  return $result;
}

sub token_float {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_float>\n";
  my $result = $self->SUPER::token_float( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_float<\n";
  return $result;
}

sub token_number {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_number>\n";
  my $result = $self->SUPER::token_number( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_number<\n";
  return $result;
}

sub token_string {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @_;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_string>\n";
  my $start_pos = $self->pos;
  my $result = $self->SUPER::token_string( @_ );
  my $end_pos = $self->pos;
  push @{ $self->{tags} }, [ $start_pos, $end_pos, $tag_name, $tag_value ];
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_string<\n";
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
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_ident>\n";
  my $result = $self->SUPER::token_ident( @_ );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_ident<\n";
  return $result;
}

sub token_kw {
  my $self = shift;
  my ( $tag_name, $tag_value ) = @{ $_[-1] };
  local $self->{tag_name} = $tag_name;
  local $self->{tag_value} = $tag_value;

local $self->{_depth_} = $self->{_depth_} + 1;
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_kw>\n";
  my $result = $self->SUPER::token_kw( @_[ 0 .. $#_ - 1 ] );
$ENV{DEBUG} and warn ' ' x $self->{_depth_} . "token_kw<\n";
  return $result;
}

1;
