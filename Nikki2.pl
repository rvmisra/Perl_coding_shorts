#!/usr/local/bin/perl

#Author: Raju Misra

use warnings;
use strict;

#Prompt the user for the name of the file to read.
open MYFILE, '<', 'emPA_workings.txt' or die "Cannot open file.txt: $!";
while ( <MYFILE> ) {
chomp;	
my ($A, $B, $C, $D, $E, $F) = split(/\t/);

my %rep1 = ($A => '$B');
my %rep2 = ($C => '$D');
my %rep3 = ($E => '$F');

#

#if (($rep1{$A} eq $rep2{$C}) && ($rep1{$A} eq $rep3{$E}))

foreach (keys %rep2)
{	
if (exists $rep1{$_}) {
		
#if ($A eq $C)

#if (($A =~ m/$C/) && ($A =~ m/$E/))

print "$_ exists";
#print ($A . "\t" . $B . "\t" . $C . "\t" . $D . "\t" . $E . "\t" . $F . "\n");

}
}
}
close (MYFILE) or die( "Cannot close file : $!");