#!/usr/bin/perl
#blast_client.pl
#Version 3.2
#
#This script performs BLAST searches against NCBI's nr database. It
#prompts the user for a blast search type and an input file of FASTA
#formatted sequences. An optional 'limit by entrez query' value can be
#supplied to restrict the search. The script then submits each
#sequence to BLAST and retrieves the results. For each of the hits the
#script retrieves a detailed title by performing a separate query of
#NCBI's databases. Each BLAST hit and its descriptive title are
#written to a single tab-delimited output file.
#
#To run, make sure Perl is installed on your system, and enter:
#perl blast_client.pl
#
#Written by Paul Stothard, Genome Canada Bioinformatics Help Desk.

use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Request::Common;

my $BLAST_URL = "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi";
my $ENTREZ_URL = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?";

my %settings = (ENTREZ_QUERY => undef,
		PROGRAM => undef,
		DATABASE => undef,
		EXPECT => undef,
		WORD_SIZE => undef,
		HITLIST_SIZE => "20",
		FILTER => "L",
		OUTPUTFILE => undef,
		INPUTFILE => undef,
		INPUTTYPE => undef,
		ENTREZ_DB => undef);

my @settingsKeys = keys(%settings);

#Prompt the user for the type of blast search being performed.
print "------------------------------------------------------------\n";
print "Please enter a number to indicated the type of blast search\n";
print "you want to perform:.\n";
print "1 - Nucleotide-nucleotide BLAST (blastn).\n";
print "2 - Protein-protein BLAST (blastp).\n";
print "3 - Translated query vs protein database (blastx).\n";
print "4 - Protein query vs translated database (tblastn).\n";
print "5 - Translated query vs. translated database (tblastx).\n";
print "------------------------------------------------------------\n";
my $blastType = <STDIN>;
chomp($blastType);
if ($blastType =~ m/(\d)/) {
    $blastType = $1;
}
else {
    die ("Please enter a digit between 1 and 5.\n");
}
if (($blastType < 1) || ($blastType > 5)) {
    die ("Please enter a digit between 1 and 5.\n");
}
print "------------------------------------------------------------\n";
print "Enter an entrez query or press enter to search all sequences.\n";
print "For example, the term 'bacteria[Organism]' restricts the\n";
print "search to bacteria sequences only.\n";
print "------------------------------------------------------------\n";
$settings{ENTREZ_QUERY} = <STDIN>;
chomp($settings{ENTREZ_QUERY});

_setDefaults($blastType, \%settings);

print "------------------------------------------------------------\n";
print "Enter the name of the FASTA format " . $settings{INPUTTYPE} . " sequence file\n";
print "that contains your query sequences.\n";
print "------------------------------------------------------------\n";
$settings{INPUTFILE} = <STDIN>;
chomp($settings{INPUTFILE});
open (SEQFILE, $settings{INPUTFILE}) or die( "Cannot open file : $!" );

my $inputLessExtentions = $settings{INPUTFILE};
if ($settings{INPUTFILE} =~ m/(^[^\.]+)/g) {
    $inputLessExtentions = $1;
}

$settings{OUTPUTFILE} = $inputLessExtentions . "_" . $settings{OUTPUTFILE};

print "------------------------------------------------------------\n";
print "The results of this " . $settings{PROGRAM} . " search will be written to\n";
print "a file called " . $settings{OUTPUTFILE} . ".\n";
print "Start the search? (y or n)\n";
print "------------------------------------------------------------\n";
my $continue = <STDIN>;
chomp($continue);
unless ($continue =~ m/y/i) {
    exit(0);
}

#make sure output file does not already exist
if (-e $settings{OUTPUTFILE}) {
    die ("The file " . $settings{OUTPUTFILE} . " already exists. Please rename it or move it to another location.\n");
}

#Open file for recording results.
open(OUTFILE, "+>>" . $settings{OUTPUTFILE}) or die ("Cannot open file : $!");
print(OUTFILE "#-------------------------------------------------------------------------------------------------------------------------------------------------\n");
print(OUTFILE "#Results of automated BLAST query of performed on " . _getTime() . ".\n");
print(OUTFILE "#The following settings were specified:\n");
foreach(@settingsKeys) {
    print(OUTFILE "#" . $_ . "=" . $settings{$_} . "\n");   
}
print(OUTFILE "#The following attributes are separated by tabs:\n");
print(OUTFILE "#query_id, match_id, match_description, %_identity, alignment_length, mismatches, gap_openings, q_start, q_end, s_start, s_end, e-value, bit_score\n");
print(OUTFILE "#-------------------------------------------------------------------------------------------------------------------------------------------------\n");
close(OUTFILE) or die ("Cannot close file : $!");

#Create UserAgent object.
my $browser = LWP::UserAgent->new();

$browser->proxy('http', 'http://158.119.60.205:8080/');

$browser->timeout(30);

#Make counter for sequences.
my $seqCount = 1;

