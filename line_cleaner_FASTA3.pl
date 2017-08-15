#!/usr/local/bin/perl
#line_cleaner1.pl
#Author: Raju Misra
#This script removes any line spaces between sequences i.e. strings
#and converts into one continuous string (sequence).


use warnings;
use strict;



#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file Darren and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


open(OUTFILE, ">Mix1_output1.txt");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {

#if ($sequenceEntry =~ m/>/) {$count++}
#my $count = 0;
#$sequenceEntry =~ s/c\|P/c\|$count++P/g;


$sequenceEntry =~ s/£/\n/g;

#prints the 'cleaned file' to the output file 
print OUTFILE ("$sequenceEntry");

}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
#print "Output in the file: Line_cleanup_prots4\n";
