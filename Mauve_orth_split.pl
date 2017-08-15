#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

#my $a = 0;
#my $b = 0;
#my $c = 0;
#my $d = 0;
#my $e = 0;
#my $f = 0;
#my $g = 0;
#my $h = 0;
#my $i = 0;
#my $j = 0; 
#my $k = 0;
#my $l = 0; 
#my $m = 0;
#my $n = 0;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file (try proteins.txt) and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );

open(OUTFILE, ">Line_cleanup_prots4.txt");
while (my $line = <PROTEINFILE>) {
chomp $line;
	
#($a, $b, $c, $d, $e, $f, $g, $h, $i, $j, $k, $l, $m, $n) = split /\t/, $line;


if (($line !~ /0\:CD/g) && ($line !~ /1\:b/g) && ($line !~ /2\:\:/g) && ($line !~ /12\:M120/g) && ($line !~ /13\:Q23m63/g) && ($line =~ /3\:CDR20291/g) && ($line =~ /4\:\:/g) && ($line !~ /5\:CD196/g) && ($line =~ /6\:Q66c26/g) && ($line =~ /7\:q76w55/g) && ($line =~ /8\:q97b34/g) && ($line =~ /9\:855/g) && ($line =~ /10\:855/g)  && ($line =~ /11\:Q32g58/g)){


#print OUTFILE "$query£$subject£$percent_id£$alignment_length£$mismatches£$gap_openings£$q_start£$q_end£$s_start£$s_end£$e_value£$bit_score\n";
print OUTFILE ("$line\n");

}
}
close(OUTFILE) or die ("Cannot close file : $!");  
close (PROTEINFILE) or die( "Cannot close file : $!");
                      