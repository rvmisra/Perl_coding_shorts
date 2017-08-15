#!/usr/local/bin/perl

#Author: Raju Misra

use warnings;
use strict;




#Prompt the user for the name of the file to read.
open MYFILE, '<', 'all_snp_differences_tab.txt' or die "Cannot open file.txt: $!";
while ( <MYFILE> ) {
	
my ($BA1, $BA2, $BA3, $BA4, $BC1, $BC2, $BC3, $BC4, $BC5, $BC6, $BC7, $BC8, $BC9, $BC10, $BT1, $BT2, $BW1) = split(/\t/);

######### BC markers conserved and unique to all strains #############
#if ($BC1 eq $BC2 && $BC1 eq $BC3 && $BC1 eq $BC4 && $BC1 eq $BC5 && $BC1 eq $BC6 && $BC1 eq $BC7 && $BC1 eq $BC8 && $BC1 eq $BC9 && $BC1 eq $BC10 && $BC1 ne $BA2 && $BC1 ne $BA3 && $BC1 ne $BA4 && $BC1 ne $BT1 && $BC1 ne $BT2 && $BC1 ne $BW1)

######### BT markers #############
if ($BC1 eq $BC2 && $BC1 eq $BC3 && $BC1 eq $BC4 && $BC1 eq $BC5 && $BC1 eq $BC6 && $BC1 eq $BC7 && $BC1 eq $BC8 && $BC1 eq $BC9 && $BC1 eq $BC10 && $BT1 ne $BA2 && $BT1 ne $BA3 && $BT1 ne $BA4 && $BT1 eq $BT2 && $BT1 ne $BW1 && $BT1 ne $BC1)




#if ($BC1 eq $BC2 && $BC1 ne $BT1) 
{
#print ($BA1 ."\t" . $BC1 . "\n");
print ($BA1 ."\t" .$BA2 ."\t" .$BA3 ."\t" .$BA4 ."\t" .$BC1 ."\t" .$BC2 ."\t" .$BC3 ."\t" .$BC4 ."\t" .$BC5 ."\t" .$BC6 ."\t" .$BC7 ."\t" .$BC8 ."\t" .$BC9 ."\t" .$BC10 ."\t" .$BT1 ."\t" .$BT2 ."\t" .$BW1);

}
}
close (MYFILE) or die( "Cannot close file : $!");
                      