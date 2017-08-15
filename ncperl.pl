#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $query = 0;
my $subject = 0;
my $percent_id = 0;
my $alignment_length = 0;
my $mismatches = 0;
my $gap_openings = 0;
my $q_start = 0;
my $q_end = 0;
my $s_start = 0;
my $s_end = 0;
my $e_value = 0;
my $bit_score = 0;
my $peplength = 0;
my $match_desc = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">E_hermanni_candymarkers1_vs_NCBI_50des20al_OUTPUT_PARSED1.txt");

while (my $line = <PROTEINFILE>) {
	
$line =~ s/@[0-9][0-9]//g;
$line =~ s/@[0-9]//g;	
	

chomp $line;

	
($query, $subject, $percent_id, $alignment_length, $mismatches, $gap_openings, $q_start, $q_end, $s_start, $s_end, $e_value, $bit_score) = split /\t/, $line;


if (($percent_id =~ /100/) && ($subject !~ /Escherichia_hermannii/gi)) {

print OUTFILE "$query" . "@" . "$alignment_length" . "\n";

}
}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Done :)";