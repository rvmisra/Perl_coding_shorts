#!/usr/local/bin/perl
#convert_fasta_tab.pl
#Author: Raju Misra

use warnings;
use strict;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file Darren and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


open(OUTFILE, ">FASTA2TAB_OUT.txt");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {

$sequenceEntry =~ s/ /_/g;

if ($sequenceEntry =~ /^>/)
{
$sequenceEntry =~ s/\n/£/g;
}
$sequenceEntry =~ s/\n//g;
$sequenceEntry =~ s/£/\t/g;
$sequenceEntry =~ s/>/\n>/g;



#
#prints the 'cleaned file' to the output file 
print OUTFILE ("$sequenceEntry");
}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: Line_cleanup_prots4\n";
