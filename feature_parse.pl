#!/usr/bin/perl
#feature_parse.pl
#version 1.0
#feature_parse.pl - Reads a genomic sequence in FASTA or RAW format from a file and writes out
#the features that are described in a feature position file. The extracted features are written
#in FASTA format to the specified output file.
#
#The format of the feature position file should look like the following:
#
#131L1_Gene01	4525	8080	 +
#131L1_Gene02	11886	12878	 +
#131L1_Gene03	15280	15779	 -
#131L1_Gene04	24311	24736	 +
#131L1_Gene05	27902	31290	 +
#
#The columns represent the following: name, start, stop, strand.
#The values in each column must not contain any white space.
#Features on the '-' strand are reverse complemented when returned.
#
#There are three command line options:
#-s <sequence file>
#-f <feature file>
#-o <output file>
#
#Example usage:
#
#perl feature_parse.pl -s input_sequence.txt -f gene_boundaries.txt -o output.txt
#
#Written by Paul Stothard, Canadian Bioinformatics Help Desk.
#stothard@ualberta.ca

use warnings;
use strict;

#Command line processing.
use Getopt::Long;

my $sequenceFile;
my $featureFile;
my $outputFile;

Getopt::Long::Configure ('bundling');
GetOptions ('s|sequence_file=s' => \$sequenceFile,
	    'f|feature_file=s' => \$featureFile,
	    'o|output_file=s' => \$outputFile);

if(!defined($sequenceFile)) {
    die ("Usage: feature_parse.pl -s <sequence file> -f <feature file> -o <output file>\n");
}

if(!defined($featureFile)) {
    die ("Usage: feature_parse.pl -s <sequence file> -f <feature file> -o <output file>\n");
}

if(!defined($outputFile)) {
     die ("Usage: feature_parse.pl -s <sequence file> -f <feature file> -o <output file>\n");
}

#Now open the file specified by $sequenceFile
open (SEQUENCE_FILE, $sequenceFile) or die( "Cannot open file for input: $!" );
$/ = undef;
my $sequence = <SEQUENCE_FILE>;
$/ = "\n";
close(SEQUENCE_FILE) or die ("Cannot close file for input: $!");

my $sequenceTitle;

#Match the sequence title portion of the sequence record. A sequence record looks like this:
#>my sequence title
#gattatatatatatttac
if ($sequence =~ m/^>([^\n\cM]+)/){
    $sequenceTitle = $1;
    $sequence =~ s/^>[^\n\cM]+//;
}
else {
    $sequenceTitle = "No_title_was_found";
}
$sequence =~ s/[^gatcryswkmbdhvn]//ig;
my $sequenceLength = length($sequence);


#now read feature information
open (FEATURE_FILE, $featureFile) or die( "Cannot open file for input: $!" );

while (my $entry = <FEATURE_FILE>) {

    my $title = undef;
    my $start = undef;
    my $end = undef;
    my $isForward = undef;

    #131L1_Gene01	4525	8080	 +
    if ($entry =~ m/(\S+)[\s\t]+(\d+)[\s\t]+(\d+)[\s\t]+([\+\-])/) {
	$title = $1;
	$start = $2;
	$end = $3;
	my $strand = $4;
	if ($strand eq '+') {
	    $isForward = 1;
	}
	else {
	    $isForward = 0;
	}
    }
    else {
	next;
    }

    if ($start > $end) {
	die ("The start value $start is larger than the end value $end");
    }
    if ($start > $sequenceLength) {
	die ("The start value $start is larger than the sequence length $sequenceLength");
    }
    if ($end > $sequenceLength) {
	die ("The end value $end is larger than the sequence length $sequenceLength");
    }

    my $sequenceEntry = substr( $sequence, $start - 1, $end - $start + 1);

    if (!($isForward)) {
	#Do reverse complement
	#complement the sequence
	$sequenceEntry =~ tr/gatcryswkmbdhvnGATCRYSWKMBDHVN/ctagyrswmkvhdbnCTAGYRSWMKVHDBN/;

	#reverse the sequence
	$sequenceEntry = reverse($sequenceEntry);  

    }

    #Write header information to the file specified by $outputFile.
    open(OUTFILE, "+>>" . $outputFile) or die ("Cannot open file for output: $!");
    print(OUTFILE ">" . $title . "\n" . $sequenceEntry . "\n");
    close(OUTFILE) or die ("Cannot close file for output: $!");
}


