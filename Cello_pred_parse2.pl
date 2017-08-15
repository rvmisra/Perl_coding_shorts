#!/usr/local/bin/perl
#testparse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $seqID = '';
my $pred = '';


#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

my @arrayOfgeneids = ();
my @arrayOfpred_score = ();


while (my $sequenceEntry = <INFILE>) {

	##########################################################################
$sequenceEntry =~ m/SeqID: /g; 
   # $sequenceEntry=~ s/SeqID: \s*//g;  	
	$seqID = $sequenceEntry;
		


########################################################################
$sequenceEntry =~ m/ Z/g;
	$pred = $sequenceEntry;
}
	
    close (INFILE) or die( "Cannot close file : $!");     

####################### prints ###########################################################
my $all = 0;

open(OUTFILE, ">pred_sub_prots_2.txt");
$all = $seqID . $pred;

print OUTFILE ("$all\n");

close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     

print "Open pred_sub_prots_2.txt\n";