#!/usr/local/bin/perl
#DB_Tidy
#Author: Raju Misra

use warnings;
use strict;

my $head = 0;
my $sequence = 0;
my $xs1 = 0;
my $xs2 = 0;



#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">Clost_DB_Tom_Make1.fasta");

while (my $line = <PROTEINFILE>) {

chomp $line;

	
($head, $sequence, $xs1, $xs2) = split /@/, $line;



#print OUTFILE "$query" . "\n";

print OUTFILE ">" . $head . "@" . $sequence . "\n";
print OUTFILE $sequence . "\n";
}


close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
