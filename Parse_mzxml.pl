#!/usr/bin/perl
#Parses Mascot dat files, not that it does NOT remove redundancies.
#Output is a list of peptide sequences greater than the score listed, default = 20
	
use warnings;
use strict;


#Prompt the user for the name of the file to read.
open MYFILE, '<', 'FILE.xml' or die "Cannot open file.txt: $!";


	while (my $infile = <MYFILE>) {
		
 if($infile=~/precursorCharge\.*/g){
             
print "$infile\n";												  
	
			
    }
   }
close MYFILE;