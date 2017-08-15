#!/usr/bin/perl

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
my $peptide = '';
my $blastline = '';
my $length = 0;
my @results;
my $result;
my $peptide_letter;
my $mismatches = 0; 
my $gap_openings = 0;
my $e_value = 0; 
my $bit_score = 0;

my %peptides_hash = ();

      	open (PEPTIDES, "Urea3k_training_dat2txt_NR1.fasta") ||  die $!;
      	while ($peptide = <PEPTIDES>) {
		chomp($peptide);
		if ($peptide=~/>/g){
			$peptide_letter = substr ($peptide,1);
		}

		$length = length($peptide);
		$peptides_hash{$peptide_letter} = $length;
		
		print $length . "\t" . $peptide_letter . "\n"; 
	}
	close(PEPTIDES);