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

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {



#$sequenceEntry =~ s/\n//g;
#$sequenceEntry =~ s/\r//g;
#$sequenceEntry =~ s/\f//g;
$sequenceEntry =~ s/ //g;
$sequenceEntry =~ s/\;/_/g;
$sequenceEntry =~ s/\./_/g;
$sequenceEntry =~ s/\,/_/g;
$sequenceEntry =~ s/\(/_/g;
$sequenceEntry =~ s/\)/_/g;
$sequenceEntry =~ s/\[/_/g;
$sequenceEntry =~ s/\]/_/g;
$sequenceEntry =~ s/\|/_/g;
#$sequenceEntry =~ s/\-/_/g;
$sequenceEntry =~ s/\//_/g;

$sequenceEntry =~ s/__/_/g;



print $sequenceEntry;

}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
                                                                                                    

