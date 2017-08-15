#!/usr/bin/perl -w
#Author Raju Misra
#tab input


my $count = 1;
my $Fastahead = "[organism=Escherichia coli] [strain=H112180282]";
open (GENOME, "282map280_454AllContigs_tab.txt") ||  die $!;
while ( <GENOME> ) {
chomp;
#split the loci information file, into 3 columns	

my ($Fastahead2, $seq, $X) = split(/\t/);



print ">CS" . $count++  . " " . $Fastahead . "\n" . $seq;
print "\n";
}