$/ = ">";
#BLAST each sequence.
while (my $sequenceEntry = <SEQFILE>) {
    open(OUTFILE, "+>>" . $settings{OUTPUTFILE}) or die ("Cannot open file : $!");
    if ($sequenceEntry eq ">"){
	next;
    }
    my $sequenceTitle = "";
    if ($sequenceEntry =~ m/^([^\n\cM]+)/){
	$sequenceTitle = $1;
    }
    else {
	$sequenceTitle = "No title available";
    }
    $sequenceEntry =~ s/^[^\n\cM]+//;
    $sequenceEntry =~ s/[^A-Z]//ig;
    if (!($sequenceEntry =~ m/[A-Z]/i)) {
	next;
    }
    my $query = ">" . $sequenceTitle . "\n" . $sequenceEntry;
    #Get BLAST RID
    print "Sending RID request for sequence " . $sequenceTitle . ".\n";
    my $response = $browser->request(POST ($BLAST_URL, [DATABASE => $settings{DATABASE}, HITLIST_SIZE => $settings{HITLIST_SIZE}, EXPECT => $settings{EXPECT}, WORD_SIZE => $settings{WORD_SIZE}, FILTER => $settings{FILTER}, PROGRAM => $settings{PROGRAM}, QUERY => $query, CMD => "Put"]));
    if ($response->is_success()) {
	my $result = $response->as_string();
	if ($result =~ m/QBlastInfoBegin\s*RID\s=\s([^\s]+)\s*RTOE\s=\s(\d+)\s*QBlastInfoEnd/) {
	    print "A RID was received for sequence " . $sequenceTitle . " and an RTOE of $2.\n";
	    my $RID = $1;
	    my $RTOE = $2;
	    
	    #Do rest of BLAST.
	    #First sleep for RTOE.
	    print "Sleeping for $RTOE seconds.\n";
	    sleep($RTOE);

	    my $resultFound = 0;

	    while ($resultFound == 0) {
		print "Requesting results for sequence " . $sequenceTitle . ".\n";
		my $response = $browser->request(POST ($BLAST_URL, [RID => $RID, FORMAT_TYPE => "Text", ALIGNMENT_VIEW => "Tabular", CMD => "Get"]));
		if ($response->is_success()) {
		    my $result = $response->as_string();
		    if ($result =~ m/<td>status<\/td><td>searching<\/td>/i) {
			print "The results are not ready for sequence " . $sequenceTitle . ".\n";
			print "Pausing before requesting again.\n";
			sleep(10);
		    }
		    elsif ($result =~ m/QBlastInfoBegin\s*Status=WAITING\s*QBlastInfoEnd/) {
			print "The results are not ready for sequence " . $sequenceTitle . ".\n";
			print "Pausing before requesting again.\n";
			sleep(10);
		    }
		    elsif ($result =~ m/QBlastInfoBegin\s*Status=READY\s*QBlastInfoEnd/) {
			print "The results were received for sequence " . ($sequenceTitle) . ".\n";
			print "Writing the results to blast_results.txt\n";

			#Tabular format returns each hit as a space separated sequence of 12 values.
			my $hitFound = 0;
			while ($result =~ m/^(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]*$/gm) {

			    my $col1 = $1;
			    my $col2 = $2;
			    my $col3 = $3;			    
			    my $col4 = $4;
			    my $col5 = $5;
			    my $col6 = $6;
			    my $col7 = $7;
			    my $col8 = $8;
			    my $col9 = $9;
			    my $col10 = $10;
			    my $col11 = $11;
			    my $col12 = $12;

			    #this is to return a single gi number in $col2
			    if ($col2 =~ m/(gi\|\d+)/) {
				$col2 = $1;
			    }

			    #obtain description from NCBI

			    my $accessionEntry = $col2;
			    my $desc = "";
			    my $uid = "";
			    if ($accessionEntry =~ m/gi\|(\d+)/) {  
				print "Requesting sequence description.\n";
				sleep(1);
				$uid = $1;
				my $responseDesc = $browser->request(POST ($ENTREZ_URL . "cmd=text&db=" . $settings{ENTREZ_DB} . "&uid=$uid&dopt=DocSum"));
				if ($responseDesc->is_success()) {
				    my $resultDesc = $responseDesc->as_string();
				    if ($resultDesc =~ m/(<pre>[\s\S]+<\/pre>)/i) {
					$resultDesc = $1;
				    }
				    else {
					die ("The response received was not understood.\n");
				    }

				    #Process the result.
				    $resultDesc =~ s/<pre>\s*|\s*<\/pre>//gi;
				    $resultDesc =~ s/[^\n]+\n//;
				    $resultDesc =~ s/[^\n]+$//;

				    $resultDesc =~ s/\n/ /;
				    $resultDesc =~ s/\cM//;
				    $resultDesc =~ s/[\f\n\r]//;

				    $resultDesc =~ s/\s+$//g;

				    $desc = $resultDesc;
				    print "Sequence description obtained.\n";
				}
				else {
				    $desc = "Could not obtain description for $accessionEntry.";
				}
			    }
			    else {
				$desc = "Could not parse gi number";
			    }			    

			    print (OUTFILE $col1 . "\t" . $col2 . "\t" . $desc . "\t" . "\t" . $col3 . "\t" . $col4 . "\t" . $col5 . "\t" . $col6 . "\t" . $col7 . "\t" . $col8 . "\t" . $col9 . "\t" . $col10 . "\t" . $col11 . "\t" . $col12 . "\n");


	
			    $hitFound = 1;

			}

			if (!($hitFound)) {
			    print (OUTFILE "#no hits were returned for $sequenceTitle.\n");
			}

			$resultFound = 1;
	
		    }
		    else {
			print "Error4: The response received when requesting results for sequence " . $sequenceTitle . " was not understood.\n";
		        print(OUTFILE "#Error4: The response received when requesting results for sequence " . $sequenceTitle . " was not understood.\n");
			$resultFound = 1;
		    }
		}
		else {
		    print "Error1: Response not success when requesting results for sequence " . $sequenceTitle . ".\n";
		    print(OUTFILE "#Error1: Response not success when requesting results for sequence " . $sequenceTitle . ".\n");
		    $resultFound = 1;
		}
	    } #end of while loop for submitting RID.
	}
	else {
	    print "Error2: The response received when requesting RID for sequence " . $sequenceTitle . " was not understood.\n";
	    print (OUTFILE "#Error2: The response received when requesting RID for sequence " . $sequenceTitle . " was not understood.\n");
	}
    }
    else {
	print "Error3: Response not success when requesting RID for sequence " . $sequenceTitle . ".\n";
	print (OUTFILE "#Error3: Response not success when requesting RID for sequence " . $sequenceTitle . ".\n");
    }

    #If sequences are submitted very rapidly to the BLAST server, NCBI may block the submitting
    #site. The "sleep" statement stops execution for the specified number of seconds. After the
    #pause, the next sequence is submitted.
    print "Pausing after submission.\n";
    sleep(1);
    close(OUTFILE) or die ("Cannot close file : $!");
    $seqCount = $seqCount + 1;
}#end of sequence submission while loop
$/ = "\n";
close (SEQFILE) or die( "Cannot close file : $!");

