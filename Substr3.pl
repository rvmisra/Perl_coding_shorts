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

my $pos_min_100 = 0; 
my $len_add_100 = 0;


#Open file, containing loci information -> 3 columns>> Loci id number : Genome pos : Product size
open MYFILE, '<', 'STB.txt' or die "Cannot open file.txt: $!";

#while the file is open do something
while ( <MYFILE> ) {

#split the loci information file, into 3 columns	
my ($A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K, $L) = split(/\t/);

$pos_min_100 = $I - 100;
$len_add_150 = $D + 200;

#print $pos_min_100;

#open the genome sequence file, note: raw sequence, fasta header removed
open (GENOME, "STB_raw2.fas") ||  die $!;
$genome = <GENOME>;
chomp($genome);

#extract genome sequence, based on the criterea of the loci file e.g. at position (genome pos)755720 extract 
#(product size)333 bases from it.
$Genomepos=substr($genome,$pos_min_100,$len_add_150);

#print fasta header
print ">" . $A . "_" . $B . "_" . $D . "\n";
#print extracted genome sequence
print $Genomepos . "\n";

}

	
close MYFILE;
close (GENOME) or die( "Cannot close file : $!");

