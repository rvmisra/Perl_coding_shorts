#!/usr/local/bin/perl
#blast.pl
#Author Raju Misra, adapted from Author: Paul Stothard, Genome Canada Bioinformatics Help Desk
#This script reads multiple protein sequences (in FASTA format) from a file
#and submits them to NCBI's BLAST server. The results for each sequence
#are written to a file.

use warnings;
#use strict;

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
my $url = "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi";

#Create a user agent object of class LWP::UserAgent. The user agent object acts
#like a web browser, and we can use it to send requests for resources on the web.
#The user agent object returns the results of these requests to us in the form
#of a response object.
#In the following statement we are creating the user agent object using the 
#"LWP::UserAgent->new()". We refer to this object using $browser. Thus we have 
#created a virtual web browser that we can access using a name we gave it--$browser.  

my $browser = LWP::UserAgent->new();

#Our virtual web browser has many attributes we can adjust. A list of these attributes
#is available at http://search.cpan.org/author/GAAS/libwww-perl/lib/LWP/UserAgent.pm
#We will change the timeout value of our browser, which is how long the browser
#will wait for a response before timing out (i.e., canceling the request).
#We will set it to 30 seconds.
$browser->timeout(30);

#We have our virtual browser that we want to use to submit BLAST queries. NCBI
#provides information on how to communicate with their BLAST server at
#http://www.ncbi.nlm.nih.gov/BLAST/Doc/urlapi.html
#Briefly, a sequence is sent using our browser, and the BLAST server sends
#back a RID (Request Identifier) and a RTOE (Request Time of Execution). The
#RID is a number that we can use to obtain the BLAST results once the search
#is finished. The RTOE is the predicted number of seconds it will take the
#BLAST server to complete the BLAST search.
#The RID and RTOE are sent as part of a web page to our virtual browser. They
#are formatted as in the following example:
#    <!--QBlastInfoBegin
#        RID = 954517067-8610-1647
#        RTOE = 207
#    QBlastInfoEnd
#    -->
#We can use the matching operator to store the RID and RTOE in variables.

#The next section of code sends sequences to the BLAST server and stores
#the RID and RTOE values in the arrays @arrayOfRID and @arrayOfRTOE.
#The values in these arrays are later used to obtain the results of the BLAST
#searches.


#For each protein sequence send a request to BLAST. The request
#first request sends a request id (RID), which we will store.
my @arrayOfRID = ();
my @arrayOfRTOE = ();
for (my $i = 0; $i < scalar(@arrayOfSequences); $i = $i + 1) {
    print "Sending RID request for sequence $arrayOfNames[$i]  " . ($i + 1) . ".\n";
    
    #Send a request to the BLAST server. A request contains the information that a normal
    #web browser sends to a server when it makes a request for a particular page. This
    #information includes the URL of the page. In our case we also need to submit the
    #information that the BLAST server expects.
    #The following statement causes our virtual browser to send a request. The results
    #of the request, the response, is stored in $response.
    #The part of the request that the BLAST server sees is the list of attributes and values,
    #starting with DATABASE = > "nr", and ending with CMD => "Put". There are many
    #other options that can be specified. These are described at:
    #http://www.ncbi.nlm.nih.gov/BLAST/Doc/urlapi.html. The most important are: PROGRAM,
    #which we set to "blastp" because we are searching with a protein; QUERY, which
    #we set to $arrayOfSequences[$i]; and CMD, which we set to "Put", which tells 
    #the server we are submitting a search.
    #The HTTP::Request::Common module's POST method takes $url and the list of attributes
    #and values, and makes a request object that is sent using $browser's request method.
    # my $response = $browser->request(POST ($url, [DATABASE => "nr", HITLIST_SIZE => "10",
       my $response = $browser->request(POST ($url, [DATABASE => "nr", HITLIST_SIZE => "50",
    FILTER => "L", PROGRAM  => "blastp", EXPECT => "0.0001", GAPCOSTS => "10 1", MATRIX_NAME => "PAM30", 
    QUERY => $arrayOfSequences[$i], CMD => "Put"]));
    #$response is an object, which means it is a collection of values and methods. The different
    #values it contains are described in the Perl documentation:
    #http://search.cpan.org/author/GAAS/libwww-perl/lib/HTTP/Response.pm
    #We will use the "is_success()" method, which returns true if a response was received
    #from the BLAST server.
    if ($response->is_success()) {
	
	#The "as_string()" method returns the contents of the response (the web page)
	#as a string. We will use the matching operator to find the RID and RTOE in this
	#string, and we will store these values in an array.
	my $result = $response->as_string();
	if ($result =~ m/QBlastInfoBegin\s*RID\s=\s([^\s]+)\s*RTOE\s=\s(\d+)\s*QBlastInfoEnd/) {
	    print "A RID was received for sequence " . ($i + 1) . ".\n";
	    push (@arrayOfRID, $1);
	    push (@arrayOfRTOE, $2);
            my $minutes=$2/60;
            print "Estimated time of completion is $2 seconds or $minutes minutes.\n";
	}
	else {
	    #if for some reason we cannot find the RID and RTOE values we will store an error
	    #message instead.
	    print "The response received for sequence " . ($i + 1) . " was not understood.\n";
	    push (@arrayOfRID, "The response received for $arrayOfNames[$i] was not understood.");
	    push (@arrayOfRTOE, "The response received for $arrayOfNames[$i] was not understood.");
	}
    }
    else {
	#If no response was received from the BLAST server we will print a message on the
	#screen and store error messages instead of the RID and RTOE.
	print "No response was received for sequence " . ($i + 1) . ".\n";
	push (@arrayOfRID, "No response was received for $arrayOfNames[$i].");
	push (@arrayOfRTOE, "No response was received for $arrayOfNames[$i].");
    }
    #If sequences are submitted very rapidly to the BLAST server, NCBI may block the submitting
    #site. The "sleep" statement stops execution for the specified number of seconds. After the
    #pause, the next sequence is submitted.
    print "Pausing after submission.\n";
    sleep(5);
}

