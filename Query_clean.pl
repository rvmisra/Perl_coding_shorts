#!/usr/bin/perl -w
#Author Raju Misra
#tab input
#open the genome sequence file, note: raw sequence, fasta header removed

open (GENOME, "Query1.txt") ||  die $!;
while (my $query = <GENOME> ) {


$query =~ s/@[0-9][0-9]//g;
$query =~ s/@[0-9]//g;


print $query;
#print "\n";	
}
close (GENOME) or die( "Cannot close file : $!");