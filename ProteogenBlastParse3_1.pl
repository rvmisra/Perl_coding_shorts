#!/usr/local/bin/perl
#TblastN parse
#This script goes through the blast output where the qlen is included and 
#parses -> outfile 1, where pcid = 100% and qlen = alignlen
#it then goes through outfile 1 and makes it NR, writing to outfile 2.
#
#Author: Raju Misra

use warnings;
#use strict;

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

my $querynumber = 1;

my @Blastorig = [];
my @BlastparseNR = [];
######## BLAST PARSE ################ WORKS!

#Blastoutput > INPUT FILE NAME HERE
my $file1in = "A2916_rep1_merge_tab_vs_NR_50des_20al_output.txt";

#Blast parse : 100% id and qlen=aliglen
my $fileout1 = "Parse_$file1in";

#Blast parse made non redundant
my $fileoutNR1 = "PARSE_NR_$file1in";


############# SETUP QUERY FILE #########

#Blast query files made non redundant
my $fileoutQUERY1 = "Query_$file1in";
my $fileoutQUERYNR1 = "QUERY_NR_$file1in";

######## MARKERS ##########################

#Marker output Redundant
my $filecompout1 = "parseNR_marker_R_$file1in";

#Marker output NONRedundant
my $filecompout1NR = "parseNR_marker_NR_$file1in";

############# PART 1 ################################
#####################################################
##############BLAST PARSE#############################

open PROTEINFILE, '<', $file1in or die "Cannot open file.txt: $!"; #$file1in
open(OUTFILE, ">$fileout1"); #my $fileout1 = "Parse_$file1in"

while (my $line = <PROTEINFILE>) {
chomp $line;

($AA, $BB, $CC, $DD, $EE, $FF, $GG, $HH, $II, $JJ, $KK, $LL, $MM, $NN) = split /\t/, $line;


if (($DD =~ /$MM/) && ($CC =~ /100/)) {

print OUTFILE "$AA" . "\t" . "$BB" . "\t" . "$CC" . "\t" . "$DD" . "\t" . "$LL" . "\t" . "$MM" . "\n";

}

}

close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");

#################################################################################
##################BLAST PARSE MADE NON REDUNDANT ################################

open MYFILE, '<', $fileout1 or die "Cannot open file.txt: $!"; #my $fileout1 = "Parse_$file1in"

my %unique;


while ( <MYFILE> ) {

my ($c1, $c2, $c3, $c4, $c5, $c6, $c7) = split(/\t/);

    chomp;
        $unique{ "$c1\t" }++;

            
    }
close MYFILE;

open(OUTFILE, ">$fileoutNR1"); #my $fileoutNR1 = "PARSE_NR_$file1in";

my @sorted = sort keys %unique;

my @sort;
for my $line ( @sorted ) {
    print OUTFILE $line . "\n";
    }
close OUTFILE;


###################################################
######## FOR COMPARISON ############################
########need to make query file from blast output NR
####################################################
# QUERY QUERY QUERY QUERY QUERY 
#####################################################
##############BLAST PARSE#############################

open PROTEINFILE, '<', $file1in or die "Cannot open file.txt: $!"; #$file1in
open(OUTFILE, ">$fileoutQUERY1"); #my $fileoutQUERY1 = "Query_$file1in";

while (my $line = <PROTEINFILE>) {
chomp $line;

	
($AA, $BB, $CC, $DD, $EE, $FF, $GG, $HH, $II, $JJ, $KK, $LL, $MM, $NN) = split /\t/, $line;


print OUTFILE "$AA" . "\t" . "$BB" . "\t" . "$CC" . "\t" . "$DD" . "\t" . "$LL" . "\t" . "$MM" . "\n";

}



close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");

#################################################################################
##################BLAST PARSE MADE NON REDUNDANT ################################

open MYFILE2, '<', $fileoutQUERY1 or die "Cannot open file.txt: $!"; #my $fileoutQUERY1 = "Query_$file1in";

my %unique2;


while ( <MYFILE2> ) {

my ($c1, $c2, $c3, $c4, $c5, $c6, $c7) = split(/\t/);

    chomp;
        $unique2{ "$c1\t" }++;

            
    }
close MYFILE2;

open(OUTFILE2, ">$fileoutQUERYNR1"); #my $fileoutQUERYNR1 = "QUERY_NR_$file1in";

my @sorted2 = sort keys %unique2;

my @sort2;
for my $line2 ( @sorted2 ) {
    print OUTFILE2 $line2 . "\n";
    }
close OUTFILE2;

##############  COMPARISON HERE #################################
##############  PERL version of vlookup #########################

### MAKE BOTH FILES TAB SEPERATED ie. xxxx@yyyy to xxxxx	yyyyyy
#Use that for the input into file compare program
