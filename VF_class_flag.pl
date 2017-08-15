#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits

my $count_flih = 0;
my $count_flii = 0;
my $count_flio = 0;
my $count_fliz = 0;
my $count_flip = 0;
my $count_fliq = 0;
my $count_flir = 0;
my $count_flha = 0;
my $count_flhb = 0;
my $count_flhe = 0;
my $count_flhf = 0;

my $count_mota = 0;
my $count_motb = 0;
my $count_flig = 0;
my $count_flim = 0;
my $count_flin = 0;
my $count_fliy = 0;

my $count_flif = 0;
my $count_flgi = 0;
my $count_flga = 0;
my $count_flgh = 0;
my $count_flgb = 0;
my $count_flgc = 0;
my $count_flgd = 0;
my $count_flgf = 0;
my $count_flgg = 0;
my $count_flgj = 0;
my $count_flge = 0;
my $count_flie = 0;
my $count_flgk = 0;
my $count_flgl = 0;
my $count_flid = 0;
my $count_flik = 0;
my $count_flil = 0;
my $count_flic = 0;
my $count_flaf = 0;
my $count_flag = 0;
my $count_flba = 0;
my $count_flbb = 0;

my $count_flbc = 0;
my $count_flbd = 0;
my $count_flbt = 0;
my $count_flhc = 0;
my $count_flhd = 0;
my $count_flia = 0;
my $count_flgm = 0;
my $count_flgn = 0;
my $count_flij = 0;
my $count_flis = 0;
my $count_flit = 0;

my $count_flaa = 0;
my $count_flab = 0;
my $count_flac = 0;
my $count_flad = 0;
my $count_flae = 0;


my $count_flah = 0;
my $count_flai = 0;
my $count_flaj = 0;
my $count_flak = 0;








#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">parse_results_flag_count_strain_B.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
################# flagella #################################
	
if ($sequenceEntry =~ m/flih/i) {

#increments the counter
$count_flih++
}


if ($sequenceEntry =~ m/flii/i) {

#increments the counter
$count_flii++
}

if ($sequenceEntry =~ m/flio/i) {

#increments the counter
$count_flio++
}


if ($sequenceEntry =~ m/fliz/i) {

#increments the counter
$count_fliz++
}

if ($sequenceEntry =~ m/flip/i) {

#increments the counter
$count_flip++
}

if ($sequenceEntry =~ m/fliq/i) {

#increments the counter
$count_fliq++
}

if ($sequenceEntry =~ m/flir/i) {

#increments the counter
$count_flir++
}

if ($sequenceEntry =~ m/flha/i) {

#increments the counter
$count_flha++
}

if ($sequenceEntry =~ m/fhlb/i) {

#increments the counter
$count_flhb++
}

if ($sequenceEntry =~ m/flhe/i) {

#increments the counter
$count_flhe++
}

if ($sequenceEntry =~ m/flhf/i) {

#increments the counter
$count_flhf++
}

if ($sequenceEntry =~ m/mota/i) {

#increments the counter
$count_mota++
}

if ($sequenceEntry =~ m/motb/i) {

#increments the counter
$count_motb++
}

if ($sequenceEntry =~ m/flig/i) {

#increments the counter
$count_flig++
}

if ($sequenceEntry =~ m/flim/i) {

#increments the counter
$count_flim++
}


if ($sequenceEntry =~ m/flin/i) {

#increments the counter
$count_flin++
}


if ($sequenceEntry =~ m/fliy/i) {

#increments the counter
$count_fliy++
}


if ($sequenceEntry =~ m/flif/i) {

#increments the counter
$count_flif++
}


if ($sequenceEntry =~ m/flgi/i) {

#increments the counter
$count_flgi++
}


if ($sequenceEntry =~ m/flga/i) {

#increments the counter
$count_flga++
}


if ($sequenceEntry =~ m/flgh/i) {

#increments the counter
$count_flgh++
}


if ($sequenceEntry =~ m/flgb/i) {

#increments the counter
$count_flgb++
}


if ($sequenceEntry =~ m/flgc/i) {

#increments the counter
$count_flgc++
}


if ($sequenceEntry =~ m/flgd/i) {

#increments the counter
$count_flgd++
}


if ($sequenceEntry =~ m/flgf/i) {

#increments the counter
$count_flgf++
}


