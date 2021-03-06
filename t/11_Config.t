#!/usr/bin/perl -w
# Actual configuration tests for directories
# Richard Foley RFI perlbug@rfi.net
# $Id: 11_Config.t,v 1.2 2001/12/05 20:58:38 richardf Exp $
#
use strict;
use lib qw(../);
use Perlbug::Test;
my $test = 0;
my $err = 0;

# Libs
# -----------------------------------------------------------------------------
use Perlbug::Config;
use Data::Dumper;
my $o_conf = Perlbug::Config->new; 
my $o_test = Perlbug::Test->new($o_conf);

my @dirs = $o_conf->get_keys('directory');
plan('tests' => scalar(@dirs));

# 1-7
# Directories 
$test++;
$err = 0;
foreach my $context (@dirs) {
	my $err = 0;
	my $dir = $o_conf->directory($context);
	if (! -d $dir) {
		$err++; # 1	
		output("Dir($dir) not exists)");
	}
	if (! -r $dir) {
		$err++; # 2
		output("Dir($dir) not readable)");
	}
	if ($context =~ /^(arch|spool|temp)$/o) {
		if (! -w $dir) {
			$err++; # 3
			output("Dir($dir) not writable)");
		}
	}
	if ($err == 0) {	
		# output("$context directory($dir) looks ok");
		ok($test);
	} else {
		ok(0);
		output("$context directory failure($err)");
	}
	$test++;
}

# Done
# -----------------------------------------------------------------------------
# .
