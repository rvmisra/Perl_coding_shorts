#!/usr/local/bin/perl
#genbank_parse1.pl
#Author: Raju Misra
#This script ...


use warnings;
use strict;

#Perl comes with a group of modules that can be used to automate Web-related activities.
#We need to load two modules that we will be using.
use LWP::UserAgent;
use HTTP::Request::Common;
use BeginPerlBioinfo;

#declare and initilise variables
my @genbank = ();

my $geneID = '';
my $gi = '';
my $accession='';
#get genbank file data
@genbank = get_file_data('px01.gb');

#let's startwith something simple.  Lets get some of the identifying information:locus & accession number & defintiton

for my $line (@genbank) {

	while (@genbank) {
	
		
				
	if($line =~ m/GeneID:/) {
	 $line=~ s/GeneID:\s*//;
	 $geneID=$line;

	 }elsif($line=~ m/GI:/) {
	 $line=~ s/GI:\s*//;
	 $gi=$line;


	 	 
 }elsif($line=~ /^ACCESSION/) {
	 $line=~ s/^ACCESSION\s*//;
	 $accession=$line;


	 
	 
 }	 	   
}
}
#open(OUTFILE, ">GENBANK_PARSE1.txt");

#print "\nLOCUS:$locus:DEFINITION:$definition:ACCESSION:$accession:ORGANISM:$organism:DB_XREF:$db_xref";
print "GENE_ID";
print $geneID;
print "****";
print "GI_ID ****";
print $gi;
print "****";
print "ACCESSION ****";
print $accession;

#print "\n\n open GENBANK_PARSE1.txt to view results";
exit;	 