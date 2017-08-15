#!/usr/local/bin/perl
#SQL_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $A = 0;
my $B = 0;
my $C = 0;
my $D = 0;
my $E = 0;
my $F = 0;
my $G = 0;
my $H = 0;
my $I = 0;
my $J = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">SQL_insert.txt");

while (my $line = <PROTEINFILE>) {

chomp $line;

	
($A,$B,$C,$D,$E,$F,$G,$H,$I) = split /\t/, $line;

#var_for_sql_script
#print OUTFILE "UPDATE genus_markers SET g_marker = 'N' WHERE pri_id = '$pri_id';\n";
print OUTFILE "INSERT INTO taxa_peptide_sequence_join (tax_id, seq_id) VALUES ('$B','$C');\n";


}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     