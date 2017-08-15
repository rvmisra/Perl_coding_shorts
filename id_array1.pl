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