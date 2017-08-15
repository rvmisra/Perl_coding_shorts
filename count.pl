#!/usr/local/bin/perl -w
# Simple Sequence counter
# EXpects a file in fasta format
# Nirav@arl.arizona.edu march 04 2004

my $in_seq = shift or die "Need sequence file in fasta format to count sequences";
if (! -e $in_seq) {die "\nCannot find file: $in_seq\n\n";}

use Bio::SeqIO;

my $in = Bio::SeqIO->new(-file => "$in_seq", -format => "Fasta");
my $count = 0;

while ( my $seq = $in->next_seq()) {
		
$count++;		
		
				}
				
print "\nThere are $count sequences in\nFile: $in_seq\n\n";
