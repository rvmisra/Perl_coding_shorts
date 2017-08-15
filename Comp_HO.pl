#!/usr/bin/perl -w
#Author Raju Misra
#MS_db_Substring.pl
#This program tidies up files, from NCBI, into a format mascot likes.  Removing
#non-alphanumeric characters and spaces (replacing them with '_').  It splits the a tab
#delimited file, usualy 3 columns: acc, desc and seq.  The description is trimmed to 
#the first 200 characters only.  As mascot has kicked up errors where the description header
#is too long.


#Open file, containing loci information -> 2 columns>> Start : End 
open MYFILE, '<', 'Spore_pepstab_length_vs_NCBI_nr_Feb_db_top200_PARSED2_TAB.TXT' or die "Cannot open file.txt: $!";

#while the file is open do something
while ( <MYFILE> ) {

#split the tab file in to columns
my ($A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K, $L) = split(/\t/);

if($B = $E){

	

print $A . "\t" . $B . "\t" . $C . "\t" . $D . "\t" . $E;
}
}

	
close MYFILE;
