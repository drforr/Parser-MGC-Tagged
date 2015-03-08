#!/usr/bin/perl

use strict;
use warnings;

package DictParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->any_of(
      sub { $self->token_int( Int => 1 ) },

      sub { $self->token_string( String => 1 ) },

      sub { $self->scope_of( "{",
               sub { $self->commit; $self->parse_dict },
            "}" );
      },
   );
}

sub parse_dict
{
   my $self = shift;

   my %ret;
   $self->list_of( ",", sub {
      my $key = $self->token_ident( Ident => 1 );

      $self->expect( ":", [ Expect => 1 ] );

      $ret{$key} = $self->parse;
   } );

   return \%ret
}

use Data::Dumper;

if( !caller ) {
   my $parser = __PACKAGE__->new;

   while( defined( my $line = <STDIN> ) ) {
      my $ret = eval { $parser->from_string( $line ) };
      print $@ and next if $@;

      print Dumper( $ret );
   }
}

1;
