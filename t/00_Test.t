#!/usr/bin/perl -w
# Setup test data for Perlbug: insert: user, bug, patch, note, test, claimants, ccs
# Richard Foley RFI perlbug@rfi.net
# $Id: 00_Test.t,v 1.2 2000/08/02 08:15:56 perlbug Exp $
#
BEGIN {
	use File::Spec; 
	use lib File::Spec->updir;
	use Perlbug::Testing;
	plan('tests' => 9);
}
use strict;
use lib qw(../); 

# Libs
# -----------------------------------------------------------------------------
use Perlbug::Base;
use FileHandle;
use Mail::Internet;
use Sys::Hostname;
my $o_perlbug = Perlbug::Base->new;
$o_perlbug->current('admin', 'richardf');
$o_perlbug->current('isatest', 1);

# Setup
# -----------------------------------------------------------------------------
my $err  = 0;
my $test = 0;
my $UID  = 'perlbug_test';
my $BID  = '';
my $TID  = '';
my $MID  = '';
my $PID  = '';
my $NID  = '';
my $context = '';
my $msgid = getnow; 

# SETUP
# -----------------------------------------------------------------------------

my $HEADER = q#
Return-path: <perl5-porters-return-14508-p5p=rfi.net@perl.org>
Date: Wed, 12 Jul 2000 15:26:47 +0100
From: "Richard. J. S. Foley" <perlbug_test@rfi.net>
Subject: [PATCH] "make realclean" eats my patches :-)
To: perlbug@perl.com
Cc: perlbug_test_cc@rfi.net
Cc: cc_perlbug_interest@rfi.net
Message-ID: <$msgid>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
Precedence: bulk
Delivered-to: mailing list perl5-porters@perl.org
Delivered-to: perlmail-perlbug@perl.org
Mail-For: <p5p@rfi.net>
Mailing-List: contact perl5-porters-help@perl.org; run by ezmlm
X-Comment: Message Virus scanned by m.dasa.de
List-Post: <mailto:perl5-porters@perl.org>
List-Unsubscribe: <mailto:perl5-porters-unsubscribe@perl.org>
List-Help: <mailto:perl5-porters-help@perl.org>
X-Mozilla-Status: 8001
X-Mozilla-Status2: 00000000
X-UIDL:  !!!!01JROPXND8ZK8Y7ZAG0
#;

my $PATCH = q#
	This is a patch of some sort...
	
	:-|
#;

my $NOTE = q#
	This is a note of some sort...
	
	:-/
#;

my $TEST = q#
	This is a test of some sort...
	
	:-\
#;

my $QHEADER = $o_perlbug->quote($HEADER);

# Tests
# -----------------------------------------------------------------------------

# 1
# INSERT for testing
$test++; 
$err = 0;
$context = 'tm_bug';
if (1 == 1) { # container	
	my $subject = ' [PATCH] "make realclean" eats my patches :-) ';
	my $from = '"Richard. J. S. Foley" <perlbug_test@rfi.net>';
	my $to = 'perlbug@perl.com';
	my $body = "\nBody (not much data... \nhere perl etc...\n";
	my $ok = 0;
	($ok, $BID, $MID) = $o_perlbug->insert_bug($subject, $from, $to, $QHEADER, $body); 
	if ($ok == 1 and $o_perlbug->ok($BID)) {
		# 
	} else {
		$err++;
		output("$context test ($test) failed -> '$BID'");
	} 
}
output("$context -> err($err) leftovers from previous tests?") if $err;
if ($err == 0) {	
	ok($test);
	output("Installed bugid($BID)");
} else {
	notok($test);
}

# 2
$test++; 
$err = 0;
$context = 'tm_cc';
if (1 == 1) {
	my @ccs = (qw(perlbug_test_cc@rfi.net cc_perlbug_interest@rfi.net));
	my ($i_ok, @cc) = $o_perlbug->tm_cc($BID, @ccs);
	$err++ unless $i_ok == 1 and scalar(@cc) >= 1;
	output("$context -> @ccs -> ($i_ok, @cc) -> err($err)?") if $err;
}
if ($err == 0) {	
	ok($test);
} else {
	notok($test);
}

