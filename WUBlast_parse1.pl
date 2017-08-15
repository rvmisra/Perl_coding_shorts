#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

my $qid = 0;
my $sid = 0;
my $E = 0;
my $N = 0;
my $Sprime = 0;
my $S = 0;
my $alignlen = 0;
my $nident = 0;
my $npos = 0;
my $nmism = 0;
my $pcident = 0;
my $pcpos = 0;
my $qgaps = 0;
my $qgaplen = 0;
my $sgaps = 0;
my $sgaplen = 0;
my $qframe = 0;
my $qstart = 0;
my $qend = 0;
my $sframe = 0;
my $sstart = 0;
my $send = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">YP_WUblast_parse_OUTPUT2.txt");

while (my $line = <PROTEINFILE>) {

chomp $line;

	
($qid, $sid, $E, $N, $Sprime, $S, $alignlen, $nident, $npos, $nmism, $pcident, $pcpos, $qgaps, $qgaplen, $sgaps, $sgaplen, $qframe, $qstart, $qend, $sframe, $sstart, $send) = split /\t/, $line;


if (($pcident =~ /100/) && ($sid !~ /\_pestis_/)) {

#print OUTFILE "$query£$subject£$percent_id£$alignment_length£$mismatches£$gap_openings£$q_start£$q_end£$e_value£$bit_score\n";
print OUTFILE "$qid£$alignlen\n";

}

}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Output in the file: YP_WUblast_parse_OUTPUT2.txt\n";