if ($sequenceEntry =~ m/flgg/i) {

#increments the counter
$count_flgg++
}


if ($sequenceEntry =~ m/flgj/i) {

#increments the counter
$count_flgj++
}


if ($sequenceEntry =~ m/flge/i) {

#increments the counter
$count_flge++
}


if ($sequenceEntry =~ m/flie/i) {

#increments the counter
$count_flie++
}


if ($sequenceEntry =~ m/flgk/i) {

#increments the counter
$count_flgk++
}


if ($sequenceEntry =~ m/flgl/i) {

#increments the counter
$count_flgl++
}


if ($sequenceEntry =~ m/flid/i) {

#increments the counter
$count_flid++
}


if ($sequenceEntry =~ m/flik/i) {

#increments the counter
$count_flik++
}


if ($sequenceEntry =~ m/flil/i) {

#increments the counter
$count_flil++
}


if ($sequenceEntry =~ m/flic/i) {

#increments the counter
$count_flic++
}


if ($sequenceEntry =~ m/flaf/i) {

#increments the counter
$count_flaf++
}


if ($sequenceEntry =~ m/flag/i) {

#increments the counter
$count_flag++
}


if ($sequenceEntry =~ m/flba/i) {

#increments the counter
$count_flba++
}


if ($sequenceEntry =~ m/flbb/i) {

#increments the counter
$count_flbb++
}


if ($sequenceEntry =~ m/flbc/i) {

#increments the counter
$count_flbc++
}


if ($sequenceEntry =~ m/flbd/i) {

#increments the counter
$count_flbd++
}


if ($sequenceEntry =~ m/flbt/i) {

#increments the counter
$count_flbt++
}


if ($sequenceEntry =~ m/flhc/i) {

#increments the counter
$count_flhc++
}


if ($sequenceEntry =~ m/flhd/i) {

#increments the counter
$count_flhd++
}


if ($sequenceEntry =~ m/flia/i) {

#increments the counter
$count_flia++
}


if ($sequenceEntry =~ m/flgm/i) {

#increments the counter
$count_flgm++
}


if ($sequenceEntry =~ m/flgn/i) {

#increments the counter
$count_flgn++
}


if ($sequenceEntry =~ m/flij/i) {

#increments the counter
$count_flij++
}


if ($sequenceEntry =~ m/flis/i) {

#increments the counter
$count_flis++
}


if ($sequenceEntry =~ m/flit/i) {

#increments the counter
$count_flit++
}

if ($sequenceEntry =~ m/fliz/i) {

#increments the counter
$count_fliz++
}

if ($sequenceEntry =~ m/flaa/i) {

#increments the counter
$count_flaa++
}

if ($sequenceEntry =~ m/flab/i) {

#increments the counter
$count_flab++
}

if ($sequenceEntry =~ m/flac/i) {

#increments the counter
$count_flac++
}

if ($sequenceEntry =~ m/flad/i) {

#increments the counter
$count_flad++
}

if ($sequenceEntry =~ m/flae/i) {

#increments the counter
$count_flae++
}

if ($sequenceEntry =~ m/flaf/i) {

#increments the counter
$count_flaf++
}

if ($sequenceEntry =~ m/flag/i) {

#increments the counter
$count_flag++
}

if ($sequenceEntry =~ m/flah/i) {

#increments the counter
$count_flah++
}

if ($sequenceEntry =~ m/flai/i) {

#increments the counter
$count_flai++
}

if ($sequenceEntry =~ m/flaj/i) {

#increments the counter
$count_flaj++
}

if ($sequenceEntry =~ m/flak/i) {

#increments the counter
$count_flak++
}


}
close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Strain A results:\n";

print OUTFILE "Total number of *flih* contained in the file *$count_flih* times\n";
print OUTFILE "Total number of *flii* contained in the file *$count_flii* times\n";
print OUTFILE "Total number of *flio* contained in the file *$count_flio* times\n";
print OUTFILE "Total number of *fliz* contained in the file *$count_fliz* times\n";
print OUTFILE "Total number of *flip* contained in the file *$count_flip* times\n";
print OUTFILE "Total number of *fliq* contained in the file *$count_fliq* times\n";
print OUTFILE "Total number of *flir* contained in the file *$count_flir* times\n";
print OUTFILE "Total number of *flha* contained in the file *$count_flha* times\n";
print OUTFILE "Total number of *flhb* contained in the file *$count_flhb* times\n";
print OUTFILE "Total number of *flhe* contained in the file *$count_flhe* times\n";
print OUTFILE "Total number of *flhf* contained in the file *$count_flhf* times\n";

