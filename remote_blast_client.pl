#!/usr/bin/perl
#remote_blast_client.pl
#Version 1.0
#
#Written by Paul Stothard, University of Alberta.
#stothard@ualberta.ca

use warnings;
use strict;
use Getopt::Long;
use LWP::UserAgent;
use HTTP::Request::Common;

my $BLAST_URL = "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi";
my $ENTREZ_URL = "http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?";

my %settings = (PROGRAM => undef,
		DATABASE => undef,
		EXPECT => undef,
		WORD_SIZE => undef,
		HITLIST_SIZE => "5",
		FILTER => "L",
		OUTPUTFILE => undef,
		INPUTFILE => undef,
		INPUTTYPE => undef,
		ENTREZ_DB => undef,
		ENTREZ_QUERY => undef,
		ALIGN_TYPE => undef);

my $blastType = undef;

my @settingsKeys = keys(%settings);

Getopt::Long::Configure ('bundling');
GetOptions ('i|input_file=s' => \$settings{INPUTFILE},
	    'o|output_file=s' => \$settings{OUTPUTFILE},
	    'b|blast_program=s' => \$blastType,
	    'e|entrez_query=s' => \$settings{ENTREZ_QUERY},
	    'd|database=s' => \$settings{DATABASE});

if (!(defined($blastType))) {
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
    $blastType = <STDIN>;
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
}

if (!(defined($settings{DATABASE}))) {
    print "------------------------------------------------------------\n";
    print "Please enter the name of the database you wish to search.\n";
    print "------------------------------------------------------------\n";
    $settings{DATABASE} = <STDIN>;
    chomp($settings{DATABASE});
}

if (!(defined($settings{INPUTFILE}))) {
    print "------------------------------------------------------------\n";
    print "Enter an entrez query or press enter to search all sequences.\n";
    print "For example, the term 'bacteria[Organism]' restricts the\n";
    print "search to bacteria sequences only.\n";
    print "------------------------------------------------------------\n";
    $settings{ENTREZ_QUERY} = <STDIN>;
    chomp($settings{ENTREZ_QUERY});
}

_setDefaults($blastType, \%settings);

if (!(defined($settings{INPUTFILE}))) {
    print "------------------------------------------------------------\n";
    print "Enter the name of the FASTA format " . $settings{INPUTTYPE} . " sequence file\n";
    print "that contains your query sequences.\n";
    print "------------------------------------------------------------\n";
    $settings{INPUTFILE} = <STDIN>;
    chomp($settings{INPUTFILE});
}

open (SEQFILE, $settings{INPUTFILE}) or die( "Cannot open file : $!" );

my $inputLessExtentions = $settings{INPUTFILE};
if ($settings{INPUTFILE} =~ m/(^[^\.]+)/g) {
    $inputLessExtentions = $1;
}

if (!(defined($settings{OUTPUTFILE}))) {
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
}

#make sure output file does not already exist
if (-e $settings{OUTPUTFILE}) {
    die ("The file " . $settings{OUTPUTFILE} . " already exists. Please rename it or move it to another location.\n");
}

