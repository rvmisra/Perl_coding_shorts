#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

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
my $peplength = 0;
my $match_desc = 0;

my $count_gi = 0;
my $count_transp = 0;
my $count_ABC = 0;
my $count_drug = 0;
my $count_adhes = 0;
my $count_hypoth = 0;
my $count_toxin = 0;
my $count_shigatoxin = 0;
my $count_flag = 0;
my $count_protea = 0;
my $count_serineprotea = 0;
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
my $count_aggreg = 0;
my $count_hemagglut = 0;
my $count_intimin = 0;
my $count_hemolysin = 0;
my $count_tellurium = 0;
my $count_lactam = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">E32627_plate_merge_tab_NR_VS_EnterobacterUniprotNR_280cat1_TOPHIT_OUT_VFS.txt");

while (my $line = <PROTEINFILE>) {
	
	

chomp $line;

	
($query, $subject, $percent_id, $alignment_length, $mismatches, $gap_openings, $q_start, $q_end, $s_start, $s_end, $e_value, $bit_score) = split /\t/, $line;



#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
################# gi count #################################
	if ($subject =~ m/Outbreak_280_540_541/i) {

#increments the counter
$count_gi++
}
################# transp count #################################

if ($subject =~ m/transp/i) {

#increments the counter
$count_transp++
}

################# ABC trans count #################################

if ($subject =~ m/abc/i) {

#increments the counter
$count_ABC++
}

################# drug count #################################

if ($subject =~ m/drug/i) {

#increments the counter
$count_drug++
}

################# adhesion count #################################

if ($subject =~ m/adhes/i) {

#increments the counter
$count_adhes++
}

################# hypothothetical count #################################

if ($subject =~ m/hypoth/i) {

#increments the counter
$count_hypoth++
}

################# toxin count #################################

if ($subject =~ m/toxin/i) {$count_toxin++}
if ($subject =~ m/shiga_toxin/i) {$count_shigatoxin++}


################# flagella count #################################

if ($subject =~ m/flag/i) {

#increments the counter
$count_flag++
}

################# proteases count #################################

if ($subject =~ m/protea/i) {

#increments the counter
$count_protea++
}

if ($subject =~ m/serine_protease/i) {

#increments the counter
$count_serineprotea++
}


################# motility count #################################

if ($subject =~ m/motil/i) {

#increments the counter
$count_motil++
}

################# capsule count #################################

if ($subject =~ m/cap/i) {

#increments the counter
$count_cap++
}

################# surface count #################################

if ($subject =~ m/surf/i) {

#increments the counter
$count_surf++
}

################# taxis count #################################

if ($subject =~ m/taxis/i) {

#increments the counter
$count_tax++
}

################# permease count #################################

if ($subject =~ m/perm/i) {

#increments the counter
$count_perm++
}

################# regulatory count #################################

if ($subject =~ m/reg/i) {

#increments the counter
$count_reg++
}

################# kinase count #################################

if ($subject =~ m/kin/i) {

#increments the counter
$count_kin++
}

################# siderophore count #################################

if ($subject =~ m/side/i) {

#increments the counter
$count_side++
}

################# dehydrogenase count #################################

if ($subject =~ m/dehy/i) {

#increments the counter
$count_dehy++
}

################# pump count #################################

if ($subject =~ m/pump/i) {

#increments the counter
$count_pump++
}

################# capsule #################################

if ($subject =~ m/caps/i) {

#increments the counter
$count_caps++
}

################# spore count #################################

if ($subject =~ m/spore/i) {

#increments the counter
$count_spore++
}
################# phage count #################################

if ($subject =~ m/phage/i) {

#increments the counter
$count_phage++
}

################# phage count #################################

if ($subject =~ m/pilli/i) {

#increments the counter
$count_pill++
}

### ---------------------------------------------------------------------------- ####


################# resistance #################################

if ($subject =~ m/res/i) {

#increments the counter
$count_res++
}
################# signalling #################################

if ($subject =~ m/sig/i) {

#increments the counter
$count_sig++
}
################# trigger count #################################

if ($subject =~ m/trig/i) {

#increments the counter
$count_trig++
}
################# virulence specifically count #################################

if ($subject =~ m/vir/i) {

#increments the counter
$count_vir++
}

################# invasion count #################################

if ($subject =~ m/inva/i) {

#increments the counter
$count_invas++
}

################# virulence specifically count #################################

if ($subject =~ m/expo/i) {

#increments the counter
$count_exp++
}

################# aggregative #################################

if ($subject =~ m/aggreg/i) {

#increments the counter
$count_aggreg++
}

################# hemagglut #################################

if ($subject =~ m/hemagglut/i) {

#increments the counter
$count_hemagglut++
}
################# intimin #################################

if ($subject =~ m/intimin/i) {

#increments the counter
$count_intimin++
}

################# hemolysin #################################

if ($subject =~ m/hemolysin/i) {

#increments the counter
$count_hemolysin++
}

################# tellurium #################################

if ($subject =~ m/tellurium/i) {

#increments the counter
$count_tellurium++
}

################# lactam #################################

if ($subject =~ m/lactam/i) {

#increments the counter
$count_lactam++
}

}
close (PROTEINFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Search for the word, virulence, specifically\n";
print OUTFILE "virulence* $count_vir* times\n\n";

print OUTFILE "TRANSPORTER/PERMEASE/PUMP/EXPORT RELATED PROTEINS\n";
print OUTFILE "Transporters* $count_transp* times\n";
print OUTFILE "Permeases* $count_perm* times\n";
print OUTFILE "Pumps* $count_pump* times\n";
print OUTFILE "Export* $count_exp* times\n";
print OUTFILE "ABC transporter* $count_ABC* times\n\n";


print OUTFILE "RESISTANCE RELATED PROTEINS\n";
print OUTFILE "Resistance related proteins *$count_res* times\n";
print OUTFILE "Beta lactam related proteins* $count_lactam* times\n";
print OUTFILE "Tellurium related proteins* $count_tellurium* times\n";
print OUTFILE "Drug related proteins* $count_drug* times\n\n";


print OUTFILE "ADHESION + AGGREGRATION + INVASION RELATED PROTEINS\n";
print OUTFILE "Adhesion related proteins* $count_adhes* times\n";
print OUTFILE "Aggregration related proteins* $count_aggreg* times\n";
print OUTFILE "Hemagglutinin related proteins* $count_hemagglut* times\n";
print OUTFILE "Intimin related proteins* $count_intimin* times\n";
print OUTFILE "Invasion related proteins* $count_invas* times\n\n";


print OUTFILE "HYPOTHETICAL PROTEINS\n";
print OUTFILE "Hyphothetical proteins* $count_hypoth* times\n\n";


print OUTFILE "TOXIN RELATED PROTEINS\n";
print OUTFILE "Toxin (all) related proteins* $count_toxin* times\n";
print OUTFILE "Hemolysin related proteins* $count_hemolysin* times\n";
print OUTFILE "Shiga Toxin related proteins* $count_shigatoxin* times\n\n";



print OUTFILE "MOTILITY RELATED PROTEINS\n";
print OUTFILE "Flagella related proteins* $count_flag* times\n";
print OUTFILE "Motility related proteins* $count_motil* times\n";
print OUTFILE "Taxis related proteins* $count_tax* times\n";
print OUTFILE "Pilli related proteins* $count_pill* times\n\n";


print OUTFILE "PROTEASES + KINASES + DEHYDROGENASES\n";
print OUTFILE "Protease related proteins* $count_protea* times\n";
print OUTFILE "Serine Protease related proteins* $count_serineprotea* times\n";
print OUTFILE "Kinase related proteins* $count_kin* times\n";
print OUTFILE "Dehydrogenase related proteins* $count_dehy* times\n\n";

print OUTFILE "REGULATORY\n";
print OUTFILE "Signal related proteins* $count_sig* times\n";
print OUTFILE "Trigger related proteins* $count_trig* times\n";
print OUTFILE "Regulatory related proteins* $count_reg* times\n\n";


print OUTFILE "CAPSULE + SURFACE\n";
print OUTFILE "Capsule related proteins* $count_cap* times\n";
print OUTFILE "Surface related proteins* $count_surf* times\n\n";

print OUTFILE "SIDEROPHORES\n";
print OUTFILE "Siderophore related proteins* $count_side* times\n\n";

print OUTFILE "SPORE\n";
print OUTFILE "Spore related proteins* $count_spore* times\n\n";

print OUTFILE "PHAGE\n";
print OUTFILE "Phage related proteins* $count_phage* times\n\n";

close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     