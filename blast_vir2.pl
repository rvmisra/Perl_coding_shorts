  #!/usr/local/bin/perl
#blast_vir1.pl
#Author: Raju Misra
#This script uses the virulence database at: http://zdsys.chgb.org.cn/VFs/search_VFs.htm 
#BLAST facilty to identify virulence related proteins in a given FASTA sequence.


use warnings;
use strict;

#Perl comes with a group of modules that can be used to automate Web-related activities.
#We need to load two modules that we will be using.
use LWP::UserAgent;
use HTTP::Request::Common;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

$/ = ">";

#Read each FASTA entry and add the sequence titles to @arrayOfNames and the sequences
#to @arrayOfSequences.
my @arrayOfNames = ();
my @arrayOfSequences = ();
while (my $sequenceEntry = <PROTEINFILE>) {
    if ($sequenceEntry eq ">"){
next;
    }
    my $sequenceTitle = "";
    if ($sequenceEntry =~ m/([^\n]+)/){
	$sequenceTitle = $1;
    }
    else {
	$sequenceTitle = "No title was found!";
    }
    $sequenceEntry =~ s/[^\n]+//;
    push (@arrayOfNames, $sequenceTitle);
    $sequenceEntry =~ s/[^ACDEFGHIKLMNPQRSTVWY]//ig;
    push (@arrayOfSequences, $sequenceEntry);
}
close (PROTEINFILE) or die( "Cannot close file : $!");


  #Store the BLAST URL we will be using in $url.                       
my $url = "http://zdsys.chgb.org.cn/cgi-bin/VFs/blast/blast_cs.cgi";


#go through the list of sequences in the sequence area        
for (my $i = 0; $i < scalar(@arrayOfSequences); $i = $i + 1) {

#Create a user agent object of class LWP::UserAgent. The user agent object acts       
#like a web browser, and we can use it to send requests for resources on the web.     	
#The user agent object returns the results of these requests to us in the form        	
#of a response object.                                                                	
#In the following statement we are creating the user agent object using the           	
#"LWP::UserAgent->new()". We refer to this object using $browser. Thus we have        	
#created a virtual web browser that we can access using a name we gave it--$browser.  	
	
	my $browser = LWP::UserAgent->new();
                                    
	#We have our virtual browser that we want to use to submit BLAST queries.
  my $response = $browser->request(POST ($url, [DATALIB => "VFs.faa", HITLIST_SIZE => "10",
  FILTER => "L", PROGRAM  => "blastp", SEQUENCE => $arrayOfSequences[$i], CMD => "Put"]));
    
    #We will change the timeout value of our browser, which is how long the browser
	#will wait for a response before timing out (i.e., canceling the request).
	#We will set it to 30 seconds.
$browser->timeout(30);
# The 'die' command is used in case there is no response from the web site.
# If there is no response the script will exit.
die "Error while getting ", $response->request->uri,
    " -- ", $response->status_line, "\nAborting"
    unless $response->is_success;

# The results are stored in the scalar '$results'. The '$response->as_string' code
# specifies that the data from the web site should be in the form of a string.
#my $results = $response->as_string();
 print "Pausing after submission.\n";
    sleep(5);

    #########################################################################################
    #########################################################################################
    ##### This block is used to print the results to a file called 'blast_results.html'.#####
    #########################################################################################
    #########################################################################################

open(OUTFILE, ">blast_results.html");

for (my $i = 0; $i < scalar(@arrayOfSequences); $i = $i + 1) {  
	
#We have our virtual browser that we want to use to submit BLAST queries.                 	
my $response = $browser->request(POST ($url, [DATALIB => "VFs.faa", HITLIST_SIZE => "10",	
FILTER => "L", PROGRAM  => "blastp", SEQUENCE => $arrayOfSequences[$i], CMD => "Put"])); 	
	            
my $result = $response->as_string();                                        

print(OUTFILE "Results of automated BLAST query.\n");


print(OUTFILE "*****************************************\n");
print(OUTFILE "\n"); 
print(OUTFILE "\n"); 
print "Requesting results for sequence " . ($i + 1) . ".\n";                                	




                   
print OUTFILE ("Results for $arrayOfNames[$i].\n");
print "\n";                                           
print OUTFILE $result;
print OUTFILE "-----------------------------------------------------------------------------";                                                                                               
}
}                                                    
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Open blast_results.html to view the results.\n";
