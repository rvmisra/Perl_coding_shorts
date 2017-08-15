#!/usr/bin/perl
#remove_duplicate_seq.pl
#Version 1.0
#Reads multiple sequence records in FASTA format from a file and if there are two
#or more sequences that match, only the first record in the matching group is
#written to the output file. The names of the removed records are written
#to a log file.

#There are two command line options:
#-i input file of sequences
#-o output file of non duplicate sequences
#-l log file of removed sequences
#
#example usage:
#perl remove_duplicate_seq.pl -i my_sequences.txt -o my_output.txt -l log.txt
#
#Written by Paul Stothard, Canadian Bioinformatics Help Desk.
#
#stothard@ualberta.ca

use warnings;
use strict;

#Command line processing.
use Getopt::Long;

my $inputFile;
my $outputFile;
my $logFile;

Getopt::Long::Configure ('bundling');
GetOptions ('i|input_file=s' => \$inputFile,
	    'o|output_file=s' => \$outputFile,
	    'l|log_file=s' => \$logFile);

if(!defined($inputFile)) {
    die ("Usage: remove_duplicate_seq.pl -i <input file> -o <output file> -l <log file>\n");
}

if(!defined($outputFile)) {
    die ("Usage: remove_duplicate_seq.pl -i <input file> -o <output file> -l <log file>\n");
}

if(!defined($logFile)) {
    die ("Usage: remove_duplicate_seq.pl -i <input file> -o <output file> -l <log file>\n");
}

#Make counter for sequences.
my $seqIndexOuter = 0;
my $seqIndexInner = 0;
my $skippedSeq = 0;
my @skippedList = ();

open (OUTFILE, ">" . $outputFile) or die ("Cannot open file for output: $!");

open (LOGFILE, ">" . $logFile) or die ("Cannot open file for output: $!");

print (LOGFILE "The following redundant sequences were detected in $inputFile:\n\n");

while(1) {
    #get the first record from the input file
    my $noMatch = 1;
    my $outerRecordHash = _getSequence($seqIndexOuter);
    if ($outerRecordHash->{'endReached'}) {
	last;
    }

    #now go through records again looking for match
    while(1) {
	
	if ($seqIndexOuter == $seqIndexInner) {
	    $seqIndexInner++;
	    next;
	}

	my $innerRecordHash = _getSequence($seqIndexInner);
	if ($innerRecordHash->{'endReached'}) {
	    last;
	}

	#compare the outer and inner records to look for 
	#matching sequence. Use lowercase for the comparison.
	if ((lc($outerRecordHash->{'seq'})) eq (lc($innerRecordHash->{'seq'}))) {
	    #write entry to log file
	    print (LOGFILE "-" . $outerRecordHash->{'seqTitle'} . " has the same sequence as " . $innerRecordHash->{'seqTitle'} . ".\n");
	    $skippedSeq++;
	    $noMatch = 0;
	    push (@skippedList, $seqIndexInner);
	}

	$seqIndexInner++;
    }

    #if no other records identical in sequence, write the record out.
    if ($noMatch) {
	print (OUTFILE ">" . $outerRecordHash->{'seqTitle'} . "\n");
	print (OUTFILE $outerRecordHash->{'seq'} . "\n\n");	
    }
    #else check to see if the record is a member of the indexes to skip.
    else {
	my $inSkippedList = 0;
	foreach (@skippedList) {
	    if ($_ == $seqIndexOuter) {
		$inSkippedList = 1;
	    }
	}

	if (!($inSkippedList)) {
	    print (OUTFILE ">" . $outerRecordHash->{'seqTitle'} . "\n");
	    print (OUTFILE $outerRecordHash->{'seq'} . "\n\n");
	}
	else {
	    print (LOGFILE "-" . $outerRecordHash->{'seqTitle'} . " has been removed from the output file.\n");
	}
    }
    
    $seqIndexOuter++;
    $seqIndexInner = 0;
}

close (LOGFILE) or die( "Cannot close file : $!");

close (OUTFILE) or die( "Cannot close file : $!");


sub _getSequence {

    #0 refers to the first sequence record
    my $seqToGetIndex = shift;
    my $seqIndex = 0;
    my %resultsHash = ('seqTitle' => undef, 'seq' => undef, 'endReached' => 0);

    open (SEQFILE, $inputFile) or die( "Cannot open file : $!" );
    $/ = ">";

    #read each sequence.
    while (my $sequenceEntry = <SEQFILE>) {

	if ($sequenceEntry eq ">"){
	    next;
	}

	my $sequenceTitle = "";
	if ($sequenceEntry =~ m/^([^\n\cM]+)/){
	    $sequenceTitle = $1;
	}
	else {
	    $sequenceTitle = "No title was found!";
	}

	$sequenceEntry =~ s/^[^\n\cM]+//;
	$sequenceEntry =~ s/[^A-Za-z]//g;
    
	if ($seqToGetIndex == $seqIndex) {
	    $resultsHash{'seqTitle'} = $sequenceTitle;
	    $resultsHash{'seq'} = $sequenceEntry;
	    close (SEQFILE) or die( "Cannot close file : $!");
	    return \%resultsHash;
	}
	
	$seqIndex++;
    }    

    $resultsHash{'endReached'} = 1;
    close (SEQFILE) or die( "Cannot close file : $!");
    return \%resultsHash;
}

