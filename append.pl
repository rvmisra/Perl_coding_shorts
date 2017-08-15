#!/usr/bin/perl -w
# Script for combining multiple dat files with
# a delimiter blank/new line
# combine.pl ver 0.99b Nov 24 2004
# Nirav Merchant nirav@arl.arizona.edu
# Needs activstate perl on PC
# modification history
#     9/28/05 Tim Radabaugh 1. added code so that $out gets closed
#                           2. added code to rename output file to .dta file
#
# append.pl ver 1.0b March 2005 
# added file name to first line of spectra
# combined features from both previous versions
# Paul Haynes 11/10/05
# append.pl version 1.10b

use strict;
use Getopt::Long;



my $usage = "\n Usage: \n\n $0 -i filename-mask -o outputfile\n\n e.g. $0 -i *.dta -o big \n 
(i.e. no need to add the .dta suffix to the output filename) \n";
# option variable with default value
my ($in,$out,$count,$cmd,$temp);

GetOptions ('i=s' => \$in, 'o=s' => \$out   );
if (!$in and !$out) { print "$usage";
                      exit;
}
if (-e $out) {
print "Output file $out already exists, please use different name\n";
exit;
              } else {
open(FH,">$out") or die "Cannot open $out\n";
              }
              
my @files = glob("$in");
$count = scalar(@files);
print "Appending $count file to $out\n";
foreach my $f (@files) {
open(IN,$f) or warn "Cannot open $f\n";
# Print file name as part of first line
my $line = <IN>;
chomp($line);
print FH $line." ".$f."\n";
while(<IN>) { print FH $_; }
print FH "\n";
close(IN);
}
close (FH);


if (index($out, ".txt", 0) != -1) {
  $temp = substr($out, 0, index($out, ".txt", 0));
}
else {
  $temp = $out;
}

$cmd="rename $out $temp".".dta";
print `$cmd`;



print "\nFinished append $count files to $temp.dta\n";

