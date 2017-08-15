#!/usr/local/bin/perl -w
# Simple Sequence extractor from a file containing fasta seq.
# Expects a input file containing fasta format sequences and a text file with
# sequence names one per line with 
# comma separated optional start and stop values
# see example below
# seq_a
# seq_b,9,15
# seq_c
# seq_d,1,200
# Nirav@arl.arizona.edu Ver 1.0 03/31/2005
use strict;
use Getopt::Long;
my ($in_file,$out_file,$list);
my $usage = "\n$0 -i fasta_file -o output_file -l list\n
# Simple Sequence extractor from a file containing fasta seq.
# Expects a input file containing fasta format sequences and a text file with
# sequence names one per line with 
# comma separated optional start and stop values
# see example below
# seq_a
# seq_b,9,15
# seq_c
# seq_d,1,200 \n";
         GetOptions ('i=s' => \$in_file, 'o=s' => \$out_file , 'l:s'=> \$list);
##################################################
# No modification needed beyond this point
##################################################
if(!$in_file or !$out_file or !$list) { die $usage;}
if (! -e $in_file) {die "\nCannot find file: $in_file\n\n";}
if (! -e $list) {die "\nCannot find file: $list\n\n";}
use Bio::SeqIO;

my $in = Bio::SeqIO->new(-file => "$in_file", -format => "Fasta");
my $out = Bio::SeqIO->new(-file => ">$out_file", -format => "Fasta");
my $count = 0;
my $count_write = 0;
my %seq_name = ();
my %seq_start =();
my %seq_stop = ();
#slurp the list in and build a hash
open(LIST, "$list") or die "Cannot open list files $list\n";
while(<LIST>) {
chomp($_);
my ($getseq_name,$start,$stop) = split(/,/,$_);
# Doing sone Uppercase stuff so seqnames match
# removing > in case some lazy bum copies fasta names
# with >
$getseq_name = uc($getseq_name);
$getseq_name =~ s/^>//;

if($start and $stop) {
	$seq_name{$getseq_name} = "$start,$stop";
			} else {
			$seq_name{$getseq_name} = ",";
			}
}
while ( my $seq = $in->next_seq()) {
	my $desc = $seq->desc();
	my $name = $seq->display_id;
	$name = uc($name);
       if($seq_name{$name}){
# If no sub seq then on , will be there so dump full seq     
       if($seq_name{$name} eq ",") {
        $out->write_seq($seq); 
	} else {
	my $sub_seq = $seq->subseq(eval($seq_name{$name}));
	# print "$sub_seq\n";
	$seq->desc($seq->desc()." bases $seq_name{$name} only");
	$seq->seq($sub_seq);
	$out->write_seq($seq);
	} 
	$count_write++;
	}
$count++;

                                }

print "\nExtracted $count_write sequences to file: $out_file\nFrom input fasta file $in_file that contained $count sequences\n\n";
