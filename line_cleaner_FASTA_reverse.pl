#!/usr/local/bin/perl
#line_cleaner1.pl
#Author: Raju Misra
#This script reverses a string - fasta sequence, keeps and prints fasta header.
#Lines 35 and 36, reverse and complements respectively.  To get rid of complement hash out line 35.
#NOTE: Put a new line after the last sequence!!!!!!!!!!!!! other wise the last fasta sequence doesn't look right

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

while (my $sequenceEntry = <PROTEINFILE>) {

#This pulls out the fasta header using substr, and then offsets by 1, so pulls out text after the '>'
if ($sequenceEntry=~/^>/g){
			$fastaheader = substr ($sequenceEntry,1);

chomp ($fastaheader);
			print OUTFILE(">"."$fastaheader");
						  }	
			
elsif ($sequenceEntry!~ />/g){	

$reversed = reverse $sequenceEntry;

$reversed =~ tr/[A,T,G,C,a,t,g,c]/[T,A,C,G,t,a,c,g]/;

chomp ($reversed);
			print OUTFILE("$reversed\n");
							  }		
						
											}
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
#print "Output in the file: Line_cleanup_prots4\n";
