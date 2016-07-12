#!/usr/bin/perl -w

=head1 NAME

twinblastDB - Component to access a DB for curation purposes using TwinBlast

=head1 SYNOPSIS

Communicates curation/annotations from TwinBlast page to a DB.

=head1 DESCRIPTION

This script uses MySQL but can be reconfigured to work with other DBs.

=head1 AUTHOR - James Matsumura

e-mail: jmatsumura@som.umaryland.edu

=cut

use strict;
use CGI;
use DBI;
use JSON;
use Config::IniFiles;

my $cgi = CGI->new;
my $conf = Config::IniFiles->new( -file => "$ENV{CONF}");
my $chosen_db = $ENV{CHOSEN_DB};

# Deal with the CGI inputs.
my $id = $cgi->param('seq_id');
my $annot = $cgi->param('annot_note'); # annotation note

my $db = $conf->val($chosen_db, 'dbname');
my $host = $conf->val($chosen_db, 'hostname');
my $user = $conf->val($chosen_db, 'username');
my $pw = $conf->val($chosen_db, 'password');

my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host",
						"$user", "$pw");

# Auto-increment locks the table during each statement so will avoid concurrency.
my $cv_name = &getCVname($annot);

# Need to check if this cv entry already exists. If it does, can insert 
# straight away. Else, need to add this entry to the cv table.
if(defined $cv_name){

	&updateCuration($id, $cv_name);

} else {

	# Already checked for their presence, thus insert instead of replace
	$dbh->do("INSERT INTO cv (name) VALUES(?)", undef, $annot);

	# Re-perform this check as a safety measure of sorts to make sure 
	# this new curation label actually made it into the table
	$cv_name = &getCVname($annot);
	&updateCuration($id, $cv_name);
}

$dbh->disconnect();

sub getCVname {
	my($annot) = @_;
	my $cv_name;
	$cv_name = $dbh->selectrow_array('SELECT id FROM cv WHERE name=?', undef, $annot);
	return $cv_name;
}

sub updateCuration {
	my ($id, $cv_name) = @_;
	$dbh->do("REPLACE INTO curation VALUES(?, ?)", undef, $id, $cv_name);
}
