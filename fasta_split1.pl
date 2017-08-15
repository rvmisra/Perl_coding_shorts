#!/usr/bin/perl
 
use strict ;
use warnings;
use BeginperlBioinfo;

my @file_data=();
my $dna= '';

@file_data=get_file_data("BC_atcc14759.fasta");

$dna=extract_sequence_from_fasta_data(@file_data);

print_sequence($dna, 500);

exit;