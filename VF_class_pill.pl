#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits

my $count_pilh = 0;
my $count_pilg = 0;
my $count_pili = 0;
my $count_pilj = 0;
my $count_pilk = 0;
my $count_pill = 0;
my $count_pilr = 0;
my $count_pils = 0;
my $count_pilt = 0;
my $count_pilu = 0;

my $count_chpa = 0;
my $count_chpb = 0;
my $count_chpc = 0;
my $count_chpd = 0;
my $count_chpe = 0;

my $count_pila = 0;
my $count_pilb = 0;
my $count_pilc = 0;
my $count_pild = 0;
my $count_pilf = 0;
my $count_pilq = 0;
my $count_pilp = 0;
my $count_pilo = 0;
my $count_piln = 0;
my $count_pilm = 0;
my $count_pilz = 0;
my $count_pilv = 0;
my $count_pilw = 0;
my $count_pilx = 0;
my $count_pily1 = 0;
my $count_pily2 = 0;
my $count_pile = 0;
my $count_cpaa = 0;
my $count_cpab = 0;
my $count_cpac = 0;
my $count_cpad = 0;
my $count_cpae = 0;
my $count_cpaf = 0;

my $count_fima = 0;
my $count_fimc = 0;
my $count_fimd = 0;
my $count_fimf = 0;
my $count_fimg = 0;

my $count_fimh = 0;
my $count_fimi = 0;
my $count_sfma = 0;
my $count_sfmc = 0;
my $count_sfmd = 0;
my $count_sfmf = 0;
my $count_sfmh = 0;



#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">parse_results_pilli_count_strain_B.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
################# capsule #################################
	if ($sequenceEntry =~ m/pilh/i) {

#increments the counter
$count_pilg++
}


if ($sequenceEntry =~ m/pilg/i) {

#increments the counter
$count_pilh++
}

if ($sequenceEntry =~ m/pili/i) {

#increments the counter
$count_pili++
}


if ($sequenceEntry =~ m/pilj/i) {

#increments the counter
$count_pilj++
}

if ($sequenceEntry =~ m/pilk/i) {

#increments the counter
$count_pilk++
}

if ($sequenceEntry =~ m/pill/i) {

#increments the counter
$count_pill++
}

if ($sequenceEntry =~ m/pilr/i) {

#increments the counter
$count_pilr++
}

if ($sequenceEntry =~ m/pils/i) {

#increments the counter
$count_pils++
}

if ($sequenceEntry =~ m/pilt/i) {

#increments the counter
$count_pilt++
}

if ($sequenceEntry =~ m/[pilu]/i) {

#increments the counter
$count_pilu++
}

if ($sequenceEntry =~ m/chpa/i) {

#increments the counter
$count_chpa++
}

if ($sequenceEntry =~ m/chpb/i) {

#increments the counter
$count_chpb++
}

if ($sequenceEntry =~ m/chpc/i) {

#increments the counter
$count_chpc++
}

if ($sequenceEntry =~ m/chpd/i) {

#increments the counter
$count_chpd++
}

if ($sequenceEntry =~ m/chpe/i) {

#increments the counter
$count_chpe++
}


if ($sequenceEntry =~ m/pila/i) {

#increments the counter
$count_pila++
}


if ($sequenceEntry =~ m/pilb/i) {

#increments the counter
$count_pilb++
}


if ($sequenceEntry =~ m/pilc/i) {

#increments the counter
$count_pilc++
}


if ($sequenceEntry =~ m/pild/i) {

#increments the counter
$count_pild++
}


if ($sequenceEntry =~ m/pilf/i) {

#increments the counter
$count_pilf++
}


if ($sequenceEntry =~ m/pilq/i) {

#increments the counter
$count_pilq++
}


if ($sequenceEntry =~ m/pilp/i) {

#increments the counter
$count_pilp++
}


if ($sequenceEntry =~ m/pilo/i) {

#increments the counter
$count_pilo++
}


if ($sequenceEntry =~ m/piln/i) {

#increments the counter
$count_piln++
}


if ($sequenceEntry =~ m/pilm/i) {

#increments the counter
$count_pilm++
}


if ($sequenceEntry =~ m/pilz/i) {

#increments the counter
$count_pilz++
}


if ($sequenceEntry =~ m/pilv/i) {

#increments the counter
$count_pilv++
}


if ($sequenceEntry =~ m/pilw/i) {

#increments the counter
$count_pilw++
}


if ($sequenceEntry =~ m/pilx/i) {

#increments the counter
$count_pilx++
}


if ($sequenceEntry =~ m/pily1/i) {

#increments the counter
$count_pily1++
}


if ($sequenceEntry =~ m/pily2/i) {

#increments the counter
$count_pily2++
}


if ($sequenceEntry =~ m/pile/i) {

#increments the counter
$count_pile++
}


if ($sequenceEntry =~ m/cpaa/i) {

#increments the counter
$count_cpaa++
}


if ($sequenceEntry =~ m/cpab/i) {

#increments the counter
$count_cpab++
}


if ($sequenceEntry =~ m/cpac/i) {

#increments the counter
$count_cpac++
}


if ($sequenceEntry =~ m/cpad/i) {

#increments the counter
$count_cpad++
}


if ($sequenceEntry =~ m/cpae/i) {

#increments the counter
$count_cpae++
}


if ($sequenceEntry =~ m/cpaf/i) {

#increments the counter
$count_cpaf++
}


if ($sequenceEntry =~ m/fima/i) {

#increments the counter
$count_fima++
}


