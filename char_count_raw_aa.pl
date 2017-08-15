#!/usr/bin/perl -w
#Author Raju Misra
#tab input
#open the genome sequence file, note: raw sequence, fasta header removed
open (GENOME, "anth_veg_peps_all.txt") ||  die $!;
while ( <GENOME> ) {
chomp;
#split the loci information file, into 3 columns	
my ($Fastahead, $seq, $X) = split(/\t/);

my $seqlength = length ($seq);
chomp $seqlength;

print ">" . $Fastahead . "*" . $seq . "%" . $seqlength;
print "\n";
print $seq;
print "\n";

	

}
	
close (GENOME) or die( "Cannot close file : $!");