#!/usr/bin/perl 
# Perlbug graph interface to database (bugdb)
# (C) 2000 Richard Foley RFI perlbug@rfi.net 
# $Id: graph.cgi,v 1.1 2001/03/23 14:38:08 perlbug Exp $
#
use strict;
use vars(qw($VERSION));
$VERSION = do { my @r = (q$Revision: 1.1 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; 

use FindBin;
use lib "$FindBin::Bin/..";
use Perlbug::Base;
use GD::Graph::pie; 				# mixed
use CGI;
$|=1;

# OBJs
my $pb = Perlbug::Base->new;
my $gd = GD::Graph::pie->new(300, 300);		# mixed
my $cgi= '';

# ARGs
my $flag  = $ARGV[0] || 'severity';		# 
my $debug = $ARGV[1] || 0; 				# 0, 1, 2
my $out   = $ARGV[2] || '/tmp/image';	# or direct with cgi
my $context = $ARGV[3] || 'std'; 		# or std (cmd line) 

# DATA 
my $data = $pb->stats;
if ($context eq 'std') {
	print "flag($flag), debug($debug), out($out), context($context)\n" if $debug >= 0;
	print $pb->dump($$data{$flag}) if $debug == 1;
	print $pb->dump($data) if $debug >= 2; 
} else {
    my $cgi= CGI->new; # ('-no_debug');
	print $cgi->header("image/png");
	$flag = $cgi->param('req');
}

# GRAPH 
#        'types'	=> [qw(lines bars points area linespoints)],
#        'default_type' => 'points',
#);            
#$gd->set_legend( qw( one two three four five six )); # mixed or points only?
$gd->set(
    'axislabelclr'     => 'black',
    'title'            => "Perlbug overview ($flag)",
);      

# SETUP
my @keys = (qw(here there everywhere ok not));
my @vals = (qw(3 4 4 6 2));
foreach my $key (keys %{$$data{$flag}}) {
    next unless $key =~ /^(\w+)$/;
	next unless $$data{$flag}{$key} =~ /^(\d+)$/;
	push(@keys, "$key ($$data{$flag}{$key})");
	push(@vals, $$data{$flag}{$key});
}

# DATA
my @data = (
   \@keys, 
   \@vals,
);     

# OUT
binmode STDOUT;
my $graph = $gd->plot([\@keys, \@vals]);
my $image = $graph->png;
if ($context eq 'cgi') {
	# print $cgi->start_html;
	print $image;
	print $cgi->end_html;
} else {
	open OUT, "> $out" or die("can't open '$out': $!");
	print OUT $image;
	close OUT;
}

$pb->clean_up("$0 ($flag) done");

exit(0);
