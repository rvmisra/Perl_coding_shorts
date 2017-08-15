#!/usr/bin/perl -w
#Author Raju Misra
#Substr2.pl
#Goes through a whole genome DNA sequence, extracts specific loci sequences 
#based on an input file, Loci id number : Genome pos : Product size
#
#Input loci file looks like this, but with header removed
#
#Genome start	Genome end	Product size
#1000540		1001796		1256
#1001819		1003900		2081
#1003937		1005019		1082
#1005076		1006200		1124


#Open file, containing loci information -> 2 columns>> Start : End 
open MYFILE, '<', 'Q23.txt' or die "Cannot open file.txt: $!";

#while the file is open do something
while ( <MYFILE> ) {

#split the loci information file, into 3 columns	
my ($A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K, $L) = split(/\t/);


#open the genome sequence file, note: raw sequence, fasta header removed
open (GENOME, "Q23m63_genome_fasta_raw.fas") ||  die $!;
$genome = <GENOME>;
chomp($genome);

#extract genome sequence, based on the criterea of the loci file 
#e.g. at position (genome pos)1000540 extract 
#(product size)1256 bases from it.
$Genomepos=substr($genome,$A,$C);

#print fasta header
print ">" . $A . "_" . $B . "_" . $C;
#print extracted genome sequence
print $Genomepos . "\n\n";

}

	
close MYFILE;
close (GENOME) or die( "Cannot close file : $!");

