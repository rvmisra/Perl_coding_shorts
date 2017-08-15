#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;


#Prompt the user for the name of the file to read.
open MYFILE, '<', 'motb_dna_aligned_cleaned2.fasta' or die "Cannot open file.txt: $!";

while (my $sequenceEntry = <MYFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
$sequenceEntry =~ s/>BC_/>BC_£/g;
}

close (MYFILE) or die( "Cannot close file : $!");





