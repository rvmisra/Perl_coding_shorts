#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits

my $count_pilG = 0;
my $count_pilH = 0;
my $count_pilI = 0;
my $count_pilJ = 0;
my $count_pilK = 0;
my $count_pilL = 0;
my $count_pilR = 0;
my $count_pilS = 0;
my $count_pilT = 0;
my $count_pilU = 0;

my $count_chpA = 0;
my $count_chpB = 0;
my $count_chpC = 0;
my $count_chpD = 0;
my $count_chpE = 0;

my $count_pixG = 0;
my $count_pixH = 0;
my $count_pixI = 0;
my $count_pixJ = 0;
my $count_pixL = 0;

my $count_pilA = 0;
my $count_pilB = 0;
my $count_pilC = 0;
my $count_pilD = 0;
my $count_pilF = 0;
my $count_pilQ = 0;
my $count_pilP = 0;
my $count_pilO = 0;
my $count_pilN = 0;
my $count_pilM = 0;
my $count_pilZ = 0;
my $count_pilV = 0;
my $count_pilW = 0;
my $count_pilX = 0;
my $count_pilY1 = 0;
my $count_pilY2 = 0;
my $count_pilE = 0;
my $count_flp = 0;
my $count_cpaA = 0;
my $count_cpaB = 0;
my $count_cpaC = 0;
my $count_cpaD = 0;
my $count_cpaE = 0;
my $count_cpaF = 0;

my $count_fimA = 0;
my $count_fimC = 0;
my $count_fimD = 0;
my $count_fimF = 0;
my $count_fimG = 0;
my $count_fimH = 0;
my $count_fimI = 0;
my $count_sfmA = 0;
my $count_sfmC = 0;
my $count_sfmD = 0;
my $count_sfmF = 0;
my $count_sfmH = 0;

#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">mots.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
if ($sequenceEntry =~ m/pilG/i) {$count_pilG++}
if ($sequenceEntry =~ m/pilH/i) {$count_pilH++}
if ($sequenceEntry =~ m/pilI/i) {$count_pilI++}
if ($sequenceEntry =~ m/pilJ/i) {$count_pilJ++}
if ($sequenceEntry =~ m/pilK/i) {$count_pilK++}
if ($sequenceEntry =~ m/pilL/i) {$count_pilL++}
if ($sequenceEntry =~ m/pilR/i) {$count_pilR++}
if ($sequenceEntry =~ m/pilS/i) {$count_pilS++}
if ($sequenceEntry =~ m/pilT/i) {$count_pilT++}
if ($sequenceEntry =~ m/pilU/i) {$count_pilU++}

if ($sequenceEntry =~ m/chpA/i) {$count_chpA++}
if ($sequenceEntry =~ m/chpB/i) {$count_chpB++}
if ($sequenceEntry =~ m/chpC/i) {$count_chpC++}
if ($sequenceEntry =~ m/chpD/i) {$count_chpD++}
if ($sequenceEntry =~ m/chpE/i) {$count_chpE++}

if ($sequenceEntry =~ m/pixG/i) {$count_pixG++}
if ($sequenceEntry =~ m/pixH/i) {$count_pixH++}
if ($sequenceEntry =~ m/pixI/i) {$count_pixI++}
if ($sequenceEntry =~ m/pixJ/i) {$count_pixJ++}
if ($sequenceEntry =~ m/pixL/i) {$count_pixL++}

if ($sequenceEntry =~ m/pilA/i) {$count_pilA++}
if ($sequenceEntry =~ m/pilB/i) {$count_pilB++}
if ($sequenceEntry =~ m/pilC/i) {$count_pilC++}
if ($sequenceEntry =~ m/pilD/i) {$count_pilD++}
if ($sequenceEntry =~ m/pilF/i) {$count_pilF++}
if ($sequenceEntry =~ m/pilQ/i) {$count_pilQ++}
if ($sequenceEntry =~ m/pilP/i) {$count_pilP++}
if ($sequenceEntry =~ m/pilO/i) {$count_pilO++}
if ($sequenceEntry =~ m/pilN/i) {$count_pilN++}
if ($sequenceEntry =~ m/pilM/i) {$count_pilM++}
if ($sequenceEntry =~ m/pilZ/i) {$count_pilZ++}
if ($sequenceEntry =~ m/pilV/i) {$count_pilV++}
if ($sequenceEntry =~ m/pilW/i) {$count_pilW++}
if ($sequenceEntry =~ m/pilX/i) {$count_pilX++}
if ($sequenceEntry =~ m/pilY1/i) {$count_pilY1++}
if ($sequenceEntry =~ m/pilY2/i) {$count_pilY2++}
if ($sequenceEntry =~ m/pilE/i) {$count_pilE++}
if ($sequenceEntry =~ m/flp/i) {$count_flp++}
if ($sequenceEntry =~ m/cpaA/i) {$count_cpaA++}
if ($sequenceEntry =~ m/cpaB/i) {$count_cpaB++}
if ($sequenceEntry =~ m/cpaC/i) {$count_cpaC++}
if ($sequenceEntry =~ m/cpaD/i) {$count_cpaD++}
if ($sequenceEntry =~ m/cpaE/i) {$count_cpaE++}
if ($sequenceEntry =~ m/cpaF/i) {$count_cpaF++}

