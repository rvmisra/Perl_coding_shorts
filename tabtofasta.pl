#!/usr/bin/perl -w
#Author Raju Misra
#tab input



open (GENOME, "Ecoli_NCTC09001_merge_tab.txt") ||  die $!;
while ( <GENOME> ) {
chomp;
#split the loci information file, into 3 columns	
my ($Fastahead, $seq, $X) = split(/\t/);

print ">" . $Fastahead . "\n" . $seq;
print "\n";
}
	
close (GENOME) or die( "Cannot close file : $!");