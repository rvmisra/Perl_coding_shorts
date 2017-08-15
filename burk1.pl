#!/usr/local/bin/perl

#Author: Raju Misra

use warnings;
use strict;

#Prompt the user for the name of the file to read.
open MYFILE, '<', 'test2.txt' or die "Cannot open file.txt: $!";
while ( <MYFILE> ) {
	
my ($A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K) = split(/,/);


######### BT markers #############
#if ($204B eq $204D && $204B eq $204F && $204B eq $4845H && $204B eq $4845J && $204B eq $4845L && $204B eq $16881N && $204B eq $16881P && $204B eq $16881R && $204B ne $MT && $204B ne $MV && $204B ne $MX)


if ($B eq $D) 
{

print ($A . "\t" . $B . "\n");

}
}
close (MYFILE) or die( "Cannot close file : $!");
                      