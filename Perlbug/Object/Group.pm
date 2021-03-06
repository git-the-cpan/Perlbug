# Perlbug bug record handler
# (C) 1999 Richard Foley RFI perlbug@rfi.net
# $Id: Group.pm,v 1.29 2002/01/25 16:12:59 richardf Exp $
#

=head1 NAME

Perlbug::Object::Group - Group class

=cut

package Perlbug::Object::Group;
use strict;
use vars qw($VERSION @ISA);
$VERSION = do { my @r = (q$Revision: 1.29 $ =~ /\d+/g); sprintf "%d."."%02d" x $#r, @r }; 
$|=1;


=head1 DESCRIPTION

Perlbug bug class.

For inherited methods, see L<Perlbug::Object::Object>

=cut

use Data::Dumper;
use Perlbug::Base;
use Perlbug::Object;
@ISA = qw(Perlbug::Object); 


=head1 SYNOPSIS

	use Perlbug::Object::Group;

	my $o_grp = Perlbug::Object::Group->new();

	print $o_grp->read('docs')->format('a');


=head1 METHODS

=over 4

=item new

Create new Group object:

	my $o_group = Perlbug::Object::Group->new();

=cut

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto; 
	my $o_base = (ref($_[0])) ? shift : Perlbug::Base->new;

	my $self = Perlbug::Object->new( $o_base, 
		'name'		=> 'Group',
		'from'		=> [qw()],
		'to'		=> [qw(address bug user)],
	);

	bless($self, $class);
}


=item create 

Check if name is unique

    my $o_grp = $o_grp->create(\%data);

=cut

sub create {
    my $self   = shift;
	my $h_data = shift || $self->_oref('data');

	my $proposed = $$h_data{'name'};
	my ($extant) = $self->ids("name = '$proposed'");

	if ($extant) {
		$self->debug(0, 'disallowed group data: '.Dumper($h_data)) if $Perlbug::DEBUG;
		$h_data = undef;
		print "<h3>\nCan't create a non-unique name($proposed) while extant($extant)!\n</h3><hr>\n";
	}

	$self->SUPER::create($h_data) if $h_data;

    return $self;
}


=item htmlify 

html formatter for individual group entries for placement

    my $h_grp= $o_grp->htmlify($h_grp);

=cut

sub htmlify {
    my $self = shift;
    my $h_grp= shift;
	my $req  = shift || 'admin';
	return undef unless ref($h_grp) eq 'HASH';

    my %grp = %{$h_grp};
    my $cgi = $self->base->cgi();
	
    my $gid  = $grp{'groupid'};
	my $name = my $stat = $grp{'name'};

	%grp = %{$self->SUPER::htmlify($h_grp)};	

    ($grp{'groupid'})  = $self->href('group_id', [$gid], $gid, $stat);
	$grp{'groupid'} =~ s/format\=h/format\=H/gi;
	($grp{'name'}) = $self->href('group_id', [$gid], $name, $stat);

	my $o_usr = $self->object('user');
    if ($self->base->isadmin && $self->base->current('format') ne 'L' && $req ne 'noadmin') {
		$grp{'addaddress'}	= $cgi->textfield(-'name' => $gid.'_addaddress', -'value' => '', -'size' => 45, -'maxlength' => 99, -'override' => 1);
		$grp{'addabugid'}	= $cgi->textfield(-'name' => $gid.'_addabugid', -'value' => '', -'size' => 12, -'maxlength' => 12, -'override' => 1);
		$grp{'description'}	= $cgi->textfield(-'name' => $gid.'_description', -'value' => $grp{'description'}, -'size' => 45, -'maxlength' => 99, -'override' => 1);
		$grp{'name'} 		= $cgi->textfield(-'name' => $gid.'_name', -'value' => $name, -'size' => 15, -'maxlength' => 15);
		$grp{'select'}     	= $cgi->checkbox(-'name'=>'groupids', -'checked' => '', -'value'=> $gid, -'label' => '', -'override' => 1);
		$grp{'user_ids'} 	= $o_usr->choice($gid.'_userids', $self->rel_ids('user')).$grp{'user_ids'};
	}
	# print '<pre>'.Dumper(\%grp).'</pre>';
	return \%grp;
}

