#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits
my $count_pilG = 0;

my $count_Acn_extraction_100ul = 0;
my $count_Acn_extraction_1ml = 0;
my $count_Cdiff_630_rep1_merge = 0;
my $count_Cdiff_630_rep2_merge = 0;
my $count_Cdiff_630_rep3_merge = 0;
my $count_Lys_STA_HO_extraction_method = 0;
my $count_Readypreps_100ul = 0;
my $count_Readypreps_1ml = 0;
my $count_SLS_merge = 0;
my $count_SLS100k_merge = 0;
my $count_SLS3k_merge = 0;
my $count_SLS50k_merge = 0;
my $count_SLS_lys_nofastprep_merge = 0;
my $count_SLS_Noice_merge = 0;
my $count_SLS_RT_merge = 0;
my $count_Urea_merge = 0;
my $count_Urea_100k = 0;
my $count_Urea_3k = 0;
my $count_Urea_50k = 0;
my $count_Urea_Lys_Nofastprep_merge = 0;
my $count_Urea_Noice_merge = 0;
my $count_Urea_RT_merge = 0;


#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">CD_cats.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
if ($sequenceEntry =~ m/Acn_extraction_100ul/i) 


{$count_Acn_extraction_100ul++}
if ($sequenceEntry =~ m/Acn_extraction_1ml/i) {$count_Acn_extraction_1ml++}
if ($sequenceEntry =~ m/Cdiff_630_rep1_merge/i) {$count_Cdiff_630_rep1_merge++}
if ($sequenceEntry =~ m/Cdiff_630_rep2_merge/i) {$count_Cdiff_630_rep2_merge++}
if ($sequenceEntry =~ m/Cdiff_630_rep3_merge/i) {$count_Cdiff_630_rep3_merge++}
if ($sequenceEntry =~ m/Lys_STA_HO_extraction_method/i) {$count_Lys_STA_HO_extraction_method++}
if ($sequenceEntry =~ m/Readypreps_100ul/i) {$count_Readypreps_100ul++}
if ($sequenceEntry =~ m/Readypreps_1ml/i) {$count_Readypreps_1ml++}
if ($sequenceEntry =~ m/SLS_merge/i) {$count_SLS_merge++}
if ($sequenceEntry =~ m/SLS100k_merge/i) {$count_SLS100k_merge++}
if ($sequenceEntry =~ m/SLS3k_merge/i) {$count_SLS3k_merge++}
if ($sequenceEntry =~ m/SLS50k_merge/i) {$count_SLS50k_merge++}
if ($sequenceEntry =~ m/SLS_lys_nofastprep_merge/i) {$count_SLS_lys_nofastprep_merge++}
if ($sequenceEntry =~ m/SLS_Noice_merge/i) {$count_SLS_Noice_merge++}
if ($sequenceEntry =~ m/SLS_RT_merge/i) {$count_SLS_RT_merge++}
if ($sequenceEntry =~ m/Urea_merge/i) {$count_Urea_merge++}
if ($sequenceEntry =~ m/Urea_100k/i) {$count_Urea_100k++}
if ($sequenceEntry =~ m/Urea_3k/i) {$count_Urea_3k++}
if ($sequenceEntry =~ m/Urea_50k/i) {$count_Urea_50k++}
if ($sequenceEntry =~ m/Urea_Lys_Nofastprep_merge/i) {$count_Urea_Lys_Nofastprep_merge++}
if ($sequenceEntry =~ m/Urea_Noice_merge/i) {$count_Urea_Noice_merge++}
if ($sequenceEntry =~ m/Urea_RT_merge/i) {$count_Urea_RT_merge++}


}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count

print OUTFILE "*Acn_extraction_100ul* *$count_Acn_extraction_100ul*\n";
print OUTFILE "*Acn_extraction_1ml* *$count_Acn_extraction_1ml*\n";
print OUTFILE "*Cdiff_630_rep1_merge* *$count_Cdiff_630_rep1_merge*\n";
print OUTFILE "*Cdiff_630_rep2_merge* *$count_Cdiff_630_rep2_merge*\n";
print OUTFILE "*Cdiff_630_rep3_merge* *$count_Cdiff_630_rep3_merge*\n";
print OUTFILE "*Lys_STA_HO_extraction_method* *$count_Lys_STA_HO_extraction_method*\n";
print OUTFILE "*Readypreps_100ul* *$count_Readypreps_100ul*\n";
print OUTFILE "*Readypreps_1ml* *$count_Readypreps_1ml*\n";
print OUTFILE "*SLS_merge* *$count_SLS_merge*\n";
print OUTFILE "*SLS100k_merge* *$count_SLS100k_merge*\n";
print OUTFILE "*SLS3k_merge* *$count_SLS3k_merge*\n";
print OUTFILE "*SLS50k_merge* *$count_SLS50k_merge*\n";
print OUTFILE "*SLS_lys_nofastprep_merge* *$count_SLS_lys_nofastprep_merge*\n";
print OUTFILE "*SLS_Noice_merge* *$count_SLS_Noice_merge*\n";
print OUTFILE "*SLS_RT_merge* *$count_SLS_RT_merge*\n";
print OUTFILE "*Urea_merge* *$count_Urea_merge*\n";
print OUTFILE "*Urea_100k* *$count_Urea_100k*\n";
print OUTFILE "*Urea_3k* *$count_Urea_3k*\n";
print OUTFILE "*Urea_50k* *$count_Urea_50k*\n";
print OUTFILE "*Urea_Lys_Nofastprep_merge* *$count_Urea_Lys_Nofastprep_merge*\n";
print OUTFILE "*Urea_Noice_merge* *$count_Urea_Noice_merge*\n";
print OUTFILE "*Urea_RT_merge* *$count_Urea_RT_merge*\n";


close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
