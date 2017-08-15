#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits

my $count_chea = 0;
my $count_chew = 0;
my $count_chex = 0;
my $count_chec = 0;
my $count_ched = 0;
my $count_cher = 0;
my $count_cheb = 0;
my $count_chey = 0;
my $count_chez = 0;
my $count_chev = 0;

my $count_mcp = 0;
my $count_mcpI = 0;
my $count_mcpII = 0;
my $count_mcpIII = 0;
my $count_mcpIV = 0;

my $count_heam = 0;
my $count_hemat = 0;
my $count_aer = 0;



#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">parse_results_chem_count_strain_B.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
################# flagella #################################
	
if ($sequenceEntry =~ m/chea/i) {

#increments the counter
$count_chea++
}


if ($sequenceEntry =~ m/chew/i) {

#increments the counter
$count_chew++
}

if ($sequenceEntry =~ m/chex/i) {

#increments the counter
$count_chex++
}


if ($sequenceEntry =~ m/chec/i) {

#increments the counter
$count_chec++
}

if ($sequenceEntry =~ m/ched/i) {

#increments the counter
$count_ched++
}

if ($sequenceEntry =~ m/cher/i) {

#increments the counter
$count_cher++
}

if ($sequenceEntry =~ m/cheb/i) {

#increments the counter
$count_cheb++
}

if ($sequenceEntry =~ m/chey/i) {

#increments the counter
$count_chey++
}

if ($sequenceEntry =~ m/chez/i) {

#increments the counter
$count_chez++
}

if ($sequenceEntry =~ m/mcp/i) {

#increments the counter
$count_mcp++
}

if ($sequenceEntry =~ m/mcpI/i) {

#increments the counter
$count_mcpI++
}

if ($sequenceEntry =~ m/mcpII/i) {

#increments the counter
$count_mcpII++
}

if ($sequenceEntry =~ m/mcpIII/i) {

#increments the counter
$count_mcpIII++
}

if ($sequenceEntry =~ m/mcpIV/i) {

#increments the counter
$count_mcpIV++
}

if ($sequenceEntry =~ m/AER/i) {

#increments the counter
$count_aer++
}


if ($sequenceEntry =~ m/heam/i) {

#increments the counter
$count_heam++
}


if ($sequenceEntry =~ m/hemat/i) {

#increments the counter
$count_hemat++
}




}
close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Strain B results:\n";

print OUTFILE "Total number of *chea* contained in the file *$count_chea* times\n";
print OUTFILE "Total number of *chew* contained in the file *$count_chew* times\n";
print OUTFILE "Total number of *chex* contained in the file *$count_chex* times\n";
print OUTFILE "Total number of *chec* contained in the file *$count_chec* times\n";
print OUTFILE "Total number of *ched* contained in the file *$count_ched* times\n";
print OUTFILE "Total number of *cher* contained in the file *$count_cher* times\n";
print OUTFILE "Total number of *cheb* contained in the file *$count_cheb* times\n";
print OUTFILE "Total number of *chey* contained in the file *$count_chey* times\n";
print OUTFILE "Total number of *chez* contained in the file *$count_chez* times\n";
print OUTFILE "Total number of *chev* contained in the file *$count_chev* times\n";
print OUTFILE "Total number of *aer* contained in the file *$count_aer* times\n";


print OUTFILE "Total number of *mcp* contained in the file *$count_mcp* times\n";
print OUTFILE "Total number of *mcpI* contained in the file *$count_mcpI* times\n";
print OUTFILE "Total number of *mcpII* contained in the file *$count_mcpII* times\n";
print OUTFILE "Total number of *mcpIII* contained in the file *$count_mcpIII* times\n";
print OUTFILE "Total number of *mcpIV* contained in the file *$count_mcpIV* times\n";

print OUTFILE "Total number of *heam* contained in the file *$count_heam* times\n";
print OUTFILE "Total number of *hemat* contained in the file *$count_hemat* times\n";




close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "parse_results_chem_count_strain_B\n";