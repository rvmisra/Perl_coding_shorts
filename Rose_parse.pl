#!/usr/local/bin/perl
#Rose_parse
#Author: Raju Misra

use warnings;

my $chrom = 0;
my $pos = 0;
my $id = 0;
my $ref = 0;
my $alt = 0;
my $qual = 0;
my $ad1p = 0;
my $ad1c = 0;
my $ad2c = 0;
my $dp = 0;
my $Alt_ratio = ;
while(my $line = <>) {

chomp $line;
	
($chrom, $pos, $id, $ref, $alt, $qual, $ad1p, $dp) = split /\t/, $line;
($ad1c, $ad2c) = split /,/, $ad1p;
	
if (($pos > 10000) && ($pos < 50000)){	
$ALT_ratio = $ad2c/$dp;

print "FileName" . "\t" . "Chrom" . "\t" . "Pos" . "\t" . "ID" . "\t" . "REF" . "\t" . "ALT" . "\t" . "Qual" . "\t" . "ad1c" . "\t" . "AD" . "\t" . "DP". "\t" . "ALT_ratio";
print "\n";
print "$ARGV" . "\t" . "$chrom" . "\t" . "$pos" . "\t" . "$id" . "\t" . "$ref" . "\t" . "$alt" . "\t" . "$qual" . "\t" . "$ad1c" . "\t" . "$ad2c" . "\t" . "$dp" . "\t" . "$ALT_ratio";
print "\n";

	}

}



