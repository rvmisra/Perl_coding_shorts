#!/usr/bin/perl
#Author Raju Misra

use warnings;
use strict;

######### PART 1 converts a fasta file to tab so that it can be put ########
######## into a hash ##############

### OPEN INPUT FILE ####
### Fasta file name is within quotes ###

open (FILE1, "mix_test1.fasta") ||  die $!;

### OPEN OUTPUT FILE ####
#The new tab output file to be made is within the quotes after the > sign

open(OUTFILE1, ">mix1_test1_tab.txt");

#### loop through the file ####
while (my $line = <FILE1> ) {
	   chomp($line);
	  #regular expressions... to convert fasta to tab .. its not the most elegant... but works
	  #as is the bioinformaticians way ;)
	  #if you have fasta header with a % sign it will make mistakes, you need a unique character
	  
	  #What i do is, put a % sign at the end of every line
	  $line =~ s/%?$/%/;
	  
	  #Remove all new lines so that you have one long string
	  
	  $line =~ s/\n//g;
	  $line =~ s/\r//g;
      $line =~ s/\f//g;
	  
      #Replace all % signs with a tab
      
      $line =~ s/%/\t/g;
      
      #Replace all > signs with a new line.
	  $line =~ s/>/\n/g;
	  
	#This states only put data into the hash if there is text in the line i.e. remove
	#blank lines, this was creating an error at the top of the output.
	if ($line !~ /^\s*$/) { 	  
		  
	  print OUTFILE1 "$line";

			} #Close if statement
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
	 
	   
   }#Close while loop
   
###### test if you can read and that everything is in the hash as expected ######
### loops through hash, every key and value
while ( my ($key,$value) = each %hash ) {
	
#### prints the key and value as key XXX => value YYYY to the screen to see if it works ####
    print "Key $key => value $value\n";
}    
#closes the opened input file FILE2
close FILE2; 



	   
	   