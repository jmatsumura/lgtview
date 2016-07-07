#!/usr/bin/perl

=head1 NAME

isolate_best_blast_hitse.pl - Takes paired read BLAST output from the LGTseek pipeline and 
isolates just the top hit for each read. 

=head1 SYNOPSIS

Refines a BLAST results file from all relevant hits to only the most significant hits.

=head1 DESCRIPTION

Uses the read ID and specific pair suffix to remove the non-top hits found. This assumes
ordering in the sense that read pair 1 is followed by read pair 2 like so:

SRR00010000/1 ~
SRR00010000/2 ~
SRR00010000/2 ~
SRR00010000/2 ~
SRR00010000/2 ~
SRR00020000/1 ~
SRR00020000/1 ~
SRR00020000/2 ~
SRR00030000/1 ~
SRR00030000/2 ~

And aims to produce output like this:

SRR00010000/1 ~
SRR00010000/2 ~
SRR00020000/1 ~
SRR00020000/2 ~
SRR00030000/1 ~
SRR00030000/2 ~

=head1 USAGE

./isolate_best_hits.pl lgtseek_blast.out

=head1 AUTHOR - James Matsumura

e-mail: jmatsumura@som.umaryland.edu

=cut

use strict;

if ( @ARGV != 1) {
	print "Please provide the BLAST results file containing hits for both pairs of a read like so: $0 blast_overall\n";
	exit(1);
}

my $bfile = $ARGV[0];
open(my $infile, "<$bfile") || die "Can't access BLAST results file $bfile: $!";
open(my $outfile, ">./best_blast_only.out") || die "Can't create outfile $!";

my $id=''; 

while (my $line = <$infile>) {
	my @vals = split /\t/, $line;

	if($id eq ''){ # account for start of file
		$id = $vals[0];
		print $outfile "$line";

	} elsif($id eq $vals[0]){ # account for 2nd-n best hits
		next;

	} elsif($id ne $vals[0]){ # account for next read ID
		$id = $vals[0];
		print $outfile "$line";
	}
}
