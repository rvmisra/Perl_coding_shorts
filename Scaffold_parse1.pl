#!/usr/local/bin/perl
#Scaffold_parse1
#Author: Raju Misra

use warnings;
use strict;

my $AA = 0;
my $BB = 0;
my $CC = 0;
my $DD = 0;
my $EE = 0;
my $FF = 0;
my $GG = 0;
my $HH = 0;
my $II = 0;
my $JJ = 0;
my $KK = 0;
my $LL = 0;
my $MM = 0;
my $NN = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">SCAFFOLD_ecoli_parse_OUTPUT_PARSED1_IN_OUTBREAK_SHARED_WITH_E9_NOT_E3.txt");

while (my $line = <PROTEINFILE>) {
chomp $line;

	
($AA, $BB, $CC, $DD, $EE, $FF, $GG, $HH, $II, $JJ, $KK, $LL, $MM, $NN) = split /\t/, $line;

#OB SHARED WITH E3 AND E9
if (($MM !~ /0/) && ($NN !~ /0/)) {

print OUTFILE "$AA" . "\t" . "$BB" . "\t" . "$CC" . "\t" . "$DD" . "\t" . "$EE" . "\t" . "$FF" . "\t" . "$GG" . "\t" . "$HH" . "\t" . "$II" . "\t" . "$JJ" . "\t" . "$KK" . "\t" . "$LL" . "\t" . "$MM" . "\t" . "$NN" . "\n";

}

}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Done :)";