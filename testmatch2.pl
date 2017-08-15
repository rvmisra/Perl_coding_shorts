#!/usr/local/bin/perl
#testmatch2.pl
#Author: Raju Misra

use warnings;
use strict;

#file to read, which contains the string to search against
print "Enter the name of the file which has the strings to search for:\n";
my $fileToRead_first = <STDIN>;
chomp($fileToRead_first);
open (PROTEINFILE, $fileToRead_first) or die( "Cannot open file : $!" );


$/ = ">";


#Read each FASTA entry and add the sequence titles to @arrayOfNames and the sequences
#to @arrayOfSequences.
my @arrayOfNames = ();
my @arrayOfSequences = ();
while (my $sequenceEntry = <PROTEINFILE>) {
    if ($sequenceEntry eq ">"){
next;
    }
    my $sequenceTitle = "";
    if ($sequenceEntry =~ m/([^\n]+)/){
	$sequenceTitle = $1;
    }
    else {
	$sequenceTitle = "No title was found!";
    }
    $sequenceEntry =~ s/[^\n]+//;
    push (@arrayOfNames, $sequenceTitle);
    $sequenceEntry =~ s/[^ACDEFGHIKLMNPQRSTVWY]//ig;
    push (@arrayOfSequences, $sequenceEntry);




#opns the output file
open(OUTFILE, ">match_results1.txt");

foreach (@arrayOfNames) {
        
 print OUTFILE "@arrayOfNames\n";
}



}
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Open match_results1.txt.\n";