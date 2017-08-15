#!/usr/bin/perl -w
#Author Raju Misra
#Substr2.pl
#Goes through a whole genome DNA sequence, extracts specific loci sequences 
#based on an input file, Loci id number : Genome pos : Product size
#
#Input loci file looks like this, but with header removed
#
#Genome start	Genome end	Product size
#CD1			755720		333
#CD10			677131		569


#Open file, containing loci information -> 2 columns>> Start : End 
open MYFILE, '<', 'additional_clostridium_tab.txt' or die "Cannot open file.txt: $!";

#while the file is open do something
while ( <MYFILE> ) {

#split the tab file in to columns
my ($A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K, $L) = split(/\t/);


#open the genome sequence file, note: raw sequence, fasta header removed

#extract genome sequence, based on the criterea of the loci file e.g. at position (genome pos)755720 extract 
#(product size)333 bases from it.

#Microseq region
$Genomepos=substr($B,0,600);
#Ripseq region
#$Genomepos=substr($B,300,850);

#print fasta header
print ">" . $A . "\n";
#print extracted genome sequence
print $Genomepos . "\n\n";
}
close MYFILE;


