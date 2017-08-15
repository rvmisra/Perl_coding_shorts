#!/usr/local/bin/perl
#SQL_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $Pri_id = 0;

my $concat = 0;
my $tag = 0;
my $Seq = 0;
my $count_id = 0;
my $line = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">fasta_prep.txt");





while (my $line = <PROTEINFILE>) {

chomp $line;


($Pri_id, $Seq) = split /\t/, $line;

$count_id=1;

while ($count_id < 550000)
{
$tag = "format_seq_id_";
$concat = $tag . $count_id;

#var_for_sql_script
print OUTFILE "INSERT INTO formated_seqs VALUES('$concat', $Seq', '$Pri_id');\n";
}


}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: fasta_prep.txt\n";