print "Open " . $settings{OUTPUTFILE} . " to view the results.\n";


sub _getTime {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;

    my @days = ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
    my @months = ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
    my $time = $days[$wday] . " " . $months[$mon] . " " . sprintf("%02d", $mday) . " " . sprintf("%02d", $hour) . ":" . sprintf("%02d", $min) . ":" . sprintf("%02d", $sec) . " " . sprintf("%04d", $year);  
    return $time;
}

sub _setDefaults {
    my $blastType = shift;
    my $settingsHash = shift;

    #1 - Nucleotide-nucleotide BLAST (blastn)
    if ($blastType == 1) {
	$settingsHash->{PROGRAM} = "blastn";
	$settingsHash->{DATABASE} = "nr";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "11";
	$settingsHash->{OUTPUTFILE} = "blastn_results.txt";
	$settingsHash->{INPUTTYPE} = "DNA";
	$settingsHash->{ENTREZ_DB} = "Nucleotide";	
    }
    
    #2 - Protein-protein BLAST (blastp)
    elsif ($blastType == 2) {
	$settingsHash->{PROGRAM} = "blastp";
	$settingsHash->{DATABASE} = "nr";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "2";
	$settingsHash->{OUTPUTFILE} = "blastp_results.txt";
	$settingsHash->{INPUTTYPE} = "protein";
	$settingsHash->{ENTREZ_DB} = "Protein";
    }
    
    #3 - Translated query vs protein database (blastx)
    elsif ($blastType == 3) {
	$settingsHash->{PROGRAM} = "blastx";
	$settingsHash->{DATABASE} = "nr";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "3";
	$settingsHash->{OUTPUTFILE} = "blastx_results.txt";
	$settingsHash->{INPUTTYPE} = "DNA";
	$settingsHash->{ENTREZ_DB} = "Protein";
    }

    #4 - Protein query vs translated database (tblastn)
    elsif ($blastType == 4) {
	$settingsHash->{PROGRAM} = "tblastn";
	$settingsHash->{DATABASE} = "nr";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "3";
	$settingsHash->{OUTPUTFILE} = "tblastn_results.txt";
	$settingsHash->{INPUTTYPE} = "protein";
	$settingsHash->{ENTREZ_DB} = "DNA";
    }

    #5 - Translated query vs. translated database (tblastx)
    elsif ($blastType == 5) {
	$settingsHash->{PROGRAM} = "tblastx";
	$settingsHash->{DATABASE} = "nr";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "3";
	$settingsHash->{OUTPUTFILE} = "tblastx_results.txt";
	$settingsHash->{INPUTTYPE} = "DNA";
	$settingsHash->{ENTREZ_DB} = "DNA";
    }
}
