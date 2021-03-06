#!/usr/bin/perl

use strict;
use warnings;

package ExprParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->parse_term;
}

sub parse_term
{
   my $self = shift;

   my $val = $self->parse_factor;

   1 while $self->any_of(
      sub { $self->expect( "+", [ Expect_1 => 1 ] ); $self->commit; $val += $self->parse_factor; 1 },
      sub { $self->expect( "-", [ Expect_2 => 1 ] ); $self->commit; $val -= $self->parse_factor; 1 },
      sub { 0 },
     [ Any_Of => 1 ],
   );

   return $val;
}

sub parse_factor
{
   my $self = shift;

   my $val = $self->parse_atom;

   1 while $self->any_of(
      sub { $self->expect( "*", [ Expect_1 => 1 ] ); $self->commit; $val *= $self->parse_atom; 1 },
      sub { $self->expect( "/", [ Expect_1 => 1 ] ); $self->commit; $val /= $self->parse_atom; 1 },
      sub { 0 },
     [ Any_Of => 1 ]
   );

   return $val;
}

sub parse_atom
{
   my $self = shift;

   $self->any_of(
      sub { $self->scope_of(
               "(", sub { $self->commit; $self->parse }, ")",
               [ Scope_Of => 1 ] ) },
      sub { $self->token_int( Int => 1 ) },
     [ Any_Of => 1 ]
   );
}

if( !caller ) {
   my $parser = __PACKAGE__->new;

   while( defined( my $line = <STDIN> ) ) {
      my $ret = eval { $parser->from_string( $line ) };
      print $@ and next if $@;

      print "$ret\n";
   }
}

1;