#We have submitted the sequences to BLAST and have received RIDs and RTOEs, or error 
#messages. Now we need to ask the BLAST server for the formatted results of the
#BLAST searches we submitted.
#To do this we will go through the RID and RTOE values obtained for each sequence.
#The script will sleep for the number of seconds specified by the RTOE value, since
#the results probably won't be ready until the RTOE time has elapsed. We will use
#$totalTimeSlept to store how much time has been spent sleeping in total. If 
#$totalTimeSlept is greater than the RTOE, the script pauses for 3 seconds.

open(OUTFILE, ">NCBI_blast_results_UNIQUE_test5A.txt") or die ("Cannot open file : $!");

     

	print(OUTFILE "Results of automated BLAST query.\n");
print(OUTFILE "---------------------------------\n");
my $totalTimeSlept = 0;
my $resultFound = 0;
for (my $i = 0; $i < scalar(@arrayOfRID); $i = $i + 1) {
    
    #Recall that if we had a problem obtaining the RID or RTOE from the BLAST server
    #we added a message to @arrayOfRID and @arrayOfRTOE in place of the numbers.
    #first make sure that the RTOE value isn't an error message. We can use
    #the regular expression ^\d+$ which only matches entries that contain
    #all digits. If the entry only contains numbers, execution continues with 
    #the else statement, otherwise the message in $arrayOfRTOE is written
    #to our results file.  
    if (!($arrayOfRTOE[$i] =~ m/^\d+$/)) {
	print(OUTFILE "Results for $arrayOfNames[$i].\n" . 
	      $arrayOfRTOE[$i] . "\n" . "---------------------------------\n");
    }
    else {
	if ($arrayOfRTOE[$i] > $totalTimeSlept) {
	    print "Pausing before requesting results.\n";
	    sleep($arrayOfRTOE[$i] - $totalTimeSlept);
	    $totalTimeSlept = $totalTimeSlept + ($arrayOfRTOE[$i] - $totalTimeSlept);
	}
	else {
	    print "Pausing before requesting results.\n";
	    sleep(12);
	}
	
	#Now the results should be ready. To request the results using the RID, we need
	#to send two values to the BLAST server in the list of attributes and values.
	#RID => $arrayOfRID[$i] sends the RID number to the server, and CMD => "Get"
	#tells the server that we are requesting the results for this RID. Many other
	#options can be passed to the server to control what information is returned.
	#See http://www.ncbi.nlm.nih.gov/BLAST/Doc/urlapi.html
	#When the BLAST server receives the request with CMD => "Get", it checks to 
	#see if the results are ready. If they are not, the server sends a page 
	#containing the following text:
        #  <!--QBlastInfoBegin
        #       Status=WAITING
        #      QBlastInfoEnd
        #  -->
	#
	#If the results are ready, they are sent along with the following text:
	#    <!--QBlastInfoBegin
        #        Status=READY
        #        QBlastInfoEnd
        #    -->
	#When the WAITING message is in the response, the script pauses for 10 seconds
	#and then asks for the results again using the while loop. When the
	#READY message is received in the response, the response is added to a file,
	#and $resultFound is set to 1 so that the while loop exited.
	while ($resultFound == 0) {
	    print "Requesting results for sequence " . ($i + 1) . ".\n";
	    my $response = $browser->request(POST ($url, [RID => $arrayOfRID[$i], FORMAT_TYPE => "Text",
	       CMD => "Get"]));
	    if ($response->is_success()) {
		my $result = $response->as_string();
				
		    if ($result =~ m/QBlastInfoBegin\s*Status=READY\s*QBlastInfoEnd/){
		    print "The results were received for sequence $arrayOfNames[$i]  " . ($i + 1) . ".\n";
		    print "Writing the results to NCBI_blast_results_UNIQUE_CUPID_test3.txt\n"; 
	    

		    
#the regex used here looks for any character that is front of the word bacill, eg. lactobacllus
#if it matches then will print "...is not unique", otherwise will print the other correct genus specific
#matches.    		

	if ($result =~ m/Bacillus/) {
			  print(OUTFILE "Results for : $arrayOfNames[$i] : .\n");
		      $resultFound = 1;
	}
	
	if ($result !~ m/Bacillus/) {
			  print(OUTFILE "Results for : $arrayOfNames[$i] : ");
			  print(OUTFILE "()()()()() No good is not bacilli ()()()():\n");
			  
		      $resultFound = 1;
	}
	
		elsif ($result =~ m/QBlastInfoBegin\s*Status=WAITING\s*QBlastInfoEnd/) {
		    print "The results are not ready for sequence " . ($i + 1) . ".\n";
		    print "Pausing before requesting again.\n";
		    sleep(5);
		}
				
}    
			
	    else {
		print "No response received when requesting results for sequence " . ($i + 1) . ".\n";
		#print(OUTFILE "No result was obtained for $arrayOfNames[$i].\n" . 
		 #    "The RID for the results is $arrayOfRID[$i].\n" .
		  #    "---------------------------------\n");
		$resultFound = 1;
	    }
    
	    
	} #end of while loop
}
}

    $resultFound = 0;
}


#Close the filehandle.    
close(OUTFILE) or die ("Cannot close file : $!");
print "Open NCBI_blast_results_UNIQUE_test5A.txt to view the results.\n";
