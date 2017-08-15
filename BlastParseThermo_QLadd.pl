#!/usr/local/bin/perl
#BlastParseThermo_QLadd.pl version 1
#This adds the query length to blast tab outputs, where the query length option hasn't been
#included in the blast search.
#Providing this has the '@'sequence in the fasta header.

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
my $query_length = 0;
my $extra_tab = 0;
my $Q1 = 0;
my $Q2 = 0;
my $Q3 = 0;
my $Q4 = 0;

#Between double quotes add blast output file, where the qlength is missing
open PROTEINFILE, '<', "C_ramosum_DSM1402_rep1_merge_tab_NR_VS_NCBI_OUT.txt" or die "Cannot open file.txt: $!";
#Output file name where the qlength has been added to last column
open(OUTFILE, ">C_ramosum_DSM1402_rep1_merge_tab_NR_VS_NCBI_OUT_parse.txt");

while (my $line = <PROTEINFILE>) {
	
chomp $line;

($Q1, $Q2, $Q3, $Q4) = split /@/, $line;

my $seqlength = length ($Q2);
chomp $seqlength;
##############################################################
#Part 2 ######################################################

	
($query, $subject, $percent_id, $alignment_length, $mismatches, $gap_openings, $q_start, $q_end, $s_start, $s_end, $e_value, $bit_score) = split /\t/, $line;

print OUTFILE $query . "\t" . $subject . "\t" . $percent_id . "\t" . $alignment_length . "\t" . $mismatches . "\t" . $gap_openings . "\t" . $q_start . "\t" . $q_end . "\t" . $s_start . "\t" . $s_end . "\t" . $e_value . "\t" . $bit_score  . "\t" . $seqlength . "\n";

}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
