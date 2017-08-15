#!/usr/local/bin/perl
#TblastN parse
#This script goes through the blast output where the qlen is included and 
#parses -> outfile 1, where pcid = 100% and qlen = alignlen
#it then goes through outfile 1 and makes it NR, writing to outfile 2.
#
#Author: Raju Misra

use warnings;
use strict;

my $AA = 0;
my $BB = 0;
my $CC = 0;
my $DD = 0;
my $EE = 0;
my $FF = 0;
my $GG = 0;
my $HH = 0;
my $II = 0;
my $JJ = 0;
my $KK = 0;
my $LL = 0;
my $MM = 0;
my $NN = 0;


#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">TblastN_parse_541R3.txt");

while (my $line = <PROTEINFILE>) {
chomp $line;

	
($AA, $BB, $CC, $DD, $EE, $FF, $GG, $HH, $II, $JJ, $KK, $LL, $MM, $NN) = split /\t/, $line;


if (($DD = $MM) && ($CC = 100)) {

print OUTFILE "$AA" . "\t" . "$BB" . "\t" . "$CC" . "\t" . "$DD" . "\t" . "$LL" . "\t" . "$MM" . "\n";

}

}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");

#################################################################################
#################################################################################

open MYFILE, '<', 'TblastN_parse_541R3.txt' or die "Cannot open file.txt: $!";

my %unique;


while ( <MYFILE> ) {

my ($c1, $c2, $c3, $c4, $c5, $c6, $c7) = split(/\t/);

    chomp;
        $unique{ "$c1\t" }++;

  
    
    }
close MYFILE;

open(OUTFILE, ">TblastN_parse_541R3_NR.txt");

my @sorted = sort keys %unique;

 
my @sort;
for my $line ( @sorted ) {
    print OUTFILE "$line" . "\n";
    }

