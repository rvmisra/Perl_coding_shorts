#!/usr/local/bin/perl
#text_to_fasta1.pl
#Author: Raju Misra

use warnings;
use strict;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


open(OUTFILE, ">Text_fasta_output1.txt");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {
$sequenceEntry =~ s/_£_/\n/;

#prints the 'cleaned file' to the output file 
print OUTFILE ("$sequenceEntry");

}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: Text_fasta_output1\n";
