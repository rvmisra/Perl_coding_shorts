#!/usr/bin/perl
#Author Raju Misra

use warnings;
use strict;




############ PART 2 #################################
##### Puts the new tab seperated fasta file into a hash
####################################################

### OPEN FILE ####
open (FILE2, "2arb-silva.de_2012-03-07_id34855_clostall_format3.fasta") ||  die $!;
open(OUTFILE3, ">3arb-silva.de_2012-03-07_id34855_clostall_format3.fasta");
#initialise hash #####

my %hash;
 my $count1 = 1;
#### loop through the file ####
while (my $line = <FILE2> ) {
	
	#This states only put data into the hash if there is text in the line i.e. remove
	#blank lines, this was creating an error at the top of the output.
	if ($line !~ /^\s*$/) {
	   
	chomp($line);
		   
#### split a tab seperated text file, 2 columns, by the tab into two variables	   
       (my $word1,my $word2) = split /\t/, $line;

       if ($word1 !~ m/Uncul/i) {
	   
	     
	       print OUTFILE3 ">" . $count1++ . "_" . "$word1" . "\n" . "$word2" . "\n";    
	       
         }
       	   
       }
  }
close FILE2; 
close OUTFILE3;



	   
	   