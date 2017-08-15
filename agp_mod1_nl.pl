#!/usr/bin/perl -w
#Author Raju Misra
#tab input
#open the genome sequence file, note: raw sequence, fasta header removed

my $count_N = 0;

open (GENOME, "mix1.txt") ||  die $!;
while (my $sequenceEntry = <GENOME>) {
#chomp;


print $sequenceEntry . "yes" . "\n";
}
	
close (GENOME) or die( "Cannot close file : $!");