#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits

my $count_meth = 0;
my $count_van = 0;
my $count_tei = 0;
my $count_tige = 0;
my $count_vanc = 0;
my $count_pen = 0;
my $count_lin = 0;
my $count_strepa = 0;
my $count_strepb = 0;
my $count_sulf = 0;
my $count_tetra = 0;
my $count_deox = 0;
my $count_fos = 0;
my $count_bac = 0;
my $count_kas = 0;
my $count_tet = 0;
my $count_rox = 0;
my $count_gly = 0;
my $count_amin = 0;
my $count_trim = 0;
my $count_strept = 0;
my $count_chloro = 0;


#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">stt_spore_prots_blast_out_list1.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
if ($sequenceEntry =~ m/methicillin/i) {$count_meth++}
if ($sequenceEntry =~ m/vancomycin/i) {$count_van++}
if ($sequenceEntry =~ m/teicoplanin/i) {$count_tei++}
if ($sequenceEntry =~ m/tigecycline/i) {$count_tige++}
if ($sequenceEntry =~ m/penicillin/i) {$count_pen++}
if ($sequenceEntry =~ m/lincomycin/i) {$count_lin++}
if ($sequenceEntry =~ m/streptogramin b/i) {$count_strepa++}
if ($sequenceEntry =~ m/sulfonamide/i) {$count_strepb++}
if ($sequenceEntry =~ m/tetracycline/i) {$count_sulf++}
if ($sequenceEntry =~ m/deoxycholate/i) {$count_tetra++}
if ($sequenceEntry =~ m/fosfomycin/i) {$count_deox++}
if ($sequenceEntry =~ m/streptogramin_a/i) {$count_fos++}
if ($sequenceEntry =~ m/bacitracin/i) {$count_bac++}
if ($sequenceEntry =~ m/kasugamycin/i) {$count_kas++}
if ($sequenceEntry =~ m/tetracycline/i) {$count_tet++}
if ($sequenceEntry =~ m/roxithromycin/i) {$count_rox++}
if ($sequenceEntry =~ m/glycylcycline/i) {$count_gly++}
if ($sequenceEntry =~ m/erythromycin/i) {$count_amin++}
if ($sequenceEntry =~ m/aminoglycoside/i) {$count_trim++}
if ($sequenceEntry =~ m/trimethoprim/i) {$count_strept++}
if ($sequenceEntry =~ m/streptomycin/i) {$count_chloro++}
if ($sequenceEntry =~ m/chloramphenicol/i) {$count_chloro++}

}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Strain 196 results:\n";


print OUTFILE "Methicillin *$count_meth*\n";
print OUTFILE "vancomycin *$count_van*\n";
print OUTFILE "Teicoplanin *$count_tei*\n";
print OUTFILE "Tigecycline *$count_tige*\n";
print OUTFILE "Penicillin *$count_pen*\n";
print OUTFILE "Lincomycin *$count_lin*\n";
print OUTFILE "Streptogramin b *$count_strepa*\n";
print OUTFILE "Sulfonamide *$count_strepb*\n";
print OUTFILE "Tetracycline *$count_sulf*\n";
print OUTFILE "Deoxycholate *$count_tetra*\n";
print OUTFILE "Fosfomycin *$count_deox*\n";
print OUTFILE "Streptogramin a *$count_fos*\n";
print OUTFILE "Bacitracin *$count_bac*\n";
print OUTFILE "Kasugamycin *$count_kas*\n";
print OUTFILE "Tetracycline *$count_tet*\n";
print OUTFILE "Roxithromycin *$count_rox*\n";
print OUTFILE "Glycylcycline *$count_gly*\n";
print OUTFILE "Erythromycin *$count_amin*\n";
print OUTFILE "Aminoglycoside *$count_trim*\n";
print OUTFILE "Trimethoprim *$count_strept*\n";
print OUTFILE "Streptomycin *$count_chloro*\n";
print OUTFILE "Chloramphenicol *$count_chloro*\n";



close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "855_spore_prots_blast_out_list1.txt\n";