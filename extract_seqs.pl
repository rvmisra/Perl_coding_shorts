#!/usr/bin/perl -w
#Author Raju Misra
#Substr2.pl
#Goes through a whole genome DNA sequence, extracts specific loci sequences 
#based on an input file, Loci id number : Genome pos : Product size
#
#Input loci file looks like this, but with header removed
#
#Loci no.	Genome	Product size
#CD1		755720	333
#CD10		677131	569

#Open file, containing loci information -> 3 columns>> Loci id number : Genome pos : Product size
open MYFILE, '<', 'gene_positions.txt' or die "Cannot open file.txt: $!";

#while the file is open do something
while ( <MYFILE> ) {

#split the loci information file, into 3 columns	
my ($gene, $start, $end, $X) = split(/\t/);

#open the genome sequence file, note: raw sequence, fasta header removed
open (GENOME, "toxin_paloc.txt") ||  die $!;
while ( <GENOME> ) {

#split the loci information file, into 3 columns	
#my ($fasta_header, $seq, $X) = split(/\t/);

#extract genome sequence, based on the criterea of the loci file e.g. at position (genome pos)755720 extract 
#(product size)333 bases from it.


$Genomepos=substr(GENOME,$start,$end);

#print fasta header
print ">" . $fasta_header . "_" . $gene . "\n";
#print extracted genome sequence
print $Genomepos . "\n";

}
}	
close MYFILE;
close (GENOME) or die( "Cannot close file : $!");