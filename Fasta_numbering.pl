#!/usr/bin/perl
#This script goes through a fasta file which is split at every 500 bases by a new line.
#This script inserts a fasta header, where the sequence number increases by one
#for every sequence in the file.
#e.g. >167_ATCC14759
#	  Sequence1
#	  >168_ATCC14759
#     Sequence2
	
use warnings;
use strict;

my $count = 1;
my $fastahead = '';

#Prompt the user for the name of the file to read.
open MYFILE, '<', 'L522_contigs_raw.fasta' or die "Cannot open file.txt: $!";


	while (my $sequenceEntry = <MYFILE>) {
		
		#$sequenceEntry =~ s/\n/\n\n/g;
		$fastahead =  ">" . $count++ . "contig";
	 	$sequenceEntry =~ s/>no_description_available/\n$fastahead/g;
		
		print $sequenceEntry;												  
									     }
		
close MYFILE;