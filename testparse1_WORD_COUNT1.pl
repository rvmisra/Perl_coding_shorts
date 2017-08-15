#!/usr/local/bin/perl
#testparse1.pl
#Author: Raju Misra

use warnings;
use strict;

#user input for the word to search for
#print "word to look for: ";
#my $wordtoread = <STDIN>;


#my $word = $wordtoread;
#chomp($word);

#intialises the count, for counting the number of hits
my $count = 0;

#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
#open(OUTFILE, ">parse_results1.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.

	if ($sequenceEntry =~ m/\[/) {

#increments the counter
$count++
}
}
close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print "$word is contained in the file $count times";
#close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
#print "Open parse_results1.txt.\n";