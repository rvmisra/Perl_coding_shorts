#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $A = 0;
my $B = 0;
my $C = 0;
my $D = 0;
my $E = 0;
my $F = 0;
my $G = 0;
my $H = 0;
my $I = 0;
my $J = 0;
my $K = 0;
my $L = 0;

#Open file, containing loci information -> 2 columns>> Start : End 
open MYFILE, '<', 'Spore_prots_reps123.txt' or die "Cannot open file.txt: $!";

#while the file is open do something
while ( <MYFILE> ) {

#split the tab file in to columns
my ($A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K, $L) = split(/\t/);

#if (($J > 0) || ($K > 0) || ($L > 0))
if (($J > 0) && ($K > 0) && ($L > 0)){
print $D . "\t" . $E . "\n";
}



}



	
close MYFILE;
