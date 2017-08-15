#!/usr/local/bin/perl
#line_cleaner1.pl
#Author: Raju Misra
#This script removes any line spaces between sequences i.e. strings
#and converts into one continuous string (sequence).


use warnings;
use strict;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


open(OUTFILE, ">nr_august_clean1.fasta");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {

$sequenceEntry =~ s/\*/_/g;
$sequenceEntry =~ s/\@/_/g;
$sequenceEntry =~ s/\#/_/g;
$sequenceEntry =~ s/=/_/g;
$sequenceEntry =~ s/-/_/g;
$sequenceEntry =~ s/\./_/g;
$sequenceEntry =~ s/\,/_/g;
$sequenceEntry =~ s/\'//g;
$sequenceEntry =~ s/\"/\'/g;
$sequenceEntry =~ s/\[/_/g;
$sequenceEntry =~ s/\]/_/g;
$sequenceEntry =~ s/\{/_/g;
$sequenceEntry =~ s/\}/_/g;
$sequenceEntry =~ s/\;/_/g;
$sequenceEntry =~ s/\:/_/g;
$sequenceEntry =~ s/ /_/g;
$sequenceEntry =~ s/\|/_/g;
$sequenceEntry =~ s/\___/_/g;
$sequenceEntry =~ s/\__/_/g;
$sequenceEntry =~ s/\__/_/g;
$sequenceEntry =~ s/\__/_/g;

#prints the 'cleaned file' to the output file 
print OUTFILE ("$sequenceEntry");

}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");
