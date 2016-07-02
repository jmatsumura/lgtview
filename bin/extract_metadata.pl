#!/usr/bin/perl

=head1 NAME

extract_metadata.pl - Component of LGTview to extract the metadata from a TCGA bar code 
and then assign it to the BAM file information tied to that data.

=head1 SYNOPSIS

Extracts metadata from the output of LGTseek and enables this to be loaded into LGTview.

=head1 DESCRIPTION

The current iteration of this script only is built to handle data derived from TCGA. Future
versions will allow one to provide an input file that can assign one's own particular set of
metadata to further the capability of LGTview. 

=head1 USAGE

./extract_metadata.pl gcquery_outfile relevant_bamfile blast_overall

=head1 AUTHOR - James Matsumura

e-mail: jmatsumura@som.umaryland.edu

=cut

use strict;

my $samtools = "/usr/local/bin/samtools";

if ( @ARGV != 3) {
	print "Please use the following input format: $0 gcquery_outfile relevant_bamfile blast_overall\n";
	exit(1);
}
