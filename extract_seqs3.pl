#!/usr/bin/perl -w
#Author Raju Misra
#Substr2.pl - For tcdd first...


############ batch submission variables ##############################
my $gene = 0; 
my $Seq_start = 0;
my $Seqlength = 0;
my $SeqlenthUps = 100;

#################### sequence positions #################################

open (GENOMELOC, "gene_positions.txt") ||  die $!;

#################### within gene of interest #############################

while ( <GENOMELOC> ) {
	
my ($gene, $Seq_start, $Seqlength) = split(/\t/);

my $Seq_start_UpS = $Seq_start - 100;


#open the genome sequence file, note: raw sequence, fasta header removed
open (GENOME, "toxin_paloc.txt") ||  die $!;

#################### within gene of interest #############################

while ( <GENOME> ) {
	
my ($Fasta_head, $Seq) = split(/\t/);

#print "$Fasta_head\n";

#extract genome sequence, based on the criterea of the loci file e.g. at position (genome pos)755720 extract 

$Genomepos=substr($Seq,$Seq_start,$Seqlength);

#print fasta header
print ">" . $Fasta_head . "_" . $gene . "\n";

#print extracted genome sequence
print "$Genomepos\n";

}

close (GENOME) or die( "Cannot close file : $!");


####################### 100 bases upstream ###############################


open (GENOME, "toxin_paloc.txt") ||  die $!;

#################### within gene of interest #############################

while ( <GENOME> ) {
	
my ($Fasta_head, $Seq) = split(/\t/);

#extract genome sequence, based on the criterea of the loci file e.g. at position (genome pos)755720 extract 

$GenomeposUp=substr($Seq,$Seq_start_UpS,$SeqlenthUps);

#print fasta header

print ">" . $Fasta_head . "_" . $gene . "Upstream 100bases" . "\n";

#print extracted genome sequence
print "$GenomeposUp\n";

}

}

close (GENOME) or die( "Cannot close file : $!");

close (GENOMELOC) or die( "Cannot close file : $!");