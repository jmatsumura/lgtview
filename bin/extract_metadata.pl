#!/usr/bin/perl

=head1 NAME

extract_metadata.pl - Component of LGTview to extract the metadata from a TCGA bar code 
and then assign it to the BAM file information tied to that data.

=head1 SYNOPSIS

Extracts metadata from the output of LGTseek and enables this to be loaded into LGTview.

=head1 DESCRIPTION

The current iteration of this script only is built to handle data derived from TCGA. Future
versions will allow one to provide an input file that can assign one's own particular set of
metadata to further the capability of LGTview. The main purpose of this script is to add
the reference where the sequence is derived from from the other metadata already attached
to the BLAST results output file. 

Future iterations will allow one to call this single program to process metadata for any of
the four LGTSeek pipelines (the current is built for good donor reference and good LGT-free
recipient reference genome).

=head1 USAGE

./extract_metadata.pl cgquery_outfile relevant_bamfile best_blast_overall

=head1 AUTHOR - James Matsumura

e-mail: jmatsumura@som.umaryland.edu

=cut

use strict;
no warnings 'experimental::smartmatch'; # seems to work fine for Perl 5.18. mute this warning

my $samtools = "/usr/local/bin/samtools";
my $cgquery_file;
my $bam_file;
my $best_blast_file;
my $infile;
my $outfile;
my $string_of_metadata; # this is built out by the get_cgquery_data function

open($outfile, ">./metadata_file.out" || die "Can't open file $!");

# Extra processing will happen if three arguments are provided as to get whatever metadata
# can be found from the cgquery results if this is TCGA data. All files require the BAM
# files that detail where the reads come from in the host. 
if ( @ARGV == 3) {

	$cgquery_file = $ARGV[0];
	$bam_file = $ARGV[1];
	$best_blast_file = $ARGV[2];
	print "Extracting metadata from both the cgquery result file ($cgquery_file) and BAM file ($bam_file) \n";

	open($infile, "<$cgquery_file" || die "Can't open file $cgquery_file");

	# This next array contains all fields from cgquery that are desired to be included in the metadata results
	# except for analyte_code and sample_type which both require special processing
	my @relevant_fields = qw( disease_abbr library_strategy platform );

	while (my $line = <$infile>){

		$line =~ /^\s+(\w+)\s+:/;

		# Analyte code and sample type require some additional processing that requires the 
		# report charts from TCGA in order to convert these values into meaningful data. 
		# These will be properly accounted for once the site is up and running again. 
		if($1 eq 'analyte_code'){

		} elsif($1 eq 'sample_type') {

		}
		elsif($1 ~~ @relevant_fields) { # check if any elements in the array are present
			&get_cgquery_data($line); # build the metadata string to add on later
		}
	}

	# At this point, $string_of_metadata holds all the relevant info from the cgquery results file.
	# This will be appended along with the BAM data. 
	print "Done extracting metadata from cgquery result file \n";

	# Print header that includes cgquery fields
	print $outfile ""

} elsif ( @ARGV == 2) {
	$bam_file = $ARGV[0];
	$best_blast_file = $ARGV[1];

	# Print header that excludes cgquery fields
	print $outfile ""
}

print "Extracting metadata from the BAM file ($bam_file) \n";
open($infile, "<$best_blast_file" || die "Can't open file $best_blast_file");

# The first line needs to be tab-delimited and denote what each of the TSVs are in the file

# The next step is to append the BAM and cgquery data (if provided) to what was found from LGTseek
while (my $line = <$infile>) {

	chomp($line);
	my @vals = split /\t/, $line;

	# Value in 15 is the ID we want to search the BAM file with to pull the reference location
	my $bam_res = `$samtools view $bam_file | grep -m 1 '$vals[15]'`; # use bash
	my @bam_vals = split /\t/, $bam_res;

	my $ref_location = $bam_vals[2]; # more information here, but just grab this for now

	if ($vals[16] eq 'F') {
		print $outfile "$line\t";
	} elsif ($vals[16] eq 'R') {
		print $outfile "$line\t$ref_location$string_of_metadata\n";
	}
}

# Function to return the value tied to a particular field in a cgquery result
sub get_cgquery_data {
	my ($line) = @_;
	$line =~ /.*:\s(.*)/;
	$string_of_metadata .= "\t$1";
}
