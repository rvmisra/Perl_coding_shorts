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

my $querynumber = 0;

#Blastoutput
my $file1in = "K_pneumoniae_NCTC5056_Markers_vs_Inhouse_Db_50des_20al_output.txt";
#Blast parse : 100% id and qlen=aliglen
my $fileout1 = "parse_$file1in";
#Blast parse made non redundant
my $fileoutNR1 = "parse_NR_$file1in";
#Marker output Redundant
my $filecompout1 = "parseNR_marker_R_$file1in";
#Marker output NONRedundant
my $filecompout1NR = "parseNR_marker_NR_$file1in";


open PROTEINFILE, '<', $file1in or die "Cannot open file.txt: $!";
open(OUTFILE, ">$fileout1");

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
#################################################################################

open MYFILE, '<', $fileout1 or die "Cannot open file.txt: $!";

my %unique;


while ( <MYFILE> ) {

my ($c1, $c2, $c3, $c4, $c5, $c6, $c7) = split(/\t/);

    chomp;
        $unique{ "$c1\t" }++;

  
    
    }
close MYFILE;

open(OUTFILE, ">$fileoutNR1");

my @sorted = sort keys %unique;

my @sort;
for my $line ( @sorted ) {
    print OUTFILE "$line" . "\t" . "Querynumber_$querynumber++" ."\n";
    }
close OUTFILE;
######################################################################
######################################################################

#my ($file1, $file2, $file3) = qw(1.txt 2.txt 3.txt);

open my $fh1, '<', $file1in or die "Can't open $file1in: $!";
open my $fh2, '<', $fileoutNR1 or die "Can't open $fileoutNR1: $!";
open my $fh3, '>', $filecompout1 or die "Can't open $filecompout1: $!";

while (<$fh1>){
    last if eof($fh2);
    my $comp_line = <$fh2>;
    chomp($_, $comp_line);
    my @rec1 = split /\t/;
    my @rec2 = split /\t/, $comp_line;
    
    print $fh3 "$rec1[0]" . "\t" . "Querynumber_$querynumber++" . "\n" if $rec1[0] ne $rec2[0];
 
}

#################################################################################
#################################################################################

open MYFILE2, '<', $filecompout1 or die "Cannot open file.txt: $!";

my %unique2;


while ( <MYFILE2> ) {

my ($c12, $c22, $c32, $c42, $c52, $c62, $c72) = split(/\t/);

    chomp;
        $unique2{ "$c12\t" }++;

  
    
    }
close MYFILE2;

open(OUTFILE2, ">$filecompout1NR");

my @sorted2 = sort keys %unique2;

my @sort2;
for my $line2 ( @sorted2 ) {
    print OUTFILE2 "$line2" ."\n";
    }
close OUTFILE2;