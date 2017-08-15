#!/usr/local/bin/perl
#testparse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $seqID = '';
my $pred = '';
my $a = '';
my $b = '';



#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

my @arrayOfgeneids = ();
my @arrayOfpred_score = ();


while (my $sequenceEntry = <INFILE>) {

	##########################################################################
	if ($sequenceEntry =~ m/SeqID: /) {
    $sequenceEntry=~ s/SeqID: \s*//;  	
	$seqID = $sequenceEntry;
}	
push (@arrayOfgeneids, $seqID);

########################################################################
if ($sequenceEntry =~ m/ Z/) {
    #$sequenceEntry=~ s/db_xref=£GI:\s*//;  	
	$pred = $sequenceEntry;
}	

push (@arrayOfpred_score, $pred);

}
    close (INFILE) or die( "Cannot close file : $!");     

####################### prints ###########################################################

open(OUTFILE, ">pred_sub_prots_1.txt");

#goes through each entry submitted and gets results
for (my $i = 0; $i < scalar(@arrayOfgeneids); $i = $i + 1) {  
print OUTFILE ("Results for : $arrayOfgeneids[$i]:");
}
for (my $j = 0; $j < scalar(@arrayOfpred_score); $j = $j + 1) {
print OUTFILE ("Results for: $arrayOfpred_score[$j]:");
}

print OUTFILE ("-----------------------------------------------------------------------------------------\n");
print OUTFILE ("-----------------------------------------------------------------------------------------");

print OUTFILE ("Results for: $arrayOfgeneids . $arrayOfpred_score");

close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     

print "Open pred_sub_prots_1.txt\n";