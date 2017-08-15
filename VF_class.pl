#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits
my $count_gi = 0;
my $count_transp = 0;
my $count_ABC = 0;
my $count_drug = 0;
my $count_adhes = 0;
my $count_hypoth = 0;
my $count_toxin = 0;
my $count_flag = 0;
my $count_protea = 0;
my $count_motil = 0;
my $count_cap = 0;
my $count_surf = 0;
my $count_tax = 0;
my $count_perm = 0;
my $count_reg = 0;
my $count_kin = 0;
my $count_side = 0;
my $count_dehy = 0;
my $count_pump = 0;

my $count_caps = 0;
my $count_spore = 0;
my $count_phage = 0;
my $count_pill = 0;

my $count_res = 0;
my $count_sig = 0;
my $count_trig = 0;
my $count_vir = 0;
my $count_invas = 0;
my $count_exp = 0;

my $misc = 0;


#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">file_length.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
################# gi count #################################
	if ($sequenceEntry =~ m/B/i) {

#increments the counter
$count_gi++
}

################# transp count #################################

if ($sequenceEntry =~ m/transp/i) {

#increments the counter
$count_transp++
}

################# ABC trans count #################################

if ($sequenceEntry =~ m/abc/i) {

#increments the counter
$count_ABC++
}

################# drug count #################################

if ($sequenceEntry =~ m/drug/i) {

#increments the counter
$count_drug++
}

################# adhesion count #################################

if ($sequenceEntry =~ m/adhes/i) {

#increments the counter
$count_adhes++
}

################# hypothothetical count #################################

if ($sequenceEntry =~ m/hypoth/i) {

#increments the counter
$count_hypoth++
}

################# toxin count #################################

if ($sequenceEntry =~ m/toxin/i) {

#increments the counter
$count_toxin++
}

################# flagella count #################################

if ($sequenceEntry =~ m/flag/i) {

#increments the counter
$count_flag++
}

################# proteases count #################################

if ($sequenceEntry =~ m/protea/i) {

#increments the counter
$count_protea++
}

################# motility count #################################

if ($sequenceEntry =~ m/motil/i) {

#increments the counter
$count_motil++
}

################# capsule count #################################

if ($sequenceEntry =~ m/cap/i) {

#increments the counter
$count_cap++
}

################# surface count #################################

if ($sequenceEntry =~ m/surf/i) {

#increments the counter
$count_surf++
}

################# taxis count #################################

if ($sequenceEntry =~ m/tax/i) {

#increments the counter
$count_tax++
}

################# permease count #################################

if ($sequenceEntry =~ m/perm/i) {

#increments the counter
$count_perm++
}

################# regulatory count #################################

if ($sequenceEntry =~ m/reg/i) {

#increments the counter
$count_reg++
}

################# kinase count #################################

if ($sequenceEntry =~ m/kin/i) {

#increments the counter
$count_kin++
}

################# siderophore count #################################

if ($sequenceEntry =~ m/side/i) {

#increments the counter
$count_side++
}

################# dehydrogenase count #################################

if ($sequenceEntry =~ m/dehy/i) {

#increments the counter
$count_dehy++
}

################# pump count #################################

if ($sequenceEntry =~ m/pump/i) {

#increments the counter
$count_pump++
}

################# capsule #################################

if ($sequenceEntry =~ m/caps/i) {

#increments the counter
$count_caps++
}

################# spore count #################################

if ($sequenceEntry =~ m/spore/i) {

#increments the counter
$count_spore++
}
################# phage count #################################

if ($sequenceEntry =~ m/phage/i) {

#increments the counter
$count_phage++
}

################# phage count #################################

if ($sequenceEntry =~ m/pilli/i) {

#increments the counter
$count_pill++
}

### ---------------------------------------------------------------------------- ####


################# resistance #################################

if ($sequenceEntry =~ m/res/i) {

#increments the counter
$count_res++
}
################# signalling #################################

if ($sequenceEntry =~ m/sig/i) {

#increments the counter
$count_sig++
}
################# trigger count #################################

if ($sequenceEntry =~ m/trig/i) {

#increments the counter
$count_trig++
}
################# virulence specifically count #################################

if ($sequenceEntry =~ m/vir/i) {

#increments the counter
$count_vir++
}

