#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;

my $filein_A = "columA.txt";
my $filein_B = "columnB.txt";



open (file_to_write_A,$filein_A) or die "Can't open the file!";
@fileinput_A = <file_to_write_A>;

open (file_to_write_B,$filein_B) or die "Can't open the file!";
@fileinput_B = <file_to_write_B>;


if (@fileinput_A != @fileinput_B) {

print @fileinput_B;
}
close (file_to_write_A);
close (file_to_write_B);


