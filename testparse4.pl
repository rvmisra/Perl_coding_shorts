#!/usr/local/bin/perl
#testparse1.pl
#Author: Raju Misra

use warnings;
use strict;

#user input for the word to search for
print "word to lool for: ";
my $wordtoread = <STDIN>;


my $word = $wordtoread;
chomp($word);

#intialises the count, for counting the number of hits
my $count = 0;
#my $time = 0;


#user input for the word to search for
print "Time to calc. for blasting recs.: ";
my $timetocalc = <STDIN>;


my $time = $timetocalc;
chomp($time);




#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">parse_results1.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.

	if ($sequenceEntry =~ m/$word/) {

#increments the counter
$count++
}
}

my $timeTaken_S = $count * $time;
my $timeTaken_min = $timeTaken_S / 60;
my $timeTaken_h = $timeTaken_min / 60;


close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "The string '$word' is contained in the file '$fileToRead', $count times\n\n";
print OUTFILE " This will take $timeTaken_S seconds to analyase\n" ;
print OUTFILE " This will take $timeTaken_min minutes to analyase\n" ;
print OUTFILE " This will take $timeTaken_h hours to analyase\n" ;
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Open parse_results1.txt.\n";