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
my $gene =0;
my $product =0;
my $locustag = 0;
my $CDS = 0;

#get genbank file data
#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );
open(OUTFILE, ">GENBANK_PARSE1.txt");
while (my $line = <PROTEINFILE>) {

		
 if($line =~ /^LOCUS/) {
$line=~ s/^LOCUS\s*//;
	 $locus=$line;
	 
	 
 }elsif($line=~ /^DEFINITION/) {
	 $line=~ s/^DEFINITION\s*//;
	 $definition=$line;
	 
 }elsif($line=~ /^ACCESSION/) {
	 $line=~ s/^ACCESSION\s*//;
	 $accession=$line;
 
 }elsif($line=~ /\/locus_tag=/) {
     $line=~ s/\s*//;
	 $locustag = $line;
	 print OUTFILE $locustag;
     
 }elsif($line=~ /\/gene=/) {
	 $line=~ s/\s*//;
	 $gene = $line;
	 print OUTFILE $gene;

 }elsif($line=~ /\/product=/) {
	 $line=~ s/\s*//;
	 $product = $line;
	 print OUTFILE $product;
	 print OUTFILE "£"; 	 	 	 	
 
#}elsif($line=~ /^CDS/) {
#     $line=~ s/^CDS\s*//;
#	 $CDS = $line;
#	 print OUTFILE $CDS;
 
 }	 
 }	 	   




#print "LOCUS:$locus:DEFINITION:$definition:ACCESSION:$accession:ORGANISM:$organism:LOCUS_TAG:$locus_tag";
#print "\n$locustag";
#print "$gene";
#print "$product\n";

close (PROTEINFILE) or die( "Cannot close file : $!");
close (OUTFILE) or die( "Cannot close file : $!");