print OUTFILE "Total number of *mota* contained in the file *$count_mota* times\n";
print OUTFILE "Total number of *motb* contained in the file *$count_motb* times\n";
print OUTFILE "Total number of *flig* contained in the file *$count_flig* times\n";
print OUTFILE "Total number of *flim* contained in the file *$count_flim* times\n";
print OUTFILE "Total number of *flin* contained in the file *$count_flin* times\n";
print OUTFILE "Total number of *fliy* contained in the file *$count_fliy* times\n";

print OUTFILE "Total number of *flif* contained in the file *$count_flif* times\n";
print OUTFILE "Total number of *flgi* contained in the file *$count_flgi* times\n";
print OUTFILE "Total number of *flga* contained in the file *$count_flga* times\n";
print OUTFILE "Total number of *flgh* contained in the file *$count_flgh* times\n";
print OUTFILE "Total number of *flgb* contained in the file *$count_flgb* times\n";
print OUTFILE "Total number of *flgc* contained in the file *$count_flgc* times\n";
print OUTFILE "Total number of *flgd* contained in the file *$count_flgd* times\n";
print OUTFILE "Total number of *flgf* contained in the file *$count_flgf* times\n";
print OUTFILE "Total number of *flgg* contained in the file *$count_flgg* times\n";
print OUTFILE "Total number of *flgj* contained in the file *$count_flgj* times\n";
print OUTFILE "Total number of *flge* contained in the file *$count_flge* times\n";
print OUTFILE "Total number of *flie* contained in the file *$count_flie* times\n";
print OUTFILE "Total number of *flgk* contained in the file *$count_flgk* times\n";
print OUTFILE "Total number of *flgl* contained in the file *$count_flgl* times\n";
print OUTFILE "Total number of *flid* contained in the file *$count_flid* times\n";
print OUTFILE "Total number of *flik* contained in the file *$count_flik* times\n";
print OUTFILE "Total number of *flil* contained in the file *$count_flil* times\n";
print OUTFILE "Total number of *flic* contained in the file *$count_flic* times\n";
print OUTFILE "Total number of *flaf* contained in the file *$count_flaf* times\n";
print OUTFILE "Total number of *flag* contained in the file *$count_flag* times\n";
print OUTFILE "Total number of *flba* contained in the file *$count_flba* times\n";
print OUTFILE "Total number of *flbb* contained in the file *$count_flbb* times\n";

print OUTFILE "Total number of *flbc* contained in the file *$count_flbc* times\n";
print OUTFILE "Total number of *flbd* contained in the file *$count_flbd* times\n";
print OUTFILE "Total number of *flbt* contained in the file *$count_flbt* times\n";
print OUTFILE "Total number of *flhc* contained in the file *$count_flhc* times\n";
print OUTFILE "Total number of *flhd* contained in the file *$count_flhd* times\n";
print OUTFILE "Total number of *flia* contained in the file *$count_flia* times\n";
print OUTFILE "Total number of *flgm* contained in the file *$count_flgm* times\n";
print OUTFILE "Total number of *flgn* contained in the file *$count_flgn* times\n";
print OUTFILE "Total number of *flij* contained in the file *$count_flij* times\n";
print OUTFILE "Total number of *flis* contained in the file *$count_flis* times\n";
print OUTFILE "Total number of *flit* contained in the file *$count_flit* times\n";

print OUTFILE "Total number of *flaa* contained in the file *$count_flaa* times\n";
print OUTFILE "Total number of *flab* contained in the file *$count_flab* times\n";
print OUTFILE "Total number of *flac* contained in the file *$count_flac* times\n";
print OUTFILE "Total number of *flad* contained in the file *$count_flad* times\n";
print OUTFILE "Total number of *flae* contained in the file *$count_flae* times\n";

print OUTFILE "Total number of *flah* contained in the file *$count_flah* times\n";
print OUTFILE "Total number of *flai* contained in the file *$count_flai* times\n";
print OUTFILE "Total number of *flaj* contained in the file *$count_flaj* times\n";
print OUTFILE "Total number of *flak* contained in the file *$count_flak* times\n";


close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "parse_results_flag_count_strain_B\n";