#!/usr/bin/perl

=head1 NAME

merge_fasta_or_bam.pl - More recent iterations of the LGTSeek pipeline produce split files. 
Merge these in order to accommodate the scripts currently in place to extract metadata.  

=head1 SYNOPSIS

Extracts metadata from the output of LGTseek and enables this to be loaded into LGTview.

=head1 DESCRIPTION

This script is a precursor for two scripts. First, merging BLAST result files provides the input for
isolate_best_blast_hits.pl which this output can then be used for extract_metadata.pl. Second, 
merging BAM files provides the other input for extract_metadata.pl.

*** PLEASE NOTE THE FOLLOWING ***
-The BLAST files should be in m8 format.
-This script requires samtools installed in order to merge the bam files. 

=head1 USAGE

With either (blast|bam) list file this takes 3 options. Note that the blast/bam options
ought to be consistent with one another throughout:
./merge_blast_or_bam.pl my_(blast|bam).list (blast|bam) my_out_file.(blast|bam)

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
	print "Please make sure three arguments are provided like so: ./merge_fasta_or_bam.pl my_blast.list blast my_out_file.blast \n";
	exit(1)
}

open(my $infile, "<$list_file" || die "Can't open file $!");

if ( $fasta_or_bam eq 'blast') {

	print "Merging BLAST files specified in list ($list_file) \n";

	# Each line in this list file is a path to an individual FASTA file
	while (my $line = <$infile>) {

		chomp($line);
		`cat $line >> $out`;
	}

	print "Done merging BLAST files. Use this to run isolate_best_blast_hits.pl \n";

} elsif ( $fasta_or_bam eq 'bam') {

	print "Merging BAM files specified in list ($list_file) \n";

	# The samtools merge command takes in individual .bam files and merges them into the
	# final outfile. Thus, build this command string using the list and run it at the end. 
	my $sam_merge_cmd = "$samtools merge $out";

	while (my $line = <$infile>) {

		chomp($line);
		$sam_merge_cmd .= " $line";
	}

	`$sam_merge_cmd`;

	print "Done merging BAM files. Use this to run extract_metadata.pl \n";

}
