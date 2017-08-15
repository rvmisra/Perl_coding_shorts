#!/usr/local/bin/perl
#parse_unique.pl
#Author: Raju Misra

use warnings;
use strict;


my $data = ();
my %uniq_data= ();
my @uniq = ();
my $item = ();
my @list = ();
my $uniq_data= ();

print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);

open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">BA_blast_parse_UNIQUE_query_ID_only.txt");

$data=<PROTEINFILE>;
%uniq_data=$data;

@list = %uniq_data;

    print @list;    
    



#foreach $item (@list) {
#    unless ($seen{$item}) {
        # if we get here, we have not seen it before
#        $seen{$item} = 1;
 #       push(@uniq, $item);
  #  }
#}
  #}
       

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
#print "Output in the file: BA_blast_parse_UNIQUE_query_ID_only.txt\n";