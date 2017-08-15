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

my $pcunk = (100-((($line_count - ($count_s + $count_r))/$totalqueries)*100));
my $totalincdifftoadd = $totalqueries + ($totalqueries - $line_count);
print $totalincdifftoadd;


my $pcj = ($count_j/$totalqueries)*100;
my $pca = ($count_a/$totalqueries)*100;
my $pck = ($count_k/$totalqueries)*100;
my $pcl = ($count_l/$totalqueries)*100;
my $pcb = ($count_b/$totalqueries)*100;
my $pcd = ($count_d/$totalqueries)*100;
my $pcy = ($count_y/$totalqueries)*100;
my $pcv = ($count_v/$totalqueries)*100;
my $pct = ($count_t/$totalqueries)*100;
my $pcm = ($count_m/$totalqueries)*100;
my $pcn = ($count_n/$totalqueries)*100;
my $pcz = ($count_z/$totalqueries)*100;
my $pcw = ($count_w/$totalqueries)*100;
my $pcu = ($count_u/$totalqueries)*100;
my $pco = ($count_o/$totalqueries)*100;
my $pcc = ($count_c/$totalqueries)*100;
my $pcg = ($count_g/$totalqueries)*100;
my $pce = ($count_e/$totalqueries)*100;
my $pcf = ($count_f/$totalqueries)*100;
my $pch = ($count_h/$totalqueries)*100;
my $pci = ($count_i/$totalqueries)*100;
my $pcp = ($count_p/$totalqueries)*100;
my $pcq = ($count_q/$totalqueries)*100;
my $pcr = ($count_r/$totalqueries)*100;
my $pcs = ($count_s/$totalqueries)*100;


print OUTFILE "[J] Translation, ribosomal structure and biogenesis" . "\t" . $count_j . "\t" . $pcj . "\n";
print OUTFILE "[A] RNA processing and modification" . "\t" . $count_a . "\t" . $pca . "\n";
print OUTFILE "[K] Transcription" . "\t" . $count_k . "\t" . $pck . "\n";
print OUTFILE "[L] Replication, recombination and repair" . "\t" . $count_l . "\t" . $pcl . "\n";
print OUTFILE "[B] Chromatin structure and dynamics" . "\t" . $count_b . "\t" . $pcb . "\n";
print OUTFILE "[D] Cell cycle control, cell division, chromosome partitioning" . "\t" . $count_d . "\t" . $pcd . "\n";
print OUTFILE "[Y] Nuclear structure" . "\t" . $count_y . "\t" . $pcy . "\n";
print OUTFILE "[V] Defense mechanisms" . "\t" . $count_v . "\t" . $pcv . "\n";
print OUTFILE "[T] Signal transduction mechanisms" . "\t" . $count_t . "\t" . $pct .  "\n";
print OUTFILE "[M] Cell wall/membrane/envelope biogenesis" . "\t" . $count_m . "\t" . $pcm . "\n";
print OUTFILE "[N] Cell motility" . "\t" . $count_n . "\t" . $pcn . "\n";
print OUTFILE "[Z] Cytoskeleton" . "\t" . $count_z . "\t" . $pcz . "\n";
print OUTFILE "[W] Extracellular structures" . "\t" . $count_w . "\t" . $pcw . "\n";
print OUTFILE "[U] Intracellular trafficking, secretion, and vesicular transport" . "\t" . $count_u . "\t" . $pcu . "\n";
print OUTFILE "[O] Posttranslational modification, protein turnover, chaperones" . "\t" . $count_o . "\t" . $pco . "\n";
print OUTFILE "[C] Energy production and conversion" . "\t" . $count_c . "\t" . $pcc . "\n";
print OUTFILE "[G] Carbohydrate transport and metabolism" . "\t" . $count_g . "\t" . $pcg . "\n";
print OUTFILE "[E] Amino acid transport and metabolism" . "\t" . $count_e . "\t" . $pce . "\n";
print OUTFILE "[F] Nucleotide transport and metabolism" . "\t" . $count_f . "\t" . $pcf . "\n";
print OUTFILE "[H] Coenzyme transport and metabolism" . "\t" . $count_h . "\t" . $pch . "\n";
print OUTFILE "[I] Lipid transport and metabolism" . "\t" . $count_i . "\t" . $pci . "\n";
print OUTFILE "[P] Inorganic ion transport and metabolism" . "\t" . $count_p . "\t" . $pcp . "\n";
print OUTFILE "[Q] Secondary metabolites biosynthesis, transport and catabolism" . "\t" . $count_q . "\t" . $pcq . "\n\n";
print OUTFILE "[R] General function prediction only" . "\t" . $count_r . "\t" . $pcr . "\n";
print OUTFILE "[S] Function unknown" . "\t" . $count_s . "\t" . $pcs . "\n\n";
print OUTFILE "% Poorly/Uncharacterised (r+s+CDS where blast match <1e10:" . "\t" . $pcunk . "\n";

close(OUTFILE) or die ("Cannot close file : $!");