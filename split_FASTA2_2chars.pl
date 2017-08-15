#!/usr/local/bin/perl
#string split.pl
#Author: Raju Misra
#This script using the split command takes multiple strings in a file, splits all the characters up into an array.  
#Then prints the contents of the array to a file.


use warnings;
use strict;

my @chars = ();

#Prompt the user for the name of the file to read.
print "Enter the name of the file and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


open(OUTFILE, ">Line_cleanup_prots4.txt");

while (my $sequenceEntry = <PROTEINFILE>) {

@chars = split (/(....)/, $sequenceEntry);
	
use List::MoreUtils qw/ uniq /;
my @unique = uniq @chars;
foreach ( @unique ) {
    print OUTFILE $_, "\n";
}
}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: Line_cleanup_prots4\n";
