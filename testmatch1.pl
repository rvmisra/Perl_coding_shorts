#!/usr/local/bin/perl
#testmatch1.pl
#Author: Raju Misra

use warnings;
use strict;

#file to read, which contains the string to search against
print "Enter the name of the file which has the strings to search for:\n";
my $fileToRead_first = <STDIN>;
chomp($fileToRead_first);
open (PROTEINFILE, $fileToRead_first) or die( "Cannot open file : $!" );


$/ = ">";


#Read each FASTA entry and add the sequence titles to @arrayOfNames and the sequences
#to @arrayOfSequences.
my @arrayOfNames = ();
while (my $sequenceEntry = <PROTEINFILE>) {
    if ($sequenceEntry eq ">"){
    push (@arrayOfNames, $sequenceEntry);
}

#Prompt the user for the name of the file to read and search against.
print "Enter the filename to search against and then press Enter:\n";
my $fileToRead_second = <STDIN>;
chomp($fileToRead_second);
open (INFILE, $fileToRead_second) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">match_results1.txt");
while (my $sequenceEntry_secondfile = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.

	if ($sequenceEntry_secondfile =~ m/$sequenceEntry/) {

}	
 print OUTFILE "$sequenceEntry : was a match";

}
}
close (INFILE) or die( "Cannot close file : $!");

close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Open match_results1.txt.\n";