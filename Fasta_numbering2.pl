#!/usr/bin/perl
#Author: Raju Misra
#This script adds a number to a fasta header, incrementing by 1 for each fasta sequence.
#This is to create a unique identifier for the fasta headers
#e.g. >1_Acession
#	   SEQUENCE1
#     >2_Acession
#	   SEQUENCE2
#	etc...

use warnings;
use strict;

my $count = 1;
my $fastahead = '';

#Prompt the user for the name of the file to read.
open MYFILE, '<', 'VirusDB.fasta' or die "Cannot open file.txt: $!";


	while (my $sequenceEntry = <MYFILE>) {
		$sequenceEntry =~ s/>/">".$count++."_"/e;
		
		print $sequenceEntry;												  
									     }
		
close MYFILE;