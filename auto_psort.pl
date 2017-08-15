#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;

my $templateDirectory = './sequences/'; #for Unix
my $outputDirectory = './results/'; #for Unix
my $firstTime = 1;
my $sequenceTitle = "";
my $sequenceProper = "";
my $readLine = "";
my $fileFound = 0;
my $sequenceLength = 0;
my $count = 1;
my $errorCount = 0;
my $sequentialErrors = 0;
my $outputString = "";
my $TIMEOUT = 10; #the number of seconds to wait for a response from a server.
my $ACCEPTEDERRORS = 3; #the max number of times one sequence is resubmitted when a server does not respond. Each time the sequence is resubmitted, the next server in the @urls array is used. A sequence is skipped once $ACCEPTEDERRORS is exceeded.
my $ACCEPTEDSEQUENTIAL = 3; #the max number of sequential sequence skips permitted. Program is stopped once this is exceeded.
my $DELAY = 2; #the number of seconds to wait before the next request is sent to a server.
my @psort = (); 

my @urls = ("http://psort.nibb.ac.jp/cgi-bin/okumura.pl");  #in this array enter the known servers that can respond to the query.
my $url = "";

opendir ( DIR, $templateDirectory ) or die ( "Could not open 'sequences' directory: $! \n" );
foreach ( readdir( DIR ) ) {
   my $file = "<" . $templateDirectory . $_;
   if ($_ =~ m/\.txt/) {
      $fileFound = 1;
      my $fileToWrite = $_;
      print "reading " . $_ . " from the 'sequences' directory\n";
      $fileToWrite =~ s/\.txt//i;
      my $outputFile = ">" . $outputDirectory . $fileToWrite . ".txt";
      open (OUT, $outputFile) or die ( "Cannot write the results to file: $! \n" );
      print (OUT "Each entry contains the sequence name, its length, and PSORT results.\n");
      print (OUT "Entries are separated by a row of 10 dashes.\n");
      print (OUT "----------\n");
      open ( IN, $file ) or die ( "Cannot open file for reading: $! \n" );
      while ($readLine = <IN>) {
	  if ($readLine =~ m/>/) {
              if ($firstTime) {
		  $firstTime = 0;
		  $sequenceTitle = substr(filterProb($readLine),0,19);
	      }
	      else {
		  $sequenceLength = length($sequenceProper);
		  do { 
		      $url = shift(@urls);
		      push(@urls, $url);
		      $url = $url . "?origin=animal&title=&" . "sequence=$sequenceProper";
		      $outputString = callToPSORT($url);
		      if ($errorCount > $ACCEPTEDERRORS) {
			  print "skipping sequence $count\n";
			  $sequentialErrors = $sequentialErrors + 1;
			  $outputString = "no response";
		      }
		  } until ($outputString ne "false");
		  $errorCount = 0;
		  if ($sequentialErrors > $ACCEPTEDSEQUENTIAL) {
		      print (OUT "The program was stopped because the PSORT servers could not be accessed\n");
		      close ( OUT ) or die ( "Cannot close file for writing: $! \n" );
		      die ("The program has been stopped because the PSORT servers could not be accessed\n");
		  }
		  if (($outputString =~ m/\-{5} Final Results \-{5}/) && ($outputString =~ m/\-{5} The End \-{5}/)) {
		     @psort = split(/\-{5} Final Results \-{5}|\-{5} The End \-{5}/,$outputString);
		  }
		  elsif ($outputString eq "no response") {		      
		      $psort[1] = "Could not connect to the PSORT servers\n";
		  }
		  else {
		      $psort[1] = "A response was received, but there were no results. There may be a problem with the sequence\n"; #if PSORT returns a response saying the sequence was too short or that the format was not correct.
		  }
		  print (OUT "$sequenceTitle " . "($sequenceLength residues)\n");
		  print (OUT $psort[1]);
		  print (OUT "----------\n");
		  print "wrote results to $fileToWrite" . ".txt\n"; 
		  print "built in delay of $DELAY seconds\n";
		  sleep($DELAY);
		  $sequenceProper = "";
		  $sequenceTitle = filterProb($readLine);
		  $count = $count + 1;
	      }
	  }
	  else {
	      $sequenceProper = $sequenceProper . filterProb($readLine);
	  }
      }
      $sequenceLength = length($sequenceProper);
      do {
	  $url = shift(@urls);
	  push(@urls, $url);
	  $url = $url . "?origin=animal&title=&" . "sequence=$sequenceProper";
	  $outputString = callToPSORT($url);
	  if ($errorCount > $ACCEPTEDERRORS) {
	      $sequentialErrors = $sequentialErrors + 1;
	      $outputString = "There was a problem accessing the PSORT servers\n";
	  }
      } until ($outputString ne "false");
      $errorCount = 0;
      if ($sequentialErrors > $ACCEPTEDSEQUENTIAL) {
	  print (OUT "The program was stopped because the PSORT servers could not be accessed\n");
	  close ( OUT ) or die ( "Cannot close file for writing: $! \n" );
	  die ("The program has been stopped because the PSORT servers could not be accessed\n");
      }
      if (($outputString =~ m/\-{5} Final Results \-{5}/) && ($outputString =~ m/\-{5} The End \-{5}/)) {
	  @psort = split(/\-{5} Final Results \-{5}|\-{5} The End \-{5}/,$outputString);
      }
      elsif ($outputString eq "no response") {		      
	  $psort[1] = "Could not connect to the PSORT servers\n";
      }
      else {
	  $psort[1] = "A response was received, but there were no results. There may be a problem with the sequence\n"; #if PSORT returns a response saying the sequence was too short or that the format was not correct.
      }

      print (OUT "$sequenceTitle " . "($sequenceLength residues)\n");
      print (OUT $psort[1]);
      print (OUT "----------\n");
      print "wrote results to $fileToWrite" . ".txt\n"; 
      close ( IN ) or die ( "Cannot close file for reading: $! \n" );
      close ( OUT ) or die ( "Cannot close file for writing: $! \n" );
      print "finished\n";
      $count = 1;
  }
}

if (!($fileFound)) {
  print "no .txt files were found in the 'sequences' directory\n";
}

sub filterProb {
   my $textToFilter = shift();
   $textToFilter =~ s/[\f\n\r\t\'\"\>\<\\\/\&\| ]+/ /g;
   $textToFilter =~ s/ +/ /g;
   $textToFilter =~ s/^ | $//g;
   $textToFilter =~s/[\,\.]+$//g;
   return $textToFilter;
}

sub callToPSORT {
    my $url = shift();
    my $agent = new LWP::UserAgent();
    $agent->proxy('http', 'http://158.119.147.40:3128/');
    
    $agent->timeout($TIMEOUT);
    my $request = new HTTP::Request( 'GET', $url );
    $request->content_type( 'application/x-www-form-urlencoded' );
    print "sending request for sequence $count\n";
    my $response = $agent->request($request);
    if ($response->is_success()) {
	print "response received for sequence $count\n";
	$sequentialErrors = 0;
	return $response->as_string();
    }
    else {
	print "no response received for sequence $count\n";
	print "trying again\n";
	$errorCount = $errorCount + 1;
	return "false";
    }
}