=item webupdate

Update group data via web interface, accepts relations via param('_opts')

	$oid = $o_grp->webupdate(\%cgidata, $oid);

=cut

sub webupdate {
	my $self   = shift;
	my $h_data = shift;
	my $oid    = shift;
    my $cgi    = shift || $self->base->cgi();

	if (!(ref($h_data) eq 'HASH')) {
		$self->error("requires data hash ref($h_data) to update ".ref($self)." data via the web!");
	} else {
		if ($self->read($oid)->READ) {
			$self->debug(0, "oid: ".$self->oid) if $Perlbug::DEBUG;
			my $pri = $self->attr('primary_key');
			$$h_data{$pri} = $oid;
			my $i_updated = $self->update($h_data)->UPDATED; # internal debugging
			if ($i_updated == 1) {
				$self->SUPER::webupdate($h_data, $oid);
			}
		}
	}
	
	return $oid;
}


=pod
# NEW GROUP
		if ($ok == 1 && $newgroup) {
			if ($newgroup !~ /^\w\w\w+$/) {
				$ok = 0;
				print "Group($newgroup) notallowed: please use at least 3 alphanumerics for group names!<hr>";
			} else {
				my $o_grp = $self->object('group');
				my @gindb = $o_grp->col('name');
				my $pri = $o_grp->primary_key;
				$o_grp->create({
					$pri	 		=> $o_grp->new_id,
					'name'			=> $newgroup,
					'description'	=> $desc,
				});
				if ($o_grp->CREATED) {
					push(@gids, $o_grp->oid); 
					my @uids = $cgi->param('addusers');
					$o_grp->relation('user')->store(\@uids) if @uids;
				}
			}
			print '<table border = 1>', $self->groups(\@gids), '</ table>'; 
		}
=cut

# --------------------------------------------------------- #

=pod

=back

=head1 FORMATS

Group formatter for all occasions...

=over 4

=item FORMAT_l

Lean (list) ascii format for groups:

	my ($top, $format, @args) = $o_grp->FORMAT_l(\%data);

=cut

sub FORMAT_l { # 
	my $self = shift;
	my $d    = shift; # 
	my @args = ( 
		$$d{'name'},  $$d{'groupid'}, 
		$$d{'user_count'}, $$d{'bug_count'}, $$d{'address_count'},
		$$d{'created'},
	);
	my $top = qq|
Name       GroupID  Admins  Bugs    Ccs    Created               
-------------------------------------------------------------------------------|;
	my $format = qq|
@<<<<<<<<  @<<<<<   @<<<<   @<<<<<< @<<<<  @<<<<<<<<<<<<<<<<<<<  
|; 
	return ($top, $format, @args);
}


=item FORMAT_a

ascii format for groups:

	my ($top, $format, @args) = $o_grp->FORMAT_a(\%data);

=cut

sub FORMAT_a { # 
	my $self = shift;
	my $d    = shift; # 
	my @args = ( 
		$$d{'name'},  $$d{'groupid'}, 
		$$d{'user_count'}, $$d{'bug_count'}, $$d{'address_count'},
		$$d{'created'}, $$d{'ts'},
		$$d{'description'},
	);
	my $top = qq|
Name       GroupID  Admins  Bugs    Ccs    Created               Modified 
-------------------------------------------------------------------------------|;
	my $format = qq|
@<<<<<<<<  @<<<<<   @<<<<   @<<<<<< @<<<<  @<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
|; 
	return ($top, $format, @args);
}


=item FORMAT_A

ASCII format for groups:

	my ($top, $format, @args) = $o_grp->FORMAT_A(\%data);

=cut

sub FORMAT_A { # 
	my $self = shift;
	my $d    = shift; # 
	my @args = ( 
		$$d{'name'},  $$d{'groupid'}, 
		$$d{'user_count'}, $$d{'bug_count'}, $$d{'address_count'},
		$$d{'created'}, $$d{'ts'},
		$$d{'description'},
		$$d{'user_ids'}, $$d{'address_ids'}, $$d{'bug_ids'},
		$$d{'bug_ids'},
	);
	my $top = qq|
Name       GroupID  Admins  Bugs    Ccs    Created               Modified 
-------------------------------------------------------------------------------|;
	my $format = qq|
@<<<<<<<<  @<<<<<   @<<<<   @<<<<<< @<<<<  @<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Admins:    @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Addresses: @*
Bugids:	   @*
|; 
	return ($top, $format, @args);
}



