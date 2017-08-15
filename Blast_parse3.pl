#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $qid = 0;
my $sid = 0;
my $alignlen = 0;
my $pcident = 0;
my $qstart = 0;
my $qend = 0;
my $sstart = 0;
my $send = 0;
my $length = 0;
my $mismatches = 0; 
my $gap_openings = 0;
my $e_value = 0; 
my $bit_score = 0;


#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">Cdiff_Extracts_test200511_OUTPUT.txt");

while (my $line = <PROTEINFILE>) {

chomp $line;

	
($qid, $sid, $pcident, $alignlen, $mismatches, $gap_openings, $qstart, $qend, $sstart, $send, $e_value, $bit_score) = split /\t/, $line;


if ($sid !~ /Clostridium_difficile/g) {

#if ($percent_id =~ /100/) {


#print OUTFILE "$query£$subject£$percent_id£$alignment_length£$mismatches£$gap_openings£$q_start£$q_end£$s_start£$s_end£$e_value£$bit_score\n";
print OUTFILE "$qid\n";

}

}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: BA_blast_parse_OUTPUT1_query_ID_only3.txt\n";