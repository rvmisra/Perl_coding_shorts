#!/usr/local/bin/perl
#SQL_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $Pri_id = 0;
my $Line_id = 0;
my $Scanfile = 0;
my $Peptide_seq = 0;
my $MH = 0;
my $DeltaM = 0;
my $z = 0;
my $XC = 0;
my $DeltaCn = 0;
my $Mwsp = 0;
my $Acc_rsp = 0;
my $Pep_hit = 0;
my $Count = 0;


my $format_seq_id = 0;
my $sequence = 0;
my $pri_id = 0;


my $out1 = 0;
my $out2 = 0;
my $string = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">fasta_prep_2.txt");

while (my $line = <PROTEINFILE>) {

chomp $line;

	
($format_seq_id, $sequence, $pri_id) = split /\t/, $line;

#var_for_sql_script
print OUTFILE "INSERT INTO markers VALUES('$format_seq_id', '$sequence', '$pri_id');\n";

#my $out1 = ">";
#my $out2 = "£";
#my $string = $out1 . $Line_id . $out2 . $Peptide_seq;

#print OUTFILE "$string\n";



}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: fasta_prep_2.txt\n";