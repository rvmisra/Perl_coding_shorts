#!/usr/local/bin/perl
#word_count.pl
#Author: Raju Misra

use warnings;
use strict;



#intialises the count, for counting the number of hits
my $count = 0;

#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );


while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.

	if ($sequenceEntry =~ m/>/) {

#increments the counter
$count++
}
}
close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print "$count times";

