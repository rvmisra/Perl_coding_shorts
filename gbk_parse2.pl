#!/usr/local/bin/perl
#gbk_parse.pl
#Author: Raju Misra
#This script parses out locus tag and product lines from a genbank file.
#Can easily be adapted to pull out other strings.

use warnings;
use strict;

my $reversed = 0;
my $fastaheader = 0;
my $locus_tag = 0;
my $product = 0;
my $CDS = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file Darren and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


open(OUTFILE, ">Line_cleanup_prots4.txt");

while (my $sequenceEntry = <PROTEINFILE>) {

#This matches a string and than pulls out everything after it..'\s*' --> CDS
if ($sequenceEntry=~/CDS\s*/g){
			$locus_tag = $sequenceEntry;
			chomp ($locus_tag);
			print OUTFILE ("$locus_tag\t");
					}	
	 
#This matches a string and than pulls out everything after it..'\s*' --> product					
elsif ($sequenceEntry=~/\/product=\s*/g){
		$product = $sequenceEntry;
			chomp ($product);		 					
			print OUTFILE ("$product\n");
									  }	 	
										  }

									  											
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
#print "Output in the file: Line_cleanup_prots4\n";
