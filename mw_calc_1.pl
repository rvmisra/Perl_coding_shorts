#!/usr/bin/perl
#MW_calculator
#
#Written by Raju Misra HPA

#!/usr/bin/perl


use Getopt::Std;

our ($opt_f, $opt_r);
getopts('fr');


#variable


#asks for filename
print "file name? ";
chomp($input1 = <STDIN>)  || die "cannot open: $!";

#opens file
open(INFILE, "$input1");

#countchar
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


	


#if ($myfile = A) {
#$mw = 89.09 * $myfile;;
#}
 close INFILE;
 
#creates output file 
 open OUTFILE, ">answer1.txt";

#writes to the output file
 print OUTFILE "Dec\tHex\tCour\tLegacy\tCount\n";
for $i (@list) {
	$c = chr($i);
	if ($count[$i]) {
		printf "%3d\tx%04X\t$c\t$c\t%5g\n", $i, $i, $count[$i];
		}
	}
 close OUTFILE;
