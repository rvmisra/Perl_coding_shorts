#!/usr/local/bin/perl
#vntr1.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
#use strict;

#intialises the count, for counting the number of hits

my $count_CD11 = 0;
my $count_CD39 = 0;
my $count_CD24 = 0;
my $count_CD18 = 0;
my $count_CD20 = 0;
my $count_CD36 = 0;
my $count_CD1 = 0;
my $count_CD47 = 0;
my $count_CD41 = 0;
my $count_CD31 = 0;
my $count_CD29 = 0;
my $count_CD38 = 0;
my $count_CD27 = 0;
my $count_CD32 = 0;
my $count_CD42 = 0;
my $count_CD33 = 0;
my $count_CD15 = 0;
my $count_CD4 = 0;
my $count_CD2 = 0;
my $count_CD30 = 0;
my $count_CD12 = 0;
my $count_CD16 = 0;
my $count_CD19 = 0;
my $count_CD21 = 0;
my $count_CD13 = 0;
my $count_CD37 = 0;
my $count_CD10 = 0;
my $count_CD6 = 0;
my $count_CD6_NEW = 0;
my $count_CD44 = 0;
my $count_CD14 = 0;
my $count_CD9 = 0;
my $count_CD34 = 0;
my $count_CD40 = 0;
my $count_CD28 = 0;
my $count_CD5 = 0;
my $count_CD43 = 0;
my $count_CD8 = 0;
my $count_CD3 = 0;
my $count_CD7 = 0;
my $count_CD26 = 0;
my $count_CD17 = 0;
my $count_CD22 = 0;
my $count_CD35 = 0;
my $count_CD23 = 0;
my $count_CD46 = 0;
my $count_CD25 = 0;
my $count_CD45 = 0;


#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );
foreach $line (<INFILE>) {
	#chomp ($line);
#opns the output file

open(OUTFILE, ">Line_cleanup_prots4.txt");

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.

if ($line =~ m/AAAAAATATA/i) {$count_CD11++}
if ($line =~ m/AAAAAG/i) {$count_CD39++}
if ($line =~ m/AAAAATG/i) {$count_CD24++}
if ($line =~ m/AAACCTTAT/i) {$count_CD18++}
if ($line =~ m/AAAGTAT/i) {$count_CD20++}
if ($line =~ m/AAGAAGAAAA/i) {$count_CD36++}
if ($line =~ m/AAGAGC/i) {$count_CD1++}
if ($line =~ m/AATAAC/i) {$count_CD47++}
if ($line =~ m/AATAAGAGA/i) {$count_CD41++}
if ($line =~ m/AATCTTTTA/i) {$count_CD31++}
if ($line =~ m/ACTTAA/i) {$count_CD29++}
if ($line =~ m/AGAAAT/i) {$count_CD38++}
if ($line =~ m/AGAATT/i) {$count_CD27++}
if ($line =~ m/AGCAGT/i) {$count_CD32++}
if ($line =~ m/AGTATATTAGTAGTTCTGTA/i) {$count_CD42++}
if ($line =~ m/AT/i) {$count_CD33++}
if ($line =~ m/ATAAAGATA/i) {$count_CD15++}
if ($line =~ m/ATAGATT/i) {$count_CD4++}
if ($line =~ m/ATCTTCT/i) {$count_CD2++}
if ($line =~ m/ATTAGTG/i) {$count_CD30++}
if ($line =~ m/CTTCAATAA/i) {$count_CD12++}
if ($line =~ m/GAAAAG/i) {$count_CD16++}
if ($line =~ m/GAACGAATT/i) {$count_CD19++}
if ($line =~ m/GATGGCTTA/i) {$count_CD21++}
if ($line =~ m/GCT/i) {$count_CD13++}
if ($line =~ m/GCTATGAA/i) {$count_CD37++}
if ($line =~ m/GTAAATAGGATGTAAAA/i) {$count_CD10++}
if ($line =~ m/TAAAAGAG/i) {$count_CD6_NEW++}
if ($line =~ m/TAAATATAATCTAA/i) {$count_CD44++}
if ($line =~ m/TAAATCAGA/i) {$count_CD14++}
if ($line =~ m/TAAGTATAGAT/i) {$count_CD9++}
if ($line =~ m/TAATAT/i) {$count_CD34++}
if ($line =~ m/TAG/i) {$count_CD40++}
if ($line =~ m/TAGATGCAT/i) {$count_CD28++}
if ($line =~ m/TAT/i) {$count_CD5++}
if ($line =~ m/TATATGGATAATATCAATTTA/i) {$count_CD43++}
if ($line =~ m/TATATTGG/i) {$count_CD8++}
if ($line =~ m/TATTGC/i) {$count_CD3++}
if ($line =~ m/TCTTCTTCC/i) {$count_CD7++}
if ($line =~ m/TCTTGTATA/i) {$count_CD26++}
if ($line =~ m/TGCTTC/i) {$count_CD17++}
if ($line =~ m/TTC/i) {$count_CD22++}
if ($line =~ m/TTCATGA/i) {$count_CD35++}
if ($line =~ m/TTCTTCAGCCTTTTTAGC/i) {$count_CD23++}
if ($line =~ m/TTCTTTAGATTAATTTTCTATACTTCCTAAATTAGTTTATTATAC/i) {$count_CD46++}
if ($line =~ m/TTGCTCATA/i) {$count_CD25++}
if ($line =~ m/TTTTATATTAACTATTTTTTTATTACTTCTATATTATTGTATCA/i) {$count_CD45++}
}



