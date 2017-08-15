#!/usr/bin/perl -w
#Author Raju Misra
#Substr2.pl - For tcdd first...

####### gene of interest ##############

my $tcdd = tcdC;
my $tcdd_S = 19280; #subtract 1
my $tcdd_length = 579; #add 1
my $Genomepos = 0;

######## upstream region ################

my $tcdd_UpS = $tcdd_S - 100; 
my $tcdd_Uplength = 100;
my $GenomeposUp = 0;

#open the genome sequence file, note: raw sequence, fasta header removed
open (GENOME, "toxin_paloc.txt") ||  die $!;

#################### within gene of interest #############################

while ( <GENOME> ) {
	
my ($Fasta_head, $Seq) = split(/\t/);

#print "$Fasta_head\n";

#extract genome sequence, based on the criterea of the loci file e.g. at position (genome pos)755720 extract 

$Genomepos=substr($Seq,$tcdd_S,$tcdd_length);

#print fasta header
print ">" . $Fasta_head . "_" . $tcdd . "\n";

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

$GenomeposUp=substr($Seq,$tcdd_UpS,$tcdd_Uplength);

#print fasta header

print ">" . $Fasta_head . "_" . $tcdd . "Upstream 100bases" . "\n";

#print extracted genome sequence
print "$GenomeposUp\n";

}


#close MYFILE;
close (GENOME) or die( "Cannot close file : $!");

