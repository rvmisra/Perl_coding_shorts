#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $A = 0;
my $B = 0;
my $C = 0;
my $D = 0;
my $E = 0;
my $F = 0;
my $G = 0;
my $H = 0;

my $match_desc = 0;


#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">Clost_extraction_peps_to_remove.txt");

while (my $line = <PROTEINFILE>) {

chomp $line;

	
($A, $B, $C, $D, $E, $F, $G, $H) = split /\t/, $line;


#if (($percent_id =~ /100/) && ($subject !~ /Clostridium_difficile/)  && ($alignment_length > 6)) {

print OUTFILE "$A" . "\n";




}

#}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: BA_blast_parse_OUTPUT2_query_ID_only.txt\n";