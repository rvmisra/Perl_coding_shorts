#!/usr/bin/perl -w
#
#
#
#
use strict; 
my $origfile = 'xabi.txt'; 
my $outfile  = 'xabi2.txt'; 
my %hTmp;
 
open (IN, "<$origfile")  or die "Couldn't open input file: $!"; 
open (OUT, ">$outfile") or die "Couldn't open output file: $!"; 
 
while (my $sLine = <IN>) {
  print OUT $sLine unless ($hTmp{$sLine}++);
}
close OUT;
close IN;