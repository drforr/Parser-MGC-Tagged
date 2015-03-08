#!/usr/bin/perl

use strict;
use warnings;

package PodParser;
use base qw( Parser::MGC::Tagged );

sub parse
{
   my $self = shift;

   $self->sequence_of(
      sub { $self->any_of(

         sub { my ( undef, $tag, $delim ) = $self->expect( qr/([A-Z])(<+)/ );
               $self->commit;
               +{ $tag => $self->scope_of( undef, \&parse, ">" x length $delim, [ Scope_Of => 1 ] ) }; },

         sub { $self->substring_before( qr/[A-Z]</ ) },
        [ Any_Of => 1 ]
      ) },
     [ Sequence_Of => 1 ]
   );
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
