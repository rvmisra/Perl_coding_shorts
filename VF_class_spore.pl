#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits

my $count_abrb = 0;
my $count_bofa = 0;
my $count_bofc = 0;
my $count_codygtp = 0;
my $count_gere = 0;
my $count_gerr = 0;
my $count_kina = 0;
my $count_kinb = 0;
my $count_kinc = 0;
my $count_kind = 0;
my $count_kine = 0;
my $count_phra = 0;
my $count_phrc = 0;
my $count_phre = 0;
my $count_prosigmaK = 0;
my $count_rapa = 0;
my $count_rapb = 0;
my $count_rape = 0;
my $count_sda = 0;
my $count_sigmaE = 0;
my $count_sigmaF = 0;
my $count_sigmaH = 0;
my $count_sigmaK = 0;
my $count_sinI = 0;
my $count_sinr = 0;
my $count_spo0a = 0;
my $count_spo0b = 0;
my $count_spo0e = 0;
my $count_spo0f = 0;
my $count_spo0j = 0;
my $count_spo0m = 0;
my $count_spoIIA = 0;
my $count_spoIIab = 0;
my $count_spoIIb = 0;
my $count_spoIId = 0;
my $count_spoIIe = 0;
my $count_spoIIg = 0;
my $count_spoIIga = 0;
my $count_spoIIID = 0;
my $count_spoIIIj = 0;
my $count_spoIIm = 0;
my $count_spoIIp = 0;
my $count_spoIIq = 0;
my $count_spoIIr = 0;
my $count_spoIVB = 0;
my $count_spoIVCA = 0;
my $count_spoIVCB = 0;
my $count_spoIVFA = 0;
my $count_spoIVFB = 0;
my $count_sporecoatX = 0;
my $count_yisI = 0;
my $count_ynzD = 0;



#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">stt_spore_prots_blast_out_list1.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
if ($sequenceEntry =~ m/abrb/i) {$count_abrb++}
if ($sequenceEntry =~ m/bofa/i) {$count_bofa++}
if ($sequenceEntry =~ m/bofc/i) {$count_bofc++}
if ($sequenceEntry =~ m/codygtp/i) {$count_codygtp++}
if ($sequenceEntry =~ m/gere/i) {$count_gere++}
if ($sequenceEntry =~ m/gerr/i) {$count_gerr++}
if ($sequenceEntry =~ m/kina/i) {$count_kina++}
if ($sequenceEntry =~ m/kinb/i) {$count_kinb++}
if ($sequenceEntry =~ m/kinc/i) {$count_kinc++}
if ($sequenceEntry =~ m/kind/i) {$count_kind++}
if ($sequenceEntry =~ m/kine/i) {$count_kine++}
if ($sequenceEntry =~ m/phra/i) {$count_phra++}
if ($sequenceEntry =~ m/phrc/i) {$count_phrc++}
if ($sequenceEntry =~ m/phre/i) {$count_phre++}
if ($sequenceEntry =~ m/prosigmaK/i) {$count_prosigmaK++}
if ($sequenceEntry =~ m/rapa/i) {$count_rapa++}
if ($sequenceEntry =~ m/rapb/i) {$count_rapb++}
if ($sequenceEntry =~ m/rape/i) {$count_rape++}
if ($sequenceEntry =~ m/sda/i) {$count_sda++}
if ($sequenceEntry =~ m/sigmaE/i) {$count_sigmaE++}
if ($sequenceEntry =~ m/sigmaF/i) {$count_sigmaF++}
if ($sequenceEntry =~ m/sigmaH/i) {$count_sigmaH++}
if ($sequenceEntry =~ m/sigmaK/i) {$count_sigmaK++}
if ($sequenceEntry =~ m/sinI/i) {$count_sinI++}
if ($sequenceEntry =~ m/sinr/i) {$count_sinr++}
if ($sequenceEntry =~ m/spo0a/i) {$count_spo0a++}
if ($sequenceEntry =~ m/spo0b/i) {$count_spo0b++}
if ($sequenceEntry =~ m/spo0e/i) {$count_spo0e++}
if ($sequenceEntry =~ m/spo0f/i) {$count_spo0f++}
if ($sequenceEntry =~ m/spo0j/i) {$count_spo0j++}
if ($sequenceEntry =~ m/spo0m/i) {$count_spo0m++}
if ($sequenceEntry =~ m/spoIIA/i) {$count_spoIIA++}
if ($sequenceEntry =~ m/spoIIab/i) {$count_spoIIab++}
if ($sequenceEntry =~ m/spoIIb/i) {$count_spoIIb++}
if ($sequenceEntry =~ m/spoIId/i) {$count_spoIId++}
if ($sequenceEntry =~ m/spoIIe/i) {$count_spoIIe++}
if ($sequenceEntry =~ m/spoIIg/i) {$count_spoIIg++}
if ($sequenceEntry =~ m/spoIIga/i) {$count_spoIIga++}
if ($sequenceEntry =~ m/spoIIID/i) {$count_spoIIID++}
if ($sequenceEntry =~ m/spoIIIj/i) {$count_spoIIIj++}
if ($sequenceEntry =~ m/spoIIm/i) {$count_spoIIm++}
if ($sequenceEntry =~ m/spoIIp/i) {$count_spoIIp++}
if ($sequenceEntry =~ m/spoIIq/i) {$count_spoIIq++}
if ($sequenceEntry =~ m/spoIIr/i) {$count_spoIIr++}
if ($sequenceEntry =~ m/spoIVB/i) {$count_spoIVB++}
if ($sequenceEntry =~ m/spoIVCA/i) {$count_spoIVCA++}
if ($sequenceEntry =~ m/spoIVCB/i) {$count_spoIVCB++}
if ($sequenceEntry =~ m/spoIVFA/i) {$count_spoIVFA++}
if ($sequenceEntry =~ m/spoIVFB/i) {$count_spoIVFB++}
if ($sequenceEntry =~ m/sporecoatX/i) {$count_sporecoatX++}
if ($sequenceEntry =~ m/yisI/i) {$count_yisI++}
if ($sequenceEntry =~ m/ynzD/i) {$count_ynzD++}

}