if ($sequenceEntry =~ m/fimA/i) {$count_fimA++}
if ($sequenceEntry =~ m/fimC/i) {$count_fimC++}
if ($sequenceEntry =~ m/fimD/i) {$count_fimD++}
if ($sequenceEntry =~ m/fimF/i) {$count_fimF++}
if ($sequenceEntry =~ m/fimG/i) {$count_fimG++}
if ($sequenceEntry =~ m/fimH/i) {$count_fimH++}
if ($sequenceEntry =~ m/fimI/i) {$count_fimI++}
if ($sequenceEntry =~ m/sfmA/i) {$count_sfmA++}
if ($sequenceEntry =~ m/sfmC/i) {$count_sfmC++}
if ($sequenceEntry =~ m/sfmD/i) {$count_sfmD++}
if ($sequenceEntry =~ m/sfmF/i) {$count_sfmF++}
if ($sequenceEntry =~ m/sfmH/i) {$count_sfmH++}

}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count

print OUTFILE "Twitching protiens\n";
print OUTFILE "*pilG* *$count_pilG*\n";
print OUTFILE "*pilH* *$count_pilH*\n";
print OUTFILE "*pilI* *$count_pilI*\n";
print OUTFILE "*pilJ* *$count_pilJ*\n";
print OUTFILE "*pilK* *$count_pilK*\n";
print OUTFILE "*pilL* *$count_pilL*\n";
print OUTFILE "*pilR* *$count_pilR*\n";
print OUTFILE "*pilS* *$count_pilS*\n";
print OUTFILE "*pilT* *$count_pilT*\n";
print OUTFILE "*pilU* *$count_pilU*\n";
print OUTFILE "Chemosensory pilli system protiens\n";
print OUTFILE "*chpA* *$count_chpA*\n";
print OUTFILE "*chpB* *$count_chpB*\n";
print OUTFILE "*chpC* *$count_chpC*\n";
print OUTFILE "*chpD* *$count_chpD*\n";
print OUTFILE "*chpE* *$count_chpE*\n";
print OUTFILE "Positive phototactic motility proteins\n";
print OUTFILE "*pixG* *$count_pixG*\n";
print OUTFILE "*pixH* *$count_pixH*\n";
print OUTFILE "*pixI* *$count_pixI*\n";
print OUTFILE "*pixJ* *$count_pixJ*\n";
print OUTFILE "*pixL* *$count_pixL*\n";
print OUTFILE "Pilus proteins\n";
print OUTFILE "*pilA* *$count_pilA*\n";
print OUTFILE "*pilB* *$count_pilB*\n";
print OUTFILE "*pilC* *$count_pilC*\n";
print OUTFILE "*pilD,* *$count_pilD,*\n";
print OUTFILE "*pilF* *$count_pilF*\n";
print OUTFILE "*pilQ* *$count_pilQ*\n";
print OUTFILE "*pilP* *$count_pilP*\n";
print OUTFILE "*pilO* *$count_pilO*\n";
print OUTFILE "*pilN* *$count_pilN*\n";
print OUTFILE "*pilM* *$count_pilM*\n";
print OUTFILE "*pilZ* *$count_pilZ*\n";
print OUTFILE "*pilV* *$count_pilV*\n";
print OUTFILE "*pilW* *$count_pilW*\n";
print OUTFILE "*pilX* *$count_pilX*\n";
print OUTFILE "*pilY1* *$count_pilY1*\n";
print OUTFILE "*pilY2* *$count_pilY2*\n";
print OUTFILE "*pilE* *$count_pilE*\n";
print OUTFILE "*flp,* *$count_flp,*\n";
print OUTFILE "*cpaA,* *$count_cpaA,*\n";
print OUTFILE "*cpaB,* *$count_cpaB,*\n";
print OUTFILE "*cpaC,* *$count_cpaC,*\n";
print OUTFILE "*cpaD* *$count_cpaD*\n";
print OUTFILE "*cpaE,* *$count_cpaE,*\n";
print OUTFILE "*cpaF,* *$count_cpaF,*\n";
print OUTFILE "Fimbrial proteins\n";
print OUTFILE "*fimA* *$count_fimA*\n";
print OUTFILE "*fimC* *$count_fimC*\n";
print OUTFILE "*fimD* *$count_fimD*\n";
print OUTFILE "*fimF* *$count_fimF*\n";
print OUTFILE "*fimG* *$count_fimG*\n";
print OUTFILE "*fimH* *$count_fimH*\n";
print OUTFILE "*fimI* *$count_fimI*\n";
print OUTFILE "*sfmA* *$count_sfmA*\n";
print OUTFILE "*sfmC* *$count_sfmC*\n";
print OUTFILE "*sfmD* *$count_sfmD*\n";
print OUTFILE "*sfmF* *$count_sfmF*\n";
print OUTFILE "*sfmH* *$count_sfmH*\n";

close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "mots.txt\n";