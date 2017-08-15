#!/usr/local/bin/perl -w
# Takes a fasta format file and 
# reverses the sequence but keeps name and description intact
# Nirav@arl.arizona.edu March 04 2003
# Usage: reverse.pl in_file rev_file

my $in_seq = shift or die "ERROR: Need file name to reverse";
my $out_seq = shift or die "ERROR: Need file name to save reversed seq";
if (! -e $in_seq) {die "\nCannot find file: $in_seq\n\n";}
use Bio::SeqIO;
my $count = 0;
$in = Bio::SeqIO->new(-file => "$in_seq", -format => "Fasta");
$out = Bio::SeqIO->new(-file => ">$out_seq", -format => "Fasta");

while ( my $seq = $in->next_seq()) {
		my $the_seq = $seq->seq();
		my $rev_seq = reverse($the_seq);
		$seq->seq($rev_seq);
		
		$out->write_seq($seq);
		$count++;
				}
print "\nReversed $count sequences from:\n\t$in_seq\nsaved to:\n\t$out_seq\n\n";
