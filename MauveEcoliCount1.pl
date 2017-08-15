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

my $count_Conserved_in_all_ECs = 0;
my $count_Unique_to_280CS = 0;
my $count_Unique_to_280P1 = 0;
my $count_Unique_to_280P2 = 0;
my $count_Unique_to_540_280CSPS = 0;
my $count_Unique_to_540_541 = 0;
my $count_Unique_to_540 = 0;
my $count_Unique_to_541_280CSPS = 0;
my $count_Unique_to_541 = 0;



#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">EC_Mauve_numbers.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.

if ($sequenceEntry =~ m/Conserved_in_all_ECs>/i) {$count_Conserved_in_all_ECs++}
if ($sequenceEntry =~ m/Unique_to_280CS>/i) {$count_Unique_to_280CS++}
if ($sequenceEntry =~ m/Unique_to_280P1>/i) {$count_Unique_to_280P1++}
if ($sequenceEntry =~ m/Unique_to_280P2>/i) {$count_Unique_to_280P2++}
if ($sequenceEntry =~ m/Unique_to_540_&_280CSPS>/i) {$count_Unique_to_540_280CSPS++}
if ($sequenceEntry =~ m/Unique_to_540_&_541>/i) {$count_Unique_to_540_541++}
if ($sequenceEntry =~ m/Unique_to_540>/i) {$count_Unique_to_540++}
if ($sequenceEntry =~ m/Unique_to_541_&_280CSPS>/i) {$count_Unique_to_541_280CSPS++}
if ($sequenceEntry =~ m/Unique_to_541>/i) {$count_Unique_to_541++}


}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count

print OUTFILE "*Conserved in all ECs>* *$count_Conserved_in_all_ECs*\n";
print OUTFILE "*Unique to 280CS>* *$count_Unique_to_280CS*\n";
print OUTFILE "*Unique to 280P1>* *$count_Unique_to_280P1*\n";
print OUTFILE "*Unique to 280P2>* *$count_Unique_to_280P2*\n";
print OUTFILE "*Unique to 540 & 280CSPS>* *$count_Unique_to_540_280CSPS*\n";
print OUTFILE "*Unique to 540 & 541>* *$count_Unique_to_540_541*\n";
print OUTFILE "*Unique to 540>* *$count_Unique_to_540*\n";
print OUTFILE "*Unique to 541 & 280CSPS>* *$count_Unique_to_541_280CSPS*\n";
print OUTFILE "*Unique to 541>* *$count_Unique_to_541*\n";



close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
