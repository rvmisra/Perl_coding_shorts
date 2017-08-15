#!/usr/local/bin/perl
#Author: Raju Misra

use warnings;
use strict;

my $geneID = '';
my $GI = '';

#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

my @arrayOfgeneids = ();
my @arrayOfgi = ();

while (my $sequenceEntry = <INFILE>) {

	if ($sequenceEntry =~ m/db_xref=£GeneID:/) {
    $sequenceEntry=~ s/db_xref=£GeneID:\s*//g;  	
	$geneID = $sequenceEntry;
}	
push (@arrayOfgeneids, $geneID);

if ($sequenceEntry =~ m/db_xref=£GI:/) {
    $sequenceEntry=~ s/db_xref=£GI:\s*//g;  	
	$GI = $sequenceEntry;
}	

push (@arrayOfgi, $GI);
}
    close (INFILE) or die( "Cannot close file : $!");     

######################################## prints ######################################################

open(OUTFILE, ">prots_2.txt");

#goes through each entry submitted and gets results
for (my $i = 0; $i < scalar(@arrayOfgeneids); $i = $i + 1) {  
print OUTFILE ("Results for : $arrayOfgeneids[$i]\n");
}
for (my $j = 0; $j < scalar(@arrayOfgi); $j = $j + 1) {
print OUTFILE ("Results for: $arrayOfgi[$j]\n");

}
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     

print "Open prots_2.txt.txt\n";