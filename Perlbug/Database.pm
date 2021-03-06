# Perlbug Bug support functions
# (C) 1999 Richard Foley RFI perlbug@rfi.net
# $Id: Database.pm,v 1.18 2002/02/01 08:36:45 richardf Exp $
#
# Based on TicketMonger.pm: Copyright 1997 Christopher Masto, NetMonger Communications
# Perlbug(::Database) integration: RFI 1998 -> 2001
#

=head1 NAME

Perlbug::Database - Bug support functions for Perlbug

=cut

package Perlbug::Database;
use strict;
use vars qw($VERSION);
$VERSION = do { my @r = (q$Revision: 1.18 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; 

use Benchmark;
use Carp;
use Data::Dumper;
use DBI;
use IO::File;
my $o_DBH  = undef;
my $lasterror = '';
my $o_Base = '';
my %DB     = ();

$Perlbug::Database::CACHED = 0; $Perlbug::Database::CACHED = 0;
$Perlbug::Database::HANDLE = 0;
$Perlbug::Database::SQL    = 0;

=head1 DESCRIPTION

Access to the database for Perlbug

=head1 SYNOPSIS

	my $o_db = Perlbug::Database->new(@args);
	
	my $sth  = $o_db->query('show tables');

	my @tables = $sth->fetchrow_array; # yek (should move get_list|data() from Base to here)
	
	print "tables: @tables\n";

=head1 METHODS

=over 4

=item new

Get a new db object

	my $o_db = Perlbug::Database->new(@args);

=cut

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	%DB = @_;

	# undef $o_DBH; # get a new one

	bless({}, $class);
}

sub base {
	my $self = shift;

	$o_Base = ref($o_Base) ? $o_Base : Perlbug::Base->new;	

	return $o_Base;
}

=item quote

Quote the given string/s to 'sql\'s'

	my $quoted = $o_db->quote($sql); 

=cut

sub quote { 
	my $self = shift;
	my @args = @_;
	my @quot = ();

	# scalar context(?) of s/// returns numerical value!
	# return map { s/^\'(.*)\'$/ } $self->dbh->quote(@_); 
	# sigh...

	my $i_xq = my @xquoted = $self->dbh->quote(@_);

	foreach my $q (@xquoted) {
		$q =~ s/^\'(.*)\'$/$1/;
		push(@quot, $q);
	}
	
	# print "in(@args)<br>\nxq($i_xq, @xquoted)<br>\nout(@quot)<br>\n";

	return wantarray ? @quot : $quot[0];
}

=item comp 

Return the appropriate comparison operator: B<LIKE> or B<=>

	my $comp = $o_db->comp($str); 

=cut

sub comp { 
	my $self = shift;
	my $str  = shift || '';

	return ($str =~ /\%/o) ? 'LIKE' : '=';
}

=item dbh

Returns database handle for queries

	my $o_dbh = $o_db->dbh;

=cut

sub dbh {
	my $self = shift;	

	$o_DBH = ref($o_DBH) ? $o_DBH : $self->DBConnect;

	$self->base->error("dbh undefined database handle($o_DBH)\n") unless $o_DBH;

	return $o_DBH;
}

=item DBConnect

DBConnect() checks to see if there is an open connection to the
Savant database, opens one if there is not, and returns a global
database handle.  This eliminates opening and closing database
handles during a session.  undef is returned 

=cut

sub DBConnect {
	my $self = shift;
	if (!defined($o_DBH)) {
		$Perlbug::Database::HANDLE++;
		my @connect = (($DB{'connect'} =~ /^(.+)$/o)
			? ($1)
			: (qq|DBI:$DB{'engine'}:$DB{'database'};host=$DB{'sqlhost'}|)
			, $DB{'user'}, $DB{'password'});
        $o_DBH = DBI->connect(@connect);
		$self->base->debug(0, "new o_DBH($o_DBH) connection") if $Perlbug::DEBUG;
		# use CGI; print CGI->new->header, '<pre>'.Dumper($self).'</pre>';
        if (!(defined($o_DBH))) {
            $self->base->error("Can't connect to db($o_DBH): '$DBI::errstr'".Dumper(\%DB));
        }
    }

    return $o_DBH;
}

=item query

Return sth from given query

	my $sth = $o_db->query($sql);

=cut

sub query {
    my $self = shift;
	my $sql = shift;
    $Perlbug::Database::SQL++;    
    $o_DBH = $self->dbh; # or return undef;
	my $beg = Benchmark->new if $Perlbug::DEBUG;
    my $sth = $o_DBH->prepare($sql) if $o_DBH;
	if (!$sth) {
		$self->base->error($self, "Couldn't prepare sql($sql): $DBI::errstr");
	} else {
		my $rv = $sth->execute;
		# $self->base->error("failed sql query($sql)") ...?;
		if ($Perlbug::DEBUG) {
			my $end = Benchmark->new; 
			my $tim = timediff($end, $beg); # tell_time
			$self->base->debug('S', "took @{[timestr($tim)]} <= $sql"); # $Perlbug::DEBUG above
		}
    }

    return $sth;
}

=item case_sensitive

Return given args(column, string) as case sensitive match

	my $sql = $o_db->case_sensitive('format', 'H');

=cut

sub case_sensitive { 
	my $self = shift;
	my $col  = shift;
	my $str  = shift;
	my $ret  = '';

	if (!($col =~ /\w+/ && $str =~ /\w+/)) {
		$self->base->debug(0, "no col($col) or str($str) given!") if $Perlbug::DEBUG; 
	} else {
		$ret = "STRCMP($col, '$str') = 0"; # mysql
	}	

	return $ret;
}

=back

=head1 AUTHOR

Richard Foley perlbug@rfi.net Oct 1999 2000 2001 

From original work by Chris Masto chrism@netmonger.net 

=cut

1;
