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
my $count_pilH = 0;
my $count_pilI = 0;
my $count_pilJ = 0;
my $count_pilK = 0;
my $count_pilL = 0;
my $count_pilR = 0;
my $count_pilS = 0;
my $count_pilT = 0;
my $count_pilU = 0;


#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">mots.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
if ($sequenceEntry =~ m/pilG/i) {$count_pilG++}
if ($sequenceEntry =~ m/pilH/i) {$count_pilH++}
if ($sequenceEntry =~ m/pilI/i) {$count_pilI++}
if ($sequenceEntry =~ m/pilJ/i) {$count_pilJ++}
if ($sequenceEntry =~ m/pilK/i) {$count_pilK++}
if ($sequenceEntry =~ m/pilL/i) {$count_pilL++}
if ($sequenceEntry =~ m/pilR/i) {$count_pilR++}
if ($sequenceEntry =~ m/pilS/i) {$count_pilS++}
if ($sequenceEntry =~ m/pilT/i) {$count_pilT++}
if ($sequenceEntry =~ m/pilU/i) {$count_pilU++}

}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count


print OUTFILE "*pilG* *$count_pilG*\n";
print OUTFILE "*pilH* *$count_pilH*\n";
print OUTFILE "*pilI* *$count_pilI*\n";
print OUTFILE "*pilJ* *$count_pilJ*\n";
print OUTFILE "*pilK* *$count_pilK*\n";
print OUTFILE "*pilL* *$count_pilL*\n";
print OUTFILE "*pilR* *$count_pilR*\n";
print OUTFILE "*pilS* *$count_pilS*\n";
print OUTFILE "*pilT* *$count_pilT*\n";
print OUTFILE "*pilU* *$count_pilU*\n";




close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "mots.txt\n";