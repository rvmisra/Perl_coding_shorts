#!/usr/bin/perl

#variable
$pi = 3.14;

#asks for filename
print "file name? ";
chomp($input1 = <STDIN>)  || die "cannot open: $!";

#opens file
 open(INFILE, "$input1");
 

#reads file one line at a time 
 while ( <INFILE> )
{
  $myfile = $myfile . $_;
}

#calculation
$circ = 2 * $pi * $myfile;

if ($myfile < 0) {
	$circ = 0;
}
 close INFILE;
 
#creates output file 
 open OUTFILE, ">answer1.txt";

#writes to the output file
 print OUTFILE "circ is $circ.\n";
 close OUTFILE;