#prints the final word count

print OUTFILE "Total number of *CD11* is *$count_CD11*\n";
print OUTFILE "Total number of *CD39* is *$count_CD39*\n";
print OUTFILE "Total number of *CD24* is *$count_CD24*\n";
print OUTFILE "Total number of *CD18* is *$count_CD18*\n";
print OUTFILE "Total number of *CD20* is *$count_CD20*\n";
print OUTFILE "Total number of *CD36* is *$count_CD36*\n";
print OUTFILE "Total number of *CD1* is *$count_CD1*\n";
print OUTFILE "Total number of *CD47* is *$count_CD47*\n";
print OUTFILE "Total number of *CD41* is *$count_CD41*\n";
print OUTFILE "Total number of *CD31* is *$count_CD31*\n";
print OUTFILE "Total number of *CD29* is *$count_CD29*\n";
print OUTFILE "Total number of *CD38* is *$count_CD38*\n";
print OUTFILE "Total number of *CD27* is *$count_CD27*\n";
print OUTFILE "Total number of *CD32* is *$count_CD32*\n";
print OUTFILE "Total number of *CD42* is *$count_CD42*\n";
print OUTFILE "Total number of *CD33* is *$count_CD33*\n";
print OUTFILE "Total number of *CD15* is *$count_CD15*\n";
print OUTFILE "Total number of *CD4* is *$count_CD4*\n";
print OUTFILE "Total number of *CD2* is *$count_CD2*\n";
print OUTFILE "Total number of *CD30* is *$count_CD30*\n";
print OUTFILE "Total number of *CD12* is *$count_CD12*\n";
print OUTFILE "Total number of *CD16* is *$count_CD16*\n";
print OUTFILE "Total number of *CD19* is *$count_CD19*\n";
print OUTFILE "Total number of *CD21* is *$count_CD21*\n";
print OUTFILE "Total number of *CD13* is *$count_CD13*\n";
print OUTFILE "Total number of *CD37* is *$count_CD37*\n";
print OUTFILE "Total number of *CD10* is *$count_CD10*\n";
print OUTFILE "Total number of *CD6_NEW* is *$count_CD6_NEW*\n";
print OUTFILE "Total number of *CD44* is *$count_CD44*\n";
print OUTFILE "Total number of *CD14* is *$count_CD14*\n";
print OUTFILE "Total number of *CD9* is *$count_CD9*\n";
print OUTFILE "Total number of *CD34* is *$count_CD34*\n";
print OUTFILE "Total number of *CD40* is *$count_CD40*\n";
print OUTFILE "Total number of *CD28* is *$count_CD28*\n";
print OUTFILE "Total number of *CD5* is *$count_CD5*\n";
print OUTFILE "Total number of *CD43* is *$count_CD43*\n";
print OUTFILE "Total number of *CD8* is *$count_CD8*\n";
print OUTFILE "Total number of *CD3* is *$count_CD3*\n";
print OUTFILE "Total number of *CD7* is *$count_CD7*\n";
print OUTFILE "Total number of *CD26* is *$count_CD26*\n";
print OUTFILE "Total number of *CD17* is *$count_CD17*\n";
print OUTFILE "Total number of *CD22* is *$count_CD22*\n";
print OUTFILE "Total number of *CD35* is *$count_CD35*\n";
print OUTFILE "Total number of *CD23* is *$count_CD23*\n";
print OUTFILE "Total number of *CD46* is *$count_CD46*\n";
print OUTFILE "Total number of *CD25* is *$count_CD25*\n";
print OUTFILE "Total number of *CD45* is *$count_CD45*\n";



close (INFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!"); 
#number of miscallaneous proteins
#$misc =$count_gi - ($count_transp +$count_drug +$count_adhes +$count_hypoth +$count_toxin +$count_flag +$count_protea +$count_motil +$count_cap +$count_perm +$count_reg +$count_tax +$count_kin +$count_dehy +$count_side);