if ($sequenceEntry =~ m/fimc/i) {

#increments the counter
$count_fimc++
}


if ($sequenceEntry =~ m/fimd/i) {

#increments the counter
$count_fimd++
}


if ($sequenceEntry =~ m/fimf/i) {

#increments the counter
$count_fimf++
}


if ($sequenceEntry =~ m/fimg/i) {

#increments the counter
$count_fimg++
}


if ($sequenceEntry =~ m/fimh/i) {

#increments the counter
$count_fimh++
}


if ($sequenceEntry =~ m/fimi/i) {

#increments the counter
$count_fimi++
}


if ($sequenceEntry =~ m/sfma/i) {

#increments the counter
$count_sfma++
}


if ($sequenceEntry =~ m/sfmc/i) {

#increments the counter
$count_sfmc++
}


if ($sequenceEntry =~ m/sfmd/i) {

#increments the counter
$count_sfmd++
}


if ($sequenceEntry =~ m/sfmf/i) {

#increments the counter
$count_sfmf++
}


if ($sequenceEntry =~ m/sfmh/i) {

#increments the counter
$count_sfmh++
}





}
close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Strain 630 results:\n";

print OUTFILE "Total number of *pilh* contained in the file *$count_pilh* times\n";
print OUTFILE "Total number of *pilg* contained in the file *$count_pilg* times\n";
print OUTFILE "Total number of *pili* contained in the file *$count_pili* times\n";
print OUTFILE "Total number of *pilj* contained in the file *$count_pilj* times\n";
print OUTFILE "Total number of *pilk* contained in the file *$count_pilk* times\n";
print OUTFILE "Total number of *pill* contained in the file *$count_pill* times\n";
print OUTFILE "Total number of *pilr* contained in the file *$count_pilr* times\n";
print OUTFILE "Total number of *pils* contained in the file *$count_pils* times\n";
print OUTFILE "Total number of *pilt* contained in the file *$count_pilt* times\n";
print OUTFILE "Total number of *pilu* contained in the file *$count_pilu* times\n";

print OUTFILE "Total number of *chpa* contained in the file *$count_chpa* times\n";
print OUTFILE "Total number of *chpb* contained in the file *$count_chpb* times\n";
print OUTFILE "Total number of *chpc* contained in the file *$count_chpc* times\n";
print OUTFILE "Total number of *chpd* contained in the file *$count_chpd* times\n";
print OUTFILE "Total number of *chpe* contained in the file *$count_chpe* times\n";

print OUTFILE "Total number of *pila* contained in the file *$count_pila* times\n";
print OUTFILE "Total number of *pilb* contained in the file *$count_pilb* times\n";
print OUTFILE "Total number of *pilc* contained in the file *$count_pilc* times\n";
print OUTFILE "Total number of *pild* contained in the file *$count_pild* times\n";
print OUTFILE "Total number of *pilf* contained in the file *$count_pilf* times\n";
print OUTFILE "Total number of *pilq* contained in the file *$count_pilq* times\n";
print OUTFILE "Total number of *pilp* contained in the file *$count_pilp* times\n";
print OUTFILE "Total number of *pilo* contained in the file *$count_pilo* times\n";
print OUTFILE "Total number of *piln* contained in the file *$count_piln* times\n";
print OUTFILE "Total number of *pilm* contained in the file *$count_pilm* times\n";
print OUTFILE "Total number of *pilz* contained in the file *$count_pilz* times\n";
print OUTFILE "Total number of *pilv* contained in the file *$count_pilv* times\n";
print OUTFILE "Total number of *pilw* contained in the file *$count_pilw* times\n";
print OUTFILE "Total number of *pilx* contained in the file *$count_pilx* times\n";
print OUTFILE "Total number of *pily1* contained in the file *$count_pily1* times\n";
print OUTFILE "Total number of *pily2* contained in the file *$count_pily2* times\n";
print OUTFILE "Total number of *pile* contained in the file *$count_pile* times\n";
print OUTFILE "Total number of *cpaa* contained in the file *$count_cpaa* times\n";
print OUTFILE "Total number of *cpab* contained in the file *$count_cpab* times\n";
print OUTFILE "Total number of *cpac* contained in the file *$count_cpac* times\n";
print OUTFILE "Total number of *cpad* contained in the file *$count_cpad* times\n";
print OUTFILE "Total number of *cpae* contained in the file *$count_cpae* times\n";
print OUTFILE "Total number of *cpaf* contained in the file *$count_cpaf* times\n";

print OUTFILE "Total number of *fima* contained in the file *$count_fima* times\n";
print OUTFILE "Total number of *fimc* contained in the file *$count_fimc* times\n";
print OUTFILE "Total number of *fimd* contained in the file *$count_fimd* times\n";
print OUTFILE "Total number of *fimf* contained in the file *$count_fimf* times\n";
print OUTFILE "Total number of *fimg* contained in the file *$count_fimg* times\n";
print OUTFILE "Total number of *fimh* contained in the file *$count_fimh* times\n";
print OUTFILE "Total number of *fimi* contained in the file *$count_fimi* times\n";
print OUTFILE "Total number of *sfma* contained in the file *$count_sfma* times\n";
print OUTFILE "Total number of *sfmc* contained in the file *$count_sfmc* times\n";
print OUTFILE "Total number of *sfmd* contained in the file *$count_sfmd* times\n";
print OUTFILE "Total number of *sfmf* contained in the file *$count_sfmf* times\n";
print OUTFILE "Total number of *sfmh* contained in the file *$count_sfmh* times\n";


close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "parse_results_pilli_count_strain_B.txt\n";