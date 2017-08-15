#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits

my $count_cher = 0;
my $count_chea = 0;
my $count_cheb = 0;
my $count_mcp = 0;
my $count_chec = 0;
my $count_chex = 0;
my $count_chew = 0;
my $count_chev = 0;
my $count_ched = 0;


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
if ($sequenceEntry =~ m/cher/i) {$count_cher++}
if ($sequenceEntry =~ m/chea/i) {$count_chea++}
if ($sequenceEntry =~ m/cheb/i) {$count_cheb++}
if ($sequenceEntry =~ m/mcp/i) {$count_mcp++}
if ($sequenceEntry =~ m/chec/i) {$count_chec++}
if ($sequenceEntry =~ m/chex/i) {$count_chex++}
if ($sequenceEntry =~ m/chew/i) {$count_chew++}
if ($sequenceEntry =~ m/chev/i) {$count_chev++}
if ($sequenceEntry =~ m/ched/i) {$count_ched++}
}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Strain 196 results:\n";


print OUTFILE "Total number of *cher* contained in the file *$count_cher* times\n";
print OUTFILE "Total number of *chea* contained in the file *$count_chea* times\n";
print OUTFILE "Total number of *cheb* contained in the file *$count_cheb* times\n";
print OUTFILE "Total number of *mcp* contained in the file *$count_mcp* times\n";
print OUTFILE "Total number of *chec* contained in the file *$count_chec* times\n";
print OUTFILE "Total number of *chex* contained in the file *$count_chex* times\n";
print OUTFILE "Total number of *chew* contained in the file *$count_chew* times\n";
print OUTFILE "Total number of *chev* contained in the file *$count_chev* times\n";
print OUTFILE "Total number of *ched* contained in the file *$count_ched* times\n";


close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "855_spore_prots_blast_out_list1.txt\n";