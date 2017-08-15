#!/usr/local/bin/perl
#vntr1.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
#use strict;

#intialises the count, for counting the number of hits
my $count_CD46 = 0;

#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );
foreach $line (<INFILE>) {
	#chomp ($line);
#opns the output file



#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
if ($line =~ m/TTCTTTAGATTAATTTTCTATACTTCCTAAATTAGTTTATTATAC/i) {$count_CD46++}
}





#prints the final word count

print "Total number of *TTCTTTAGATTAATTTTCTATACTTCCTAAATTAGTTTATTATAC* is *$count_CD46*\n";


close (INFILE) or die( "Cannot close file : $!");
#number of miscallaneous proteins
#$misc =$count_gi - ($count_transp +$count_drug +$count_adhes +$count_hypoth +$count_toxin +$count_flag +$count_protea +$count_motil +$count_cap +$count_perm +$count_reg +$count_tax +$count_kin +$count_dehy +$count_side);


#print OUTFILE "-------------- OTHERS -------------- \n";
#print OUTFILE "Total number of *miscallaneous proteins* (i.e other non-classified proteins) = *$misc*";
