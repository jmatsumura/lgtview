#!/usr/bin/perl -w

=head1 NAME

init_db.pl - Component to initialize a MySQL DB for the TwinBLAST curation database.

=head1 SYNOPSIS

Sets up the database for the TwinBLAST user and populates the table with basic info.

=head1 DESCRIPTION

This script uses MySQL but can be reconfigured to work with other DBs.

It accepts a single argument which is the name of the database to be 
created. Thus, this script can be run like so: 

./init_db.pl my_db_name

=head1 AUTHOR - James Matsumura

e-mail: jmatsumura@som.umaryland.edu

=cut

use strict;
use DBI;


# Extract MySQL connection info from a conf file
my $chosen_db = $ARGV[1];

my $dbh = DBI->connect("DBI:mysql:;host=localhost",
						"root", "");

# First create the custom database
$dbh->do("CREATE DATABASE ?", undef, $chosen_db);

# Now grant permissions for the database
$dbh->do("GRANT ALL on ?.* TO 'twinblast'\@'localhost'", undef, $chosen_db);

# Populate the database with the two necessary tables for curation
$dbh->do("use ?", undef, $chosen_db);
$dbh->do("CREATE TABLE curation(seq_id VARCHAR(100), cv_id INT, PRIMARY KEY(seq_id))", undef);
$dbh->do("CREATE TABLE cv(name VARCHAR(100), UNIQUE(name))", undef);
$dbh->do("ALTER TABLE cv ADD COLUMN id INT NOT NULL AUTO_INCREMENT FIRST, ADD primary KEY id(id)", undef);
$dbh->do("INSERT INTO cv (name) VALUES ('yes')", undef);
$dbh->do("INSERT INTO cv (name) VALUES ('no')", undef);
$dbh->do("INSERT INTO cv (name) VALUES ('maybe')", undef);

$dbh->disconnect();
