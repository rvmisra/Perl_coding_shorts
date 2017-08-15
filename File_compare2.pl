#!/usr/bin/perl -w
#Author Raju Misra
#tab input
use warnings;
use strict;


open (GENOME, "test_compare4.txt") ||  die $!;
my %hash;
while (my $line = <GENOME> ) {
	   chomp($line);
       (my $word1,my $word2) = split /\t/, $line;
	   $hash{$word1} = $word2;
	 
	   }
 #Print hash for testinf purposes
while ( my ($k,$v) = each %hash ) {
    print "Key $k => value $v\n";
}    
close GENOME;  
##########################

open (GENOME2, "test_compare3.txt") ||  die $!;
my %hash2;
while (my $line2 = <GENOME2> ) {
	   chomp($line2);
       (my $word12,my $word22) = split /\t/, $line2;
	   $hash2{$word12} = $word22;
	 
	   }
# Print hash for testinf purposes
while ( my ($k2,$v2) = each %hash2 ) {
    print "Key2 $k2 => value2 $v2\n";
}    
close GENOME2;  


###############################

my %reversed_hash2 = reverse %hash2;
my @missing = grep ! exists $reversed_hash2{ $_ }, values %hash;

print "\n\n\n\n";

foreach (@missing) {
  print "\n"; #Print new fasta header here
	print "$_\n";
}



