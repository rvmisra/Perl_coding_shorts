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


open(OUTFILE, ">Line_cleanup_prots1.txt");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {
my $Count=1;
my $replace="280Contig";
if ($sequenceEntry =~ m/^>/) {
#substr(string,position,no of times,character to add)
#substr($sequenceEntry,21,1,'|');
$sequenceEntry =~ s/280Contig1/280Contig{$Count++}/g;
}
#$sequenceEntry =~ s/£/\n/g;

#$sequenceEntry =~ s/legth.*//g;

#$sequenceEntry =~ s/\n//g;
#$sequenceEntry =~ s/\r/\n/g;
#$sequenceEntry =~ s/\f/\n/g;


#$sequenceEntry =~ s/\n//g;


#$sequenceEntry =~ s/\s//g;
#$sequenceEntry =~ s/N//g;
#$sequenceEntry =~ s/n//g;
#$sequenceEntry =~ s/amendement/amendment/g;

#$sequenceEntry =~ s/\*/_/g;
#$sequenceEntry =~ s/\@/ /g;
#$sequenceEntry =~ s/\#/_/g;
#$equenceEntry =~ s/=/_/g;
#$sequenceEntry =~ s/-/_/g;
#$sequenceEntry =~ s/\./_/g;
#$sequenceEntry =~ s/\,/_/g;
#$sequenceEntry =~ s/\'//g;
#$sequenceEntry =~ s/\"/\'/g;
#$sequenceEntry =~ s/\[//g;
#$sequenceEntry =~ s/\]//g;
#$sequenceEntry =~ s/\{//g;
#$sequenceEntry =~ s/\}//g;


#$sequenceEntry =~ s/N//g;
#$sequenceEntry =~ s/\;/\t/g;
#$sequenceEntry =~ s/ //g;
#$sequenceEntry =~ s/>/\n>/g;
#$sequenceEntry =~ s/]/]\t/g;

#$sequenceEntry =~ s/format_seqs_y/formated_seqs_y/g;


#prints the 'cleaned file' to the output file 
print OUTFILE ("$sequenceEntry");

}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");
