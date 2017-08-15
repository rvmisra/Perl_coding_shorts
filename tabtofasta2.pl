#!/usr/bin/perl -w
#Author Raju Misra
#tab input

my $count_N = 0;

open (GENOME, "CFreundiiNCTC09750_Candy_markers1.txt") ||  die $!;
while ( <GENOME> ) {
chomp;
#split the loci information file, into 3 columns	
my ($Fastahead, $seq, $X) = split(/\t/);

my $seqlength = length ($seq);
chomp $seqlength;

print ">" . $Fastahead . "@" . $seq . "*" . $seqlength;
print "\n";
print $seq;
print "\n";
}
	
close (GENOME) or die( "Cannot close file : $!");






