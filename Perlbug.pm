# Perlbug docs and placeholder - nickname=Joy
# (C) 1999 2000 Richard Foley RFI perlbug@rfi.net
# $Id: Perlbug.pm,v 2.27 2000/10/16 10:20:26 perlbug Exp perlbug $
#

=head1 NAME

Perlbug - PerlBug DataBase

=cut

package Perlbug;           
use vars qw($VERSION);
$VERSION = '2.27';
				   	# 0.00+ Original Perlbug 
                    # 1.00+ Brought under RCS, config file, cached db entries, improved logging etc
                    # 2.00  Command line interface, history mechanism, bugid parent/child relations
					#       auto-registration, multiple test suites etc
					#       patches, notes, tm_cc
					#       Fix data structure interface
					#       bug tests support
					#       migrate tables and code (ticket->bug, etc.)
					# 		tentative Tk support
					# <--   we're here :-)
					# 
					# 2.5   Full test suite
					# 3.00  Oracle support
					# 3.5   ...
					# 4.00  perlTK?

=head1 DESCRIPTION

Bug tracking system, written in perl, running on UNIX, using Mysql.

For installation instructions see the INSTALL file.


=head1 SYNOPSIS 

New bugs are created by mailing perlbug@perl.org or perlbug@perl.com

Said bug is entered in the database, and given a new bugid, the mail is then forwarded to perl5-porters with the bugid in the subject line..

perl5-porters is continously tracked for relevant mails to attach to said bug.

There are web(http://bugs.perl.org), email(bugdb@perl.org and help@bugs.perl.org) and command line(bugdb) frontends to query and administrate the bugs.

Regular overviews are emailed to p5p, and outstanding bugs are mailed to active admins for their attention.


=head1 TODO

Oracle support

perlTK interface

Comprehensive test suite (though 100+ isn't that bad for a start?)


=head1 CLASSES


For those that are interested the Perlbug module hierarchy goes something like this:

    (ISA) Config  Do  TM    (HASA) Log Format 
          |       |   |          
          -------------            --- ------
                   |
             (ISA) Base
                   --------------------
                   |  |      |        |  
                 Web  Cmd    Tk       Email
                 ---  ---    --       -----------------------------
                 |    |      |        |        |        |         |
       perlbug.cgi    bugdb  bugtk    tron.pl  mail.pl  cron.cmd  hist.cmd ...


=head1 SCRIPTS

The perlbugtron relies on the following (6 active) scripts:

perlbug.cgi is the web interface.

bugdb is a command line interface.

bugtk is the on the todo list as a Tk interface.

tron.pl tracks mailing lists, relying on header information to identify new bugs and replies to existing ones.  Accepts mail for perlbug@perl.org and perlbug@perl.com and relevant target mailing lists.

mail.pl is a query and administrative email front end, examining both Subject: and To: line for instructions.  Accepts mail for bugdb@perl.org and *@bugs.perl.org.

cron.com is the regular cron job interface to backups, weekly notifications etc.

hist.cmd is a parser of directories of archived mail (treated as per tron.pl).


=head1 COMMANDS

A couple of useful commands, assuming you're in ~perlbug/scripts:

Send mail into the db:

	cat some_mail | ./tron.pl

Slurp up archived mails:

	./hist.cmd -d /path/to/email/archives

Query the db via the email interface:

	cat my_admin_cmds | ./mail.pl
	
Or via the command line:
	
	./bugdb
	        
Send active admins unclosed bugs and an overview to master_list(p5p), 
	dump current database for reference/backup:

    crontab -e 3 5 * * 1 ./cron.cmd


=head1 BUGS

What bugs ?-)

You have a couple of choices, (with the output of 'make test TEST_VERBOSE=1'):

	1. Mail perlbug@perl.org which will assign a bugid.
	
	2. Mail the author (richard@perl.org) directly.
	
	3. Mail admins@bugs.perl.org which will Cc: to all active admins.
	
	4. Subscribe to bugmongers@perl.org (a mailing list for those interested in perl bugs).

	4. Or try perl5-porters@perl.org (p5p) for a more generic solution.


=head1 AUTHOR

Richard Foley richard@perl.org perlbug@rfi.net (c) 1999 2000


=head1 CONTRIBUTORS

The system was given a kick start by Christopher Masto, NetMonger Communications <chris@netmonger.net>.


It's development has been overseen originally by Chip Salzenburg <chip@perlsupport.com> and later by Nathan Torkington <gnat@frii.com>.


There have been numerous suggestions, feedback and patches from various people, in particular (in alphabetical order):

Mike Guy <mjtg@cam.ac.uk>

Richard Soderberg <rs@oregonnet.com>

Robert Spier <rspier@pobox.com>

Hugo van der Sanden <hv@crypt0.demon.co.uk>


Special thanks to Tom Phoenix <rootbeer@redcat.com>.


=head1 COPYRIGHT

Copyright (c) 1999 2000 Richard Foley richard@rfi.net. All rights reserved.
	
This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

# 
1;