# 3
$test++;
$err = 0;
$context = 'tm_user';
if (1 == 1) {
	my $insert = qq|INSERT INTO tm_user VALUES (now(), NULL, '$UID', PASSWORD(password), 'perlbug_test\@rfi.net', 'Perlbug Test User', 'perlbug_test\@rfi\.net', '1')|;
    my $sth = $o_perlbug->exec($insert);
    $err++ unless defined($sth);
	output("$context -> $insert -> err($err)?") if $err;
}
if ($err == 0) {
    ok($test);
	output("Installed userid($UID)");
} else {
    notok($test);
}   

# 4 
$test++;
$err = 0;
$context = 'tm_patch';
if (1 == 1) {
	my $QPATCH = $o_perlbug->quote($PATCH);
	my $insert = qq|INSERT INTO tm_patch VALUES (now(), NULL, NULL, 'Patch against a bug($BID)', 'perlbug_test\@rfi.net', 'patch_${BID}_5.06.02_cnet33\@bugs.perl.org', $QHEADER, $QPATCH)|;
    my $sth = $o_perlbug->exec($insert);
	$err++ unless defined($sth);
	($PID) = $sth->insertid;
	output("$context -> $insert -> err($err)?") if $err;
}
if ($err == 0) {
    ok($test);
	output("Installed patchid($PID)");
} else {
    notok($test);
}    
   
# 5 
$test++;
$err = 0;
$context = 'tm_bug_patch';
if ($PID =~ /\w+/) {
	my $insert = qq|INSERT INTO tm_bug_patch VALUES ('$BID', '$PID')|;
    my $sth = $o_perlbug->exec($insert);
    $err++ unless defined($sth);
	output("$context -> $insert -> err($err)?") if $err;
} else {
	$err++;
	output("no patchid($PID) found!");
}
if ($err == 0) {
    ok($test);
} else {
    notok($test);
}    

# 6
$test++;
$err = 0;
$context = 'tm_tests';
if (1 == 1) {
	my $QTEST = $o_perlbug->quote($TEST);
	my $insert = qq|INSERT INTO tm_test VALUES (now(), NULL, NULL, 'Test against a bug($BID)', 'perlbug_test\@rfi.net', 'test_${BID}_5.06.02\@bugs.perl.org', $QHEADER, $QTEST)|;
    my $sth = $o_perlbug->exec($insert);
	$err++ unless defined($sth);
	($TID) = $sth->insertid;
	output("$context -> $insert -> err($err)?") if $err;
}
if ($err == 0) {
    ok($test);
	output("Installed testid($TID)");
} else {
    notok($test);
}    
   
# 7
$test++;
$err = 0;
$context = 'tm_bug_test';
if ($TID =~ /\w+/) {
	my $insert = qq|INSERT INTO tm_bug_test VALUES ('$BID', '$TID')|;
    my $sth = $o_perlbug->exec($insert);
    $err++ unless defined($sth);
	output("$context -> $insert -> err($err)?") if $err;
} else {
	$err++;
	output("no patchid($TID) found!");
}
if ($err == 0) {
    ok($test);
} else {
    notok($test);
}    

# 8
$test++;
$err = 0;
$context = 'tm_note';
if (1 == 1) {
	my $QNOTE = $o_perlbug->quote($NOTE);
	my $insert = qq|INSERT INTO tm_note VALUES (now(), NULL, NULL, 'Note against a bug($BID)', 'perlbug_test\@rfi.net', 'test_${BID}_5.06.02\@bugs.perl.org', $QHEADER, $QNOTE)|;
    my $sth = $o_perlbug->exec($insert);
	$err++ unless defined($sth);
	($NID) = $sth->insertid;
	output("$context -> $insert -> err($err)?") if $err;
}
if ($err == 0) {
    ok($test);
	output("Installed noteid($NID)");
} else {
    notok($test);
}    

# 9
$test++;
$err = 0;
$context = 'tm_bug_note';
if ($NID =~ /\w+/) {
	my $insert = qq|INSERT INTO tm_bug_note VALUES ('$BID', '$NID')|;
    my $sth = $o_perlbug->exec($insert);
    $err++ unless defined($sth);
	output("$context -> $insert -> err($err)?") if $err;
} else {
	$err++;
	output("no patchid($NID) found!");
}
if ($err == 0) {
    ok($test);
} else {
    notok($test);
}    

# done.
# 
