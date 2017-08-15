#!/usr/local/bin/perl -w
# Simple script for adding a string to a comment
# or description section of sequence
# EXpects a file in fasta format
# Nirav@arl.arizona.edu April 14 2004
use strict;
use Getopt::Long;
my ($in_file,$out_file,$comment);
my $usage = "$0 -i input_file -o output_file -c comment\nNote: Use FASTA files\n";
         GetOptions ('i=s' => \$in_file, 'o=s' => \$out_file , 'c:s'=> \$comment);
##################################################
# No modification needed beyond this point
##################################################
if(!$in_file or !$out_file or !$comment) { die $usage;}
if (! -e $in_file) {die "\nCannot find file: $in_file\n\n";}

use Bio::SeqIO;

my $in = Bio::SeqIO->new(-file => "$in_file", -format => "Fasta");
my $out = Bio::SeqIO->new(-file => ">$out_file", -format => "Fasta");
my $count = 0;

while ( my $seq = $in->next_seq()) {
	my $desc = $seq->desc();
        my $new_desc = "$comment ".$desc;
        $seq->desc($new_desc);
        $out->write_seq($seq); 
$count++;

                                }

print "\nInserted $comment into  $count sequences in\nFile: $in_file\n\n";