################# invasion count #################################

if ($sequenceEntry =~ m/inva/i) {

#increments the counter
$count_invas++
}

################# virulence specifically count #################################

if ($sequenceEntry =~ m/expo/i) {

#increments the counter
$count_exp++
}

}
close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Total number of records contained in the file = $count_gi\n\n";

print OUTFILE "Search for the word, virulence, specifically\n";
print OUTFILE "Total number of *virulence* contained in the file *$count_vir* times\n\n";

print OUTFILE "TRANSPORTER/PERMEASE/PUMP/EXPORT RELATED PROTEINS\n";
print OUTFILE "Total number of *transporters* contained in the file *$count_transp* times (of which *$count_ABC* are ABC related transporters)\n";
print OUTFILE "Total number of *permeases* contained in the file *$count_perm* times\n";
print OUTFILE "Total number of *pumps* contained in the file *$count_pump* times\n";
print OUTFILE "Total number of *export* contained in the file *$count_exp* times\n\n";


print OUTFILE "DRUG RELATED PROTEINS\n";
print OUTFILE "Total number of *resistance related proteins* contained in the file *$count_res* times\n";
print OUTFILE "Total number of *drug related proteins* contained in the file *$count_drug* times\n\n";


print OUTFILE "ADHESION + INVASION RELATED PROTEINS\n";
print OUTFILE "Total number of *adhesion related proteins* contained in the file *$count_adhes* times\n";
print OUTFILE "Total number of *invasion related proteins* contained in the file *$count_invas* times\n\n";


print OUTFILE "HYPOTHETICAL PROTEINS\n";
print OUTFILE "Total number of *hyphothetical proteins* contained in the file *$count_hypoth* times\n\n";


print OUTFILE "TOXIN RELATED PROTEINS\n";
print OUTFILE "Total number of *toxin related proteins* contained in the file *$count_toxin* times\n\n";


print OUTFILE "MOTILITY RELATED PROTEINS\n";
print OUTFILE "Total number of *flagella related proteins* contained in the file *$count_flag* times\n";
print OUTFILE "Total number of *motility related proteins* contained in the file *$count_motil* times\n";
print OUTFILE "Total number of *taxis related proteins* contained in the file *$count_tax* times\n";
print OUTFILE "Total number of *pilli related proteins* contained in the file *$count_pill* times\n\n";


print OUTFILE "PROTEASES + KINASES + DEHYDROGENASES\n";
print OUTFILE "Total number of *protease related proteins* contained in the file *$count_protea* times\n";
print OUTFILE "Total number of *kinase related proteins* contained in the file *$count_kin* times\n";
print OUTFILE "Total number of *dehydrogenase related proteins* contained in the file *$count_dehy* times\n\n";

print OUTFILE "REGULATORY\n";
print OUTFILE "Total number of *signal related proteins* contained in the file *$count_sig* times\n";
print OUTFILE "Total number of *trigger related proteins* contained in the file *$count_trig* times\n";
print OUTFILE "Total number of *regulatory related proteins* contained in the file *$count_reg* times\n\n";


print OUTFILE "CAPSULE + SURFACE\n";
print OUTFILE "Total number of *capsule related proteins* contained in the file *$count_cap* times\n";
print OUTFILE "Total number of *surface related proteins* contained in the file *$count_surf* times\n\n";

print OUTFILE "SIDEROPHORES\n";
print OUTFILE "Total number of *siderophore related proteins* contained in the file *$count_side* times\n\n";

print OUTFILE "SPORE\n";
print OUTFILE "Total number of *spore related proteins* contained in the file *$count_spore* times\n\n";

print OUTFILE "PHAGE\n";
print OUTFILE "Total number of *phage related proteins* contained in the file *$count_phage* times\n\n";


#number of miscallaneous proteins
#$misc = $count_gi - ($count_transp + $count_drug + $count_adhes + $count_hypoth + $count_toxin + $count_flag + $count_protea + $count_motil + $count_cap + $count_perm + $count_reg + $count_tax + $count_kin + $count_dehy + $count_side);


#print OUTFILE "-------------- OTHERS -------------- \n";
#print OUTFILE "Total number of *miscallaneous proteins* (i.e other non-classified proteins) = *$misc*";
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Open file_length.txt\n";