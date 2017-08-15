#!/usr/local/bin/perl
#convert_fasta_tab.pl
#Author: Raju Misra

use warnings;
use strict;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file Darren and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

#fasta to tab

while (my $sequenceEntry = <PROTEINFILE>) {
if ($sequenceEntry =~ /^>/)
{
$sequenceEntry =~ s/\n/£/g;
}
$sequenceEntry =~ s/\n//g;
$sequenceEntry =~ s/£/\t/g;
$sequenceEntry =~ s/>/\n>/g;


#mascot_DB_clean#########################################################

#split the tab file in to columns
my ($A, $B, $C, $D, $E, $F, $G, $H, $I, $J, $K, $L) = split(/\t/);

#open the genome sequence file, note: raw sequence, fasta header removed

#extract genome sequence, based on the criterea of the loci file e.g. at position (genome pos)755720 extract 
#(product size)333 bases from it.
my $pos=substr($A,0,199);

#print fasta header
print ">" . $pos . "\n";
#print extracted genome sequence
print $B . "\n";
}
	
close (PROTEINFILE) or die( "Cannot close file : $!");
