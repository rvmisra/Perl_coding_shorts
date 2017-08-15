#!/usr/local/bin/perl
use warnings;
use strict;

#intialises the count, for counting the number of hits
my $totalqueries = 4300;
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
my $qlen = 0;
my $match_desc = 0;

my $count_j = 0;
my $count_a = 0;
my $count_k = 0;
my $count_l = 0;
my $count_b = 0;
my $count_d = 0;
my $count_y = 0;
my $count_v = 0;
my $count_t = 0;
my $count_m = 0;
my $count_n = 0;
my $count_z = 0;
my $count_w = 0;
my $count_u = 0;
my $count_o = 0;
my $count_c = 0;
my $count_g = 0;
my $count_e = 0;
my $count_f = 0;
my $count_h = 0;
my $count_i = 0;
my $count_p = 0;
my $count_q = 0;
my $count_r = 0;
my $count_s = 0;

my $line_count = 0;

print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );
open(OUTFILE, ">COGcount_OUT.txt");
while (my $line = <PROTEINFILE>) {
chomp $line;
$line_count++;	

($query, $subject, $percent_id, $alignment_length, $mismatches, $gap_openings, $q_start, $q_end, $s_start, $s_end, $e_value, $bit_score, $qlen) = split /\t/, $line;

	if ($subject =~ m/J/i) {$count_j++}
	if ($subject =~ m/A/i) {$count_a++}
	if ($subject =~ m/K/i) {$count_k++}
	if ($subject =~ m/L/i) {$count_l++}
	if ($subject =~ m/B/i) {$count_b++}
	if ($subject =~ m/D/i) {$count_d++}
	if ($subject =~ m/Y/i) {$count_y++}
	if ($subject =~ m/V/i) {$count_v++}
	if ($subject =~ m/T/i) {$count_t++}
	if ($subject =~ m/M/i) {$count_m++}
	if ($subject =~ m/N/i) {$count_n++}
	if ($subject =~ m/Z/i) {$count_z++}
	if ($subject =~ m/W/i) {$count_w++}
	if ($subject =~ m/U/i) {$count_u++}
	if ($subject =~ m/O/i) {$count_o++}
	if ($subject =~ m/C/i) {$count_c++}
	if ($subject =~ m/G/i) {$count_g++}
	if ($subject =~ m/E/i) {$count_e++}
	if ($subject =~ m/F/i) {$count_f++}
	if ($subject =~ m/H/i) {$count_h++}
	if ($subject =~ m/I/i) {$count_i++}
	if ($subject =~ m/P/i) {$count_p++}
	if ($subject =~ m/Q/i) {$count_q++}
	if ($subject =~ m/R/i) {$count_r++}
	if ($subject =~ m/S/i) {$count_s++}
	
	
}
close (PROTEINFILE) or die( "Cannot close file : $!");
#### this needs fixing ###################
my $pcunk = (100-((($line_count - ($count_s + $count_r))/$totalqueries)*100));
print $pcunk;

#prints the final word count
print OUTFILE "J" . "\t" . $count_j . "\n";
print OUTFILE "a" . "\t" . $count_a . "\n";
print OUTFILE "k" . "\t" . $count_k . "\n";
print OUTFILE "l" . "\t" . $count_l . "\n";
print OUTFILE "b" . "\t" . $count_b . "\n";
print OUTFILE "d" . "\t" . $count_d . "\n";
print OUTFILE "y" . "\t" . $count_y . "\n";
print OUTFILE "v" . "\t" . $count_v . "\n";
print OUTFILE "t" . "\t" . $count_t . "\n";
print OUTFILE "m" . "\t" . $count_m . "\n";
print OUTFILE "n" . "\t" . $count_n . "\n";
print OUTFILE "z" . "\t" . $count_z . "\n";
print OUTFILE "w" . "\t" . $count_w . "\n";
print OUTFILE "u" . "\t" . $count_u . "\n";
print OUTFILE "o" . "\t" . $count_o . "\n";
print OUTFILE "c" . "\t" . $count_c . "\n";
print OUTFILE "g" . "\t" . $count_g . "\n";
print OUTFILE "e" . "\t" . $count_e . "\n";
print OUTFILE "f" . "\t" . $count_f . "\n";
print OUTFILE "h" . "\t" . $count_h . "\n";
print OUTFILE "i" . "\t" . $count_i . "\n";
print OUTFILE "p" . "\t" . $count_p . "\n";
print OUTFILE "q" . "\t" . $count_q . "\n\n";
print OUTFILE "r" . "\t" . $count_r . "\n";
print OUTFILE "s" . "\t" . $count_s . "\n";
print OUTFILE "Poorly/Uncharacterised (r+s+CDS where blast match <1e10" . "\t" . $pcunk . "\n";

close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
