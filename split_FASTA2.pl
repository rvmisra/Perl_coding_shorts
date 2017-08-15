#!/usr/local/bin/perl
#string split.pl
#Author: Raju Misra
#This script using the split command takes multiple strings in a file, splits all the characters up into an array.  
#Then prints the contents of the array to a file.


use warnings;
use strict;

my @chars = ();

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


open(OUTFILE, ">Line_cleanup_prots4.txt");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {

@chars = split '', $sequenceEntry;
	


#prints the 'cleaned file' to the output file 
print OUTFILE ("@chars");

}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: Line_cleanup_prots4\n";
