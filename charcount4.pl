#!/usr/bin/perl

# MakeCharList.pl

our $Version = "3.0";	# 2005-10-15 bh
#	Added -f and -r options


use Getopt::Std;

our ($opt_f, $opt_r);
getopts('fr');

die <<"eof" unless $#ARGV >= 0;
Usage:
    MakeCharList.pl [-f] [-r]  infile > outfile


-f sort by frequency

-r reverse sort order

Version $Version
eof

while ($line = <>) {
	chomp $line;
	@chars = split(//, $line);
	for ($i=0; $i<=$#chars; $i++) {
		$count[ord($chars[$i])]++;
		}
	}

my @list = (0 .. 255);
@list = sort {$count[$a] <=> $count[$b]} @list if $opt_f;
@list = reverse @list if $opt_r;

print "Dec\tHex\tCour\tLegacy\tCount\n";
for $i (@list) {
	$c = chr($i);
	if ($count[$i]) {
		printf "%3d\tx%04X\t$c\t$c\t%5g\n", $i, $i, $count[$i];
		}
	}
	
