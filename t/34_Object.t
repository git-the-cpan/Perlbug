#!/usr/bin/perl -w
# Object read tests for Perlbug 
# Richard Foley RFI perlbug@rfi.net
# $Id: 34_Object.t,v 1.3 2001/12/03 07:35:50 richardf Exp $
#
BEGIN { 
	use File::Spec; 
	use lib File::Spec->updir;
	use Perlbug::Test; 
	plan('tests' => 3); 
}
use strict;
use lib qw(../);
use Carp;
my $test = 0;
my $oid = '19870502.007';

# Libs
# -----------------------------------------------------------------------------
use Perlbug::Base;
use Perlbug::Object::Bug;
my $o_obj = Perlbug::Object::Bug->new;

# Tests read, update, insert, delete
# -----------------------------------------------------------------------------

# 1
# read
$test++; 
$o_obj->read($oid);
if ($o_obj->READ) {
	ok($test);
} else {
	ok(0);
	output("read($oid) failure");
}

# 2
# get/set data 
$test++;
my $old = $o_obj->data('subject');
my $new = ($old =~ /some/io) ? 'a bug of another sort' : 'a bug of some sort';
my @vars = $o_obj->data({
	'subject' => $new,
});
if (grep(/^$new$/, @vars)) {
	ok($test);
} else {
	ok(0);
	output("o_obj->data($new) failure(@vars)");
}

# 3
# reread (old - update not used) data
$test++;  
my $subj = $o_obj->read($oid)->data('subject'); # inc. read
if ($old eq $subj) {
	ok($test);
} else {
	ok(0);
	output("o_obj->reread($old) failure($subj)");
}

