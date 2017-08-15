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
my $locus ='';
my $accession='';
my $organism='';
my $locus_tag='';
my $definition='';
my $db_xref='';
my $flag =0;

#get genbank file data
@genbank = get_file_data('196.gbk');

#let's startwith something simple.  Lets get some of the identifying information:locus & accession number & defintiton

for my $line (@genbank) {

		
 if($line =~ /^LOCUS/) {
	 $line=~ s/^LOCUS\s*//;
	 $locus=$line;
	 
 }elsif($line=~ /^DEFINITION/) {
	 $line=~ s/^DEFINITION\s*//;
	 $definition=$line;
	 $flag =1;

 }elsif($line=~ /^ACCESSION/) {
	 $line=~ s/^ACCESSION\s*//;
	 $accession=$line;
	 $flag =0;

	 	 	 
 }elsif($line=~ /^ORGANISM/) {
	 $line=~ s/^ORGANISM\s*//;
	 $organism=$line;
	 
  }elsif($line=~ /^\/locus_tag=/) {
	 $line=~ s/^\/locus_tag=\s*//;
	 $locus_tag=$line;
	 	
  }	 
 }	 	   


#open(OUTFILE, ">GENBANK_PARSE1.txt");

print "\nLOCUS:$locus:DEFINITION:$definition:ACCESSION:$accession:ORGANISM:$organism:LOCUS_TAG:$locus_tag";
print "\nLOCUSTA$locus_tag";
#print OUTFILE  "****";
#print OUTFILE  "DEFINITION ****";
#print OUTFILE  $definition;
#print OUTFILE  "****";
#print OUTFILE  "ACCESSION ****";
#print OUTFILE  $accession;
#print OUTFILE  "****";
#print OUTFILE  "ORGANISM****";
#print OUTFILE  $organism;
#print OUTFILE  "****";

#print "\n\n open GENBANK_PARSE1.txt to view results";
exit;	 