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
if ($sequenceEntry =~ m/^>/) {
#$sequenceEntry =~ s/>280Contig1|280_[0-9][0-9][0-9][0-9][0-9] />280Contig1|280_00001|/g;
substr($sequenceEntry,21,1,'|');
}
#$sequenceEntry =~ s/\n//g;
#$sequenceEntry =~ s/\r/\n/g;
#$sequenceEntry =~ s/\f/\n/g;
#$sequenceEntry =~ s/£/\n/g;

}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");

