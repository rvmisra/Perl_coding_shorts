#!/usr/bin/perl -w
#Author Raju Misra
#tab input
use warnings;
use strict;

######### PART 1 converts a fasta file to tab so that it can be put ########
######## into a hash ##############

### OPEN INPUT FILE ####
open (FILE1, "mix_test1.fasta") ||  die $!;

### OPEN OUTPUT FILE ####

open(OUTFILE1, ">mix1_test1_tab.txt");

#### loop through the file ####
while (my $line = <FILE1> ) {
	   chomp($line);
	   
	 	  $line =~ s/%?$/%/;
	  $line =~ s/\n//g;
	  $line =~ s/\r//g;
      $line =~ s/\f//g;
	  $line =~ s/%/\t/g;
	  $line =~ s/>/\n/g;
	  print OUTFILE1 "$line";

}
#closes the opened input file FILE1
close FILE1;

#closes the opened OUTPUT file OUTFILE1
close OUTFILE1;


############ PART 2 #################################
##### Puts the new tab seperated fasta file into a hash
####################################################

### OPEN FILE ####
open (FILE2, "mix1_test1_tab.txt") ||  die $!;

#initialise hash #####

my %hash;

#### loop through the file ####
while (my $line = <FILE2> ) {
	   chomp($line);
	   
#### split a tab seperated text file, 2 columns, by the tab into two variables	   
       (my $word1,my $word2) = split /\t/, $line;
	   
#### convert col1 into the hash key (word1) and col2 into the hash value (word2) #####       
       $hash{$word1} = $word2;
	 
	   }
###### test if you can read and that everything is in the hash as expected ######
### loops through hash, every key and value
while ( my ($key,$value) = each %hash ) {
	
#### prints the key and value as key XXX => value YYYY to the screen to see if it works ####
    print "Key $key => value $value\n";
}    
#closes the opened input file FILE2
close FILE2; 



	   
	   