#Open file for recording results.
open(OUTFILE, "+>>" . $settings{OUTPUTFILE}) or die ("Cannot open file : $!");
print(OUTFILE "#-------------------------------------------------------------------------------------------------------------------------------------------------\n");
print(OUTFILE "#Results of automated BLAST query of performed on " . _getTime() . ".\n");
print(OUTFILE "#Searches performed using remote_blast_client.pl, written by Paul Stothard, stothard\@ualberta.ca.\n");
print(OUTFILE "#The following settings were specified:\n");
foreach(@settingsKeys) {
    if (defined($settings{$_})) {
	print(OUTFILE "#" . $_ . "=" . $settings{$_} . "\n"); 
    }
}
print(OUTFILE "#The following attributes are separated by tabs:\n");
if ($settings{ALIGN_TYPE} eq "nucleotide") {
    print(OUTFILE "#query_id, match_id, match_description, %_identity, alignment_length, mismatches, gap_openings, q_start, q_end, s_start, s_end, e-value, bit_score\n");
}
else {
    print(OUTFILE "#query_id, match_id, match_description, %_identity, %_positives, query/sbjct_frames, alignment_length, mismatches
, gap_opens, q_start, q_end, s_start, s_end, evalue, bit_score\n");
}
print(OUTFILE "#-------------------------------------------------------------------------------------------------------------------------------------------------\n");
close(OUTFILE) or die ("Cannot close file : $!");

#Create UserAgent object.
my $browser = LWP::UserAgent->new();

$browser->proxy('http', 'http://158.119.147.40:3128/');

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
    my $response;
    if (defined($settings{ENTREZ_QUERY})) {
	$response = $browser->request(POST ($BLAST_URL, [DATABASE => $settings{DATABASE}, HITLIST_SIZE => $settings{HITLIST_SIZE}, ENTREZ_QUERY => $settings{ENTREZ_QUERY}, EXPECT => $settings{EXPECT}, WORD_SIZE => $settings{WORD_SIZE}, FILTER => $settings{FILTER}, PROGRAM => $settings{PROGRAM}, QUERY => $query, CMD => "Put"]));
    }
    else {
	$response = $browser->request(POST ($BLAST_URL, [DATABASE => $settings{DATABASE}, HITLIST_SIZE => $settings{HITLIST_SIZE}, EXPECT => $settings{EXPECT}, WORD_SIZE => $settings{WORD_SIZE}, FILTER => $settings{FILTER}, PROGRAM => $settings{PROGRAM}, QUERY => $query, CMD => "Put"]));
    }
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

			#Tabular format returns each hit as a space separated sequence of 12 values.
			my $hitFound = 0;
			my $searchPattern;
			if ($settings{ALIGN_TYPE} eq "nucleotide") {
			    $searchPattern = '^(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]*$';
			}
			else {
			    $searchPattern = '^(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]+(\S+)[\t ]*$';
			}
			while ($result =~ m/$searchPattern/gm) {

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
			    my $col13 = undef;
			    my $col14 = undef;
			    my $uid = undef;

			    if ($settings{ALIGN_TYPE} eq "protein") {
				$col13 = $13;
				$col14 = $14;
			    }

			    #this is to return a single gi number in $col2
			    if ($col2 =~ m/(ref|gi)\|(\d+)/) {
				$uid = $2;
				$col2 = $1 . "|" . $2;
			    }

			    #obtain description from NCBI

			    my $desc = "";
			    if (defined($uid)) { 
				print "Requesting sequence description.\n";
				sleep(1);
				my $responseDesc = $browser->request(POST ($ENTREZ_URL . "cmd=text&db=" . $settings{ENTREZ_DB} . "&uid=$uid&dopt=DocSum"));
				if ($responseDesc->is_success()) {
				    my $resultDesc = $responseDesc->as_string();
				    #print $resultDesc . "\n";
				    if ($resultDesc =~ m/(<pre>[\s\S]+<\/pre>)/i) {
					$resultDesc = $1;
				    }
				    else {
					$resultDesc = "Error 5: the response obtained for sequence description was not understood.";
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
				    $desc = "Error 6: Could not obtain description for $uid.";
				}
			    }
			    else {
				$desc = "Error 7: Could not parse gi number";
			    }			    
			    if ($settings{ALIGN_TYPE} eq "nucleotide") {
				print (OUTFILE $col1 . "\t" . $col2 . "\t" . $desc . "\t" . "\t" . $col3 . "\t" . $col4 . "\t" . $col5 . "\t" . $col6 . "\t" . $col7 . "\t" . $col8 . "\t" . $col9 . "\t" . $col10 . "\t" . $col11 . "\t" . $col12 . "\n");
			    }
			    else {
				print (OUTFILE $col1 . "\t" . $col2 . "\t" . $desc . "\t" . "\t" . $col3 . "\t" . $col4 . "\t" . $col5 . "\t" . $col6 . "\t" . $col7 . "\t" . $col8 . "\t" . $col9 . "\t" . $col10 . "\t" . $col11 . "\t" . $col12 . "\t" . $col13 . "\t" . $col14 . "\n");
			    }
	
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
    sleep(3);
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
    if (($blastType =~ /^blastn$/i) || ($blastType eq "1")) {
	$settingsHash->{PROGRAM} = "blastn";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "11";
	$settingsHash->{INPUTTYPE} = "DNA";
	$settingsHash->{ENTREZ_DB} = "Nucleotide";
	$settingsHash->{ALIGN_TYPE} = "nucleotide";	
    }
    
    #2 - Protein-protein BLAST (blastp)
    elsif (($blastType =~ /^blastp$/i) || ($blastType eq "2")) {
	$settingsHash->{PROGRAM} = "blastp";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "3";
	$settingsHash->{INPUTTYPE} = "protein";
	$settingsHash->{ENTREZ_DB} = "Protein";
	$settingsHash->{ALIGN_TYPE} = "protein";
    }
    
    #3 - Translated query vs protein database (blastx)
    elsif (($blastType =~ /^blastx$/i) || ($blastType eq "3")) {
	$settingsHash->{PROGRAM} = "blastx";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "3";
	$settingsHash->{INPUTTYPE} = "DNA";
	$settingsHash->{ENTREZ_DB} = "Protein";
	$settingsHash->{ALIGN_TYPE} = "protein";
    }

    #4 - Protein query vs translated database (tblastn)
    elsif (($blastType =~ /^tblastn$/i) || ($blastType eq "4")) {
	$settingsHash->{PROGRAM} = "tblastn";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "3";
	$settingsHash->{INPUTTYPE} = "protein";
	$settingsHash->{ENTREZ_DB} = "DNA";
	$settingsHash->{ALIGN_TYPE} = "protein";
    }

    #5 - Translated query vs. translated database (tblastx)
    elsif (($blastType =~ /^tblastx$/i) || ($blastType eq "5")) {
	$settingsHash->{PROGRAM} = "tblastx";
	$settingsHash->{EXPECT} = "10";
	$settingsHash->{WORD_SIZE} = "3";
	$settingsHash->{INPUTTYPE} = "DNA";
	$settingsHash->{ENTREZ_DB} = "DNA";
	$settingsHash->{ALIGN_TYPE} = "protein";
    }
    else {
	die ("blast type $blastType is not recognized.");
    }
}
