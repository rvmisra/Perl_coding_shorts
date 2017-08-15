#!/usr/local/bin/perl

#Author: Raju Misra

use warnings;
use strict;

#Prompt the user for the name of the file to read.
open MYFILE, '<', 'nikki_test1_in.txt' or die "Cannot open file.txt: $!";
while ( <MYFILE> ) {
chomp;	
my ($A, $B, $C, $D, $E, $F) = split(/\t/);
my @array = (split(/\t/),<MYFILE>);




#@headers = split(/\|/, scalar <DATA>);
######### BT markers #############
if (($A eq $C) && ($A eq $E)) {


#if (($A =~ m/$C/g) && ($A =~ m/$E/g))
#{

#print ($A . "\t" . $B . "\t" . $C . "\t" . $D . "\t" . $E . "\t" . $F . "\n");

print ($A . "\n");

}
}
close (MYFILE) or die( "Cannot close file : $!");
                      