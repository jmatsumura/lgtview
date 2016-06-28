
=head1 NAME

LGTSeekMongo - Find Lateral Gene Transfer in sequencing data

=head1 SYNOPSIS

Need to put something useful here

=head1 DESCRIPTION

A module to run computes and process the output of data for purposes
of finding putative lateral gene transfer.

*** NOTE ***
This is a modified version of the original PM to just load the MongoDB. 
***********

=head1 AUTHOR - David R. Riley & Karsten B. Sieber 
James Matsumura (updated July 2016)

e-mail: Karsten.Sieber@gmail.com
jmatsumura@som.umaryland.edu

=head1 APPENDIX

The rest of the documentation details each of the object methods.
Internal methods are usually preceded with a _

=cut

=head2 LGTSeek.pm

 Title   : LGTSeek.pm
 Usage   : Suite of subroutines used to identify LGT
 Routines:
        new                 : Create lgtseek object
        getGiTaxon          : Create gi2taxon object
=cut

package LGTSeek;
our $VERSION = '1.12';
use warnings;
no warnings 'misc';
no warnings 'uninitialized';
use strict;
use version;

# Dependencies
use File::Basename;
use Data::Dumper;
use GiTaxon;
use Cwd;
$| = 1;

=head2 new

 Title   : new
 Usage   : my $lgtseek = LGTSeek->new({fastq => $fastq,...})
 Function: Creates a new LGTSeek object.
 Returns : An instance of LGTSeek
 Args    : A hash containing potentially several config options:

           fastq - Path fastq files.
           host_fasta - One or more fasta files to use a host references
           donor_fasta - One or more fasta files to use as donor references
           prinseq_bin - Path to prinseq perl script
           bwa_bin - Path to bwa binary
           aspera_path - Path to Aspera ascp binary
           taxon_dir - Directory where taxon information lives
           taxon_idx_dir - Directory where taxon indices can be created (or where they are)
           taxon_host - Hostname of taxon mongo database

=cut

sub new {
    my ( $class, $args ) = @_;

    my $self = $args;

    bless $self;
    return $self;
}

=head2 getGiTaxon

 Title   : getGiTaxon
 Usage   : my $gi2tax = $lgtseek->getGiTaxon({'host' => 'foobar.com'...});
 Function: Retrieve a GiTaxon object ready to assign taxonomic information
 Returns : A GiTaxon object
 Args    : A hash options to pass to GiTaxon. These could have been
           passed in globally. They can also be overridden here.

           taxon_dir - Directory where taxon information lives
           taxon_idx_dir - Directory where taxon indices can be created (or where they are)
           taxon_host - Hostname of taxon mongo database

=cut

sub getGiTaxon {
    my ( $self, $config ) = @_;
    if ( $self->{verbose} ) { print STDERR "======== &getGiTaxon: Start ========\n"; }

    # If we already have a gitaxon object we'll just return it.
    if ( !$self->{gitaxon} ) {

        # Apply any config options that came over.
        if ($config) {
            map { $self->{$_} = $config->{$_} } keys %$config;
        }

        # Create the object.
        $self->{gitaxon} = GiTaxon->new(
            {   'taxon_dir'  => $self->{taxon_dir},
                'chunk_size' => 10000,
                'idx_dir'    => $self->{taxon_idx_dir},
                'host'       => $self->{taxon_host},
                'type'       => 'nucleotide',
                'verbose'    => $self->{verbose},
            }
        );
    }
    if ( $self->{verbose} ) { print STDERR "======== &getGiTaxon: Finished ========\n"; }
    $self->time_check;
    return $self->{gitaxon};
}

1;

__END__