=item FORMAT_L

Lean (list) html format for groups:

	my ($top, $format, @args) = $o_grp->FORMAT_L(\%data);

=cut

sub FORMAT_L { # 
	my $self = shift;
	my $d    = shift; # 
	my @args = ( 
		$$d{'select'},
		$$d{'name'},  $$d{'groupid'}, 
		$$d{'user_count'}, $$d{'bug_count'}, $$d{'address_count'},
		$$d{'description'},
		$$d{'created'},
	);
	my $top = qq|<tr>
<td><b>&nbsp;</b></td>
<td><b>Name</b></td>
<td><b>GroupID</b></td>
<td><b>Admins</b></td>
<td><b>Bugs</b></td>
<td><b>Ccs</b></td>
<td><b>Description</b></td>
<td><b>Created</b></td> 
</tr>|;
	my $format = '<tr><td>'.join('&nbsp;</td><td>', @args).'&nbsp;<td></tr>';	
	return ($top, $format, @args);
}


=item FORMAT_h

html format for groups:

	my ($top, $format, @args) = $o_grp->FORMAT_h(\%data);

=cut

sub FORMAT_h { # 
	my $self = shift;
	my $d    = shift; # 
	my @args = ( 
		$$d{'select'},	
		$$d{'name'},  $$d{'groupid'}, 
		$$d{'user_count'}, $$d{'bug_count'}, $$d{'address_count'},
		$$d{'description'},
		$$d{'created'}, $$d{'ts'},
	);
	my $top = qq|<tr>
<td><b>&nbsp;</b></td>
<td><b>Name</b></td>
<td><b>GroupID</b></td>
<td><b>Admins</b></td>
<td><b>Bugs</b></td>
<td><b>Ccs</b></td>
<td><b>Description</b></td>
<td><b>Created</b></td> 
<td><b>Modified</b></td> 
</tr>|;
	$^W = 0;
	my $format = '<tr><td>'.join('&nbsp;</td><td>', @args).'&nbsp;<td></tr>';	
	return ($top, $format, @args);
}


=item FORMAT_H

HTML format for groups:

	my ($top, $format, @args) = $o_grp->FORMAT_H(\%data);

=cut

sub FORMAT_H { # 
	my $self = shift;
	my $d    = shift; # 
	my @args = ( 
		$$d{'select'},	
		$$d{'name'},  $$d{'groupid'}, 
		$$d{'user_count'}, $$d{'bug_count'}, $$d{'address_count'},
		$$d{'description'},
		$$d{'created'}, $$d{'ts'},
	);
	my $top = qq|<tr>
<td><b>&nbsp;</b></td>
<td><b>Name</b></td>
<td><b>GroupID</b></td>
<td><b>Admins</b></td>
<td><b>Bugs</b></td>
<td><b>Ccs</b></td>
<td><b>Description</b></td>
<td><b>Created</b></td> 
<td><b>Modified</b></td> 
</tr>|;
	my $format = '<tr><td>'.join('&nbsp;</td><td>', @args).'&nbsp;<td></tr>';	
	$format .= qq|
<tr>
	<td><b>Admins:</b></td><td colspan=8>$$d{'user_names'}</td>
</tr>
<tr>
	<td><b>Ccs:</b></td>	<td colspan=8>$$d{'address_names'}</td>
</tr>
|;
	$format .= qq|
<tr>
	<td><b>Add Address:</b></td>	<td colspan=8>$$d{'addaddress'}</td>
</tr>
<tr>
	<td><b>Add Bugid:</b></td>	<td colspan=8>$$d{'addabugid'}</td>
</tr>
| if $self->base->isadmin; 
	return ($top, $format, @args);
}

=pod

=back

=head1 AUTHOR

Richard Foley perlbug@rfi.net 2000

=cut


# 
1;

