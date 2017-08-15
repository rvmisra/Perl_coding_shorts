#!/usr/bin/perl -w
#Author Raju Misra
#tab input

my $count_N = 0;

my $key;

open (GENOME, "test_compare4.txt") ||  die $!;
my %hash;
while (my $line = <GENOME> ) {
	   chomp($line);
       (my $word1,my $word2) = split /\t/, $line;
	   $hash{$word1} = $word2;
	 
	   }
# Print hash for testinf purposes
while ( my ($k,$v) = each %hash ) {
    print "Key $k => value $v\n";
}    
close GENOME;   


