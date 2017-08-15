#!/usr/local/bin/perl
#line_cleaner1.pl
#Author: Raju Misra
#This script reverses a string - fasta sequence, keeps and prints fasta header.
#Lines 34 and 35, reverse and complements respectively.  To get rid of complement hash out line 35.

use warnings;
use strict;

my $reversed = 0;
my $fastaheader = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file Darren and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


open(OUTFILE, ">Line_cleanup_prots4.txt");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {

#if ($sequenceEntry !~ m/^>/g) 

if ($sequenceEntry=~/^>/g){
			$fastaheader = substr ($sequenceEntry,1);
						  }
						  	
			
elsif ($sequenceEntry!~ />/g){	
$reversed = reverse $sequenceEntry;
$reversed =~ tr/[A,T,G,C,a,t,g,c]/[T,A,C,G,t,a,c,g]/;
							  }		
											
		
		print (">"."$fastaheader");
		print ("$reversed\n");
}
                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: Line_cleanup_prots4\n";
