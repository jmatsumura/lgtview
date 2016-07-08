#!/usr/bin/perl

=head1 NAME

merge_fasta_or_bam.pl - More recent iterations of the LGTSeek pipeline produce split files. 
Merge these in order to accommodate the scripts currently in place to extract metadata.  

=head1 SYNOPSIS

Extracts metadata from the output of LGTseek and enables this to be loaded into LGTview.

=head1 DESCRIPTION

This script is a precursor for two scripts. First, merging FASTA files provides the input for
isolate_best_blast_hits.pl. Second, merging BAM files provides the input for extract_metadata.pl.

This script requires samtools installed in order to merge the bam files. 

=head1 USAGE

With either (fasta|bam) list file this takes 3 options. Note that the fsa/bam options
ought to be consistent with one another throughout:
./merge_fasta_or_bam.pl my_(fasta|bam).list (fasta|bam) my_out_file.(fsa|bam)

=head1 AUTHOR - James Matsumura

e-mail: jmatsumura@som.umaryland.edu

=cut

use strict;

my $samtools = "/usr/local/bin/samtools";
my $list_file = $ARGV[0];
my $fasta_or_bam = $ARGV[1];
my $out = $ARGV[2];
my $num_of_entries = 0;

if ( @ARGV != 3) {
	print "Please make sure three arguments are provided like so: ./merge_fasta_or_bam.pl my_fasta.list fasta my_out_file.fsa \n";
	exit(1)
}

open(my $outfile, ">$out" || die "Can't open file $!");

if ( $fasta_or_bam eq 'fasta') {

	print "Merging fasta files specified in list ($list_file) \n";
	print "Done merging FASTA files. Use this to run isolate_best_blast_hits.pl \n";

} elsif ( $fasta_or_bam eq 'bam') {

	print "Merging BAM files specified in list ($list_file) \n";
	print "Done merging BAM files. Use this to run extract_metadata.pl \n";

}
