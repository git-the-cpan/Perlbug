# Perlbug bug record handler
# (C) 1999 Richard Foley RFI perlbug@rfi.net
# $Id: Log.pm,v 1.7 2001/08/20 18:57:31 mstevens Exp $
#

=head1 NAME

Perlbug::Object::Log - Log class

=cut

package Perlbug::Object::Log;
use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r = (q$Revision: 1.7 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; 
$|=1;


=head1 DESCRIPTION

Perlbug Log class.

For inherited methods, see L<Perlbug::Object>

=cut

use Data::Dumper;
use Perlbug::Base;
use Perlbug::Object;
@ISA = qw(Perlbug::Object); 


=head1 SYNOPSIS

	use Perlbug::Object::Log;

	my $o_log = Perlbug::Object::Log->new();

	print $o_log->create($h_data);


=head1 METHODS

=over 4

=item new

Create new Log object:

	my $o_rng = Perlbug::Object::Log->new();

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto; 
	my $o_base = (ref($_[0])) ? shift : Perlbug::Base->new;

	my $self = Perlbug::Object->new( $o_base, 
		'name'		=> 'Log',
		'float'		=> [qw()],
		'from'		=> [qw()],
		'to'		=> [qw()],
		'track'		=> 0,
	);

	bless($self, $class);
}

=pod

=back

=head1 AUTHOR

Richard Foley perlbug@rfi.net 2001

=cut


# 
1;

