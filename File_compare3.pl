#!/usr/bin/perl -w
#Author Raju Misra
#tab input
use warnings;
use strict;

### OPEN FILE ####
#The query list#
open (GENOME, "test_compare2.txt") ||  die $!;

#initialise hash #####

my %hash;

#### loop through the file ####
while (my $line = <GENOME> ) {
	   chomp($line);
	   
#### split a tab seperated text file, 2 columns, by the tab into two variables	   
       (my $word1,my $word2) = split /\t/, $line;
	   
#### convert col1 into the hash key (word1) and col2 into the hash value (word2) #####       
       $hash{$word1} = $word2;
	 
	   }
###### test if you can read and that everything is in the hash as expected ######
while ( my ($k,$v) = each %hash ) {
    print "Key $k => value $v\n";
}    
close GENOME;  
##########################
#the blast output..shorter list to compare with###

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
my $count_N = 0;


my %reversed_hash2 = reverse %hash2;
my @missing = grep ! exists $reversed_hash2{ $_ }, values %hash;

print "\n\n\n\n";

foreach (@missing) {
  print ">Candidate_marker_SPECIES_NAME_" .  $count_N++ . "@" . $_;
print "\n"; #Print new fasta header here
	print "$_\n";
}

