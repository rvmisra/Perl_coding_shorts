#!/usr/bin/perl


use warnings;
use strict;

use LWP::UserAgent;
use HTTP::Request::Common;

#This value is for Unix:
#my $PATH_MIDDLE = "/";

#This value is for Windows:
my $PATH_MIDDLE = "\\";

#Create UserAgent object.



my $browser = LWP::UserAgent->new();

$browser->proxy('http', 'http://158.119.147.40:3128/');

$browser->timeout(30);

#Command line processing.
use Getopt::Long;

my $inputFile;
my $outputDirectory;
my $contentsFile;

Getopt::Long::Configure ('bundling');
GetOptions ('i|input_file=s' => \$inputFile,
            'o|output_directory=s' => \$outputDirectory);

if(!defined($inputFile)) {
    die ("Usage: NCBI_BLAST.pl -i <input file> -o <output directory>\n");
}

if(!defined($outputDirectory)) {
    die ("Usage: NCBI_BLAST.pl -i <input file> -o <output directory>\n");
}


#create directory if it doesn't exist
if (!(-d $outputDirectory)) {
    mkdir ($outputDirectory, 0777);
}

#check for index.html file
if (-e $outputDirectory . $PATH_MIDDLE . "index" . ".html") {
    die ("Please empty the directory $outputDirectory, or use a new output directory.");
}

my $htmlHeader = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html lang=\"en\">\n<head>\n<title>Batch BIND BLAST results</title>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=ISO-8859-1\" />\n</head>\n<body>\n";

my $htmlFooter = "</body>\n</html>\n";

open (INDEXFILE, ">>" . $outputDirectory . $PATH_MIDDLE . "index" . ".html")  or die ("Cannot open file for output: $!");
print (INDEXFILE $htmlHeader);
print (INDEXFILE "Click on the sequence titles to view the BIND BLAST results. Use links in the results pages to view more detailed descriptions of the hits.<br />\n<br />\n<ul>\n");
close (INDEXFILE);

#check for 1.html file
if (-e $outputDirectory . $PATH_MIDDLE . "1.html") {
    die ("Please empty the directory $outputDirectory, or use a new output directory.");
}

#read each record from the input file
open (INFILE, $inputFile) or die( "Cannot open file : $!" );
$/ = ">";

my $seqCount = 1;

#read each sequence.
while (my $sequenceRecord = <INFILE>) {

    if ($sequenceRecord =~ m/^\s*>/){
        next;
    }

    my $sequenceTitle = "";
    if ($sequenceRecord =~ m/^([^\n]+)/){
        $sequenceTitle = $1;
    }
    else {
        $sequenceTitle = "No title was found!";
    }

    $sequenceRecord =~ s/^[^\n]+//;
    $sequenceRecord =~ s/[^A-Za-z]//g;

    #now submit blast
    print "submitting sequence $seqCount.\n";
    my $ua = LWP::UserAgent->new(env_proxy => 1
     #                        keep_alive => 1,
      #                       timeout => 120,
       
     #                      agent => 'IE/6.0',
                          );

    my $req = 
    POST 'http://www.ncbi.nlm.nih.gov/blast/Blast.cgi',
    Content_Type         => 'multipart/form-data',
    #Content                => [ ' PROGRAM' => 'blastp', ' DATALIB' => ' bind_aa.fsa', ' INPUT_TYPE' => ' Sequence in FASTA format', 'SEQUENCE' => '>' . $sequenceTitle . "\n" . $sequenceRecord, 'FILTER' => 'L', ' EXPECT' => ' 10', ' MAT_PARAM' => ' BLOSUM62         11         1', ' GENETIC_CODE' => ' Standard (1)', ' OOF_ALIGN' => ' 0', ' ALIGNMENT_VIEW' => '0', ' DESCRIPTIONS' => ' 100 ', ' ALIGNMENTS' => ' 50 ', ' COLOR_SCHEMA' => '0'];

    POST 'blastall -db nr -p blastp -i $inputFile';
    
    my $response = $ua->request($req);

    my $result;

    
     
    
    
    
    if ($response->is_success()) {
        $result = $response->as_string();
        print ("A response was received for record $seqCount.\n");
    }
    else {
        $result = "$htmlHeader A problem was encountered when submitting this sequence. $htmlFooter";
        print ("A response was not received for record $seqCount.\n");
    }

    if ($result =~ m/(<HTML>[\s\S]+<\/HTML>)/) {
        $result = $1;
    }

    $result =~ s/<A HREF="blast_form\.map"> \cM<IMG SRC="images\/blast_results\.gif" BORDER=0 ISMAP>\cM<\/A><P>//;

    if (-e $outputDirectory . $PATH_MIDDLE . $seqCount . ".html") {
        die ("Please empty the directory $outputDirectory, or use a new output directory.");
    }

    #now write result to $outputDirectory
    open(OUTFILE, ">" . $outputDirectory . $PATH_MIDDLE . $seqCount . ".html")  or die ("Cannot open file for output: $!");
    print (OUTFILE $result);
    close (OUTFILE);

    #now add links to the index file
    open (INDEXFILE, ">>" . $outputDirectory . $PATH_MIDDLE . "index" . ".html")  or die ("Cannot open file for output: $!");
    print (INDEXFILE "<li>\n<a href=\"" . $seqCount . ".html"  . "\">" . $sequenceTitle . "</a><br />\n</li>\n");
    close (INDEXFILE);

    $seqCount = $seqCount + 1;

    #Please DO NOT remove the sleep statement.
    print ("Pausing 10 seconds before next submission.\n");
    sleep(10);


}#end of while loop

close (INFILE) or die( "Cannot close file : $!");

open (INDEXFILE, ">>" . $outputDirectory . $PATH_MIDDLE . "index" . ".html")  or die ("Cannot open file for output: $!");
print (INDEXFILE "</ul>\n$htmlFooter");
close (INDEXFILE);