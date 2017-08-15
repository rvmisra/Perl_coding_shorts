#!/usr/local/bin/perl

#Author: Raju Misra

use warnings;
use strict;

#Prompt the user for the name of the file to read.
open MYFILE, '<', 'Min_exc_peps_mass_tab.txt' or die "Cannot open file.txt: $!";
while ( <MYFILE> ) {
	
my ($colA, $colB, $colC, $colD, $colE, $colF, $colG, $colH, $colI, $colJ, $colK, $colL, $colM, $colN) = split(/\t/);

if ($colC eq $colK)

{

print ($colA . "\t" . $colB . "\t" . $colC . "\t" . $colD);
print "\n";

}
}
close (MYFILE) or die( "Cannot close file : $!");
                      