#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
#use strict;

#intialises the count, for counting the number of hits
my $count_CDS = 0;
my $count_tRNA = 0;
my $count_rRNA = 0;

#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">file_length.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
if ($sequenceEntry =~ m/>/) {$count_CDS++}
if ($sequenceEntry =~ m/ tRNA /) {$count_tRNA++}
if ($sequenceEntry =~ m/ rRNA /) {$count_rRNA++}

}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count

print OUTFILE "Total number of *>* is *$count_CDS*\n";




#print OUTFILE "Total number of *miscallaneous proteins* (i.e other non-classified proteins) = *$misc*";
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Open file_length.txt\n";