close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Strain 196 results:\n";


print OUTFILE "Total number of *abrb* contained in the file *$count_abrb* times\n";
print OUTFILE "Total number of *bofa* contained in the file *$count_bofa* times\n";
print OUTFILE "Total number of *bofc* contained in the file *$count_bofc* times\n";
print OUTFILE "Total number of *codygtp* contained in the file *$count_codygtp* times\n";
print OUTFILE "Total number of *gere* contained in the file *$count_gere* times\n";
print OUTFILE "Total number of *gerr* contained in the file *$count_gerr* times\n";
print OUTFILE "Total number of *kina* contained in the file *$count_kina* times\n";
print OUTFILE "Total number of *kinb* contained in the file *$count_kinb* times\n";
print OUTFILE "Total number of *kinc* contained in the file *$count_kinc* times\n";
print OUTFILE "Total number of *kind* contained in the file *$count_kind* times\n";
print OUTFILE "Total number of *kine* contained in the file *$count_kine* times\n";
print OUTFILE "Total number of *phra* contained in the file *$count_phra* times\n";
print OUTFILE "Total number of *phrc* contained in the file *$count_phrc* times\n";
print OUTFILE "Total number of *phre* contained in the file *$count_phre* times\n";
print OUTFILE "Total number of *prosigmaK* contained in the file *$count_prosigmaK* times\n";
print OUTFILE "Total number of *rapa* contained in the file *$count_rapa* times\n";
print OUTFILE "Total number of *rapb* contained in the file *$count_rapb* times\n";
print OUTFILE "Total number of *rape* contained in the file *$count_rape* times\n";
print OUTFILE "Total number of *sda* contained in the file *$count_sda* times\n";
print OUTFILE "Total number of *sigmaE* contained in the file *$count_sigmaE* times\n";
print OUTFILE "Total number of *sigmaF* contained in the file *$count_sigmaF* times\n";
print OUTFILE "Total number of *sigmaH* contained in the file *$count_sigmaH* times\n";
print OUTFILE "Total number of *sigmaK* contained in the file *$count_sigmaK* times\n";
print OUTFILE "Total number of *sinI* contained in the file *$count_sinI* times\n";
print OUTFILE "Total number of *sinr* contained in the file *$count_sinr* times\n";
print OUTFILE "Total number of *spo0a* contained in the file *$count_spo0a* times\n";
print OUTFILE "Total number of *spo0b* contained in the file *$count_spo0b* times\n";
print OUTFILE "Total number of *spo0e* contained in the file *$count_spo0e* times\n";
print OUTFILE "Total number of *spo0f* contained in the file *$count_spo0f* times\n";
print OUTFILE "Total number of *spo0j* contained in the file *$count_spo0j* times\n";
print OUTFILE "Total number of *spo0m* contained in the file *$count_spo0m* times\n";
print OUTFILE "Total number of *spoIIA* contained in the file *$count_spoIIA* times\n";
print OUTFILE "Total number of *spoIIab* contained in the file *$count_spoIIab* times\n";
print OUTFILE "Total number of *spoIIb* contained in the file *$count_spoIIb* times\n";
print OUTFILE "Total number of *spoIId* contained in the file *$count_spoIId* times\n";
print OUTFILE "Total number of *spoIIe* contained in the file *$count_spoIIe* times\n";
print OUTFILE "Total number of *spoIIg* contained in the file *$count_spoIIg* times\n";
print OUTFILE "Total number of *spoIIga* contained in the file *$count_spoIIga* times\n";
print OUTFILE "Total number of *spoIIID* contained in the file *$count_spoIIID* times\n";
print OUTFILE "Total number of *spoIIIj* contained in the file *$count_spoIIIj* times\n";
print OUTFILE "Total number of *spoIIm* contained in the file *$count_spoIIm* times\n";
print OUTFILE "Total number of *spoIIp* contained in the file *$count_spoIIp* times\n";
print OUTFILE "Total number of *spoIIq* contained in the file *$count_spoIIq* times\n";
print OUTFILE "Total number of *spoIIr* contained in the file *$count_spoIIr* times\n";
print OUTFILE "Total number of *spoIVB* contained in the file *$count_spoIVB* times\n";
print OUTFILE "Total number of *spoIVCA* contained in the file *$count_spoIVCA* times\n";
print OUTFILE "Total number of *spoIVCB* contained in the file *$count_spoIVCB* times\n";
print OUTFILE "Total number of *spoIVFA* contained in the file *$count_spoIVFA* times\n";
print OUTFILE "Total number of *spoIVFB* contained in the file *$count_spoIVFB* times\n";
print OUTFILE "Total number of *sporecoatX* contained in the file *$count_sporecoatX* times\n";
print OUTFILE "Total number of *yisI* contained in the file *$count_yisI* times\n";
print OUTFILE "Total number of *ynzD* contained in the file *$count_ynzD* times\n";


close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "855_spore_prots_blast_out_list1.txt\n";