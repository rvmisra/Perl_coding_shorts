#!/usr/bin/perl -w
#Author Raju Misra
#MS_db_Substring.pl
#This program tidies up files, from NCBI, into a format mascot likes.  Removing
#non-alphanumeric characters and spaces (replacing them with '_').  It splits the a tab
#delimited file, usualy 3 columns: acc, desc and seq.  The description is trimmed to 
#the first 200 characters only.  As mascot has kicked up errors where the description header
#is too long.


#Open file, containing loci information -> 2 columns>> Start : End 
open MYFILE, '<', 'FASTA2TAB_OUT.txt' or die "Cannot open file.txt: $!";

#while the file is open do something
while ( <MYFILE> ) {

#split the tab file in to columns
my ($A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K, $L) = split(/\t/);

$A =~ s/ /_/g;
$A =~ s/-/_/g;
$A =~ s/\"/_/g;
$A =~ s/\;/_/g;
$A =~ s/\:/_/g;
$A =~ s/\./_/g;
$A =~ s/\,/_/g;
$A =~ s/\(/_/g;
$A =~ s/\)/_/g;
#$B =~ s/\[/_/g;
#$A =~ s/\]/_/g;
$A =~ s/____/_/g;
$A =~ s/___/_/g;
$A =~ s/__/_/g;
$A =~ s/>//g;


#open the genome sequence file, note: raw sequence, fasta header removed

#extract genome sequence, based on the criterea of the loci file e.g. at position (genome pos)755720 extract 
#(product size)333 bases from it.
$pos=substr($A,0,199);

#print fasta header
print ">" . $pos . "\n";
#print extracted genome sequence
print $B . "\n";

}

	
close MYFILE;
