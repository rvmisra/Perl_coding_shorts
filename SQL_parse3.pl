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


my $pri_id_y = 0;
my $line_id_y = 0;
my $scanfile_y = 0;
my $reference_y = 0;
my $mh_y = 0;
my $deltam_y = 0;
my $z_y = 0;
my $type_y = 0;
my $peptide_seq_y = 0;
my $ppep_y = 0;
my $sf_y = 0;
my $xc_y = 0;
my $deltacn_y = 0;
my $sp_y = 0;
my $rsp_y = 0;
my $ions_y = 0;
my $count_y = 0;
my $accession_y = 0;


my $id = 0;
my $sequence = 0;
my $pri_id = 0;
my $comments = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">fasta_prep.txt");

while (my $line = <PROTEINFILE>) {

chomp $line;

	
($scanfile_y,$peptide_seq_y,$pri_id_y) = split /\t/, $line;

#var_for_sql_script
print OUTFILE "UPDATE formated_seqs_y SET sequence_y  = '$peptide_seq_y' WHERE pri_id_y = '$pri_id_y';\n";
#print OUTFILE "INSERT INTO bioworks_y (pri_id_y,line_id_y, scanfile_y, reference_y, mh_y, deltam_y, z_y, type_y, peptide_seq_y, ppep_y, sf_y, xc_y, deltacn_y, sp_y, rsp_y, ions_y, count_y, accession_y) VALUES ('$pri_id_y','$line_id_y','$scanfile_y','$reference_y','$mh_y','$deltam_y','$z_y','$type_y','$peptide_seq_y','$ppep_y','$sf_y','$xc_y','$deltacn_y','$sp_y','$rsp_y','$ions_y','$count_y','$accession_y');\n";


}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: fasta_prep.txt\n";