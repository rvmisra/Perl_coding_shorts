################################################################################################################
#Written by Raju Misra, perl script to go through a tab seperated text file e.g.
#Data written: 07/04/09
#Col1    col2    col3
#Col1    col2_1    col3
#Col1    col2_1    col3
#Col1    col2_2    col3_1
#Col1    col2    col3_2
#To fine the unique strings from the first 2 columns only, so that the result will look like:
#Col1    col2
#        col2_1
#        col2_2
#
#It takes a tab file, splits it using the tab as the delimeter, puts each new column as a new var, from which
#it goes through each line 1 by 1, stores in the hash unique1 & unique 2, then using the hash sort command, pulls
#out the unique strings - as hash keys have to be unqiue.
##################################################################################################################

#!/usr/local/bin/perl
use warnings;
use strict;
open MYFILE, '<', 'test1.txt' or die "Cannot open file.txt: $!";

my %unique;
my %unique2;

while ( <MYFILE> ) {

my ($c1, $c2, $c3) = split(/\t/);

    chomp;
        $unique{ "$c1\t" }++;  # updated!

    chomp;
        $unique2{ "$c2\t" }++;  # updated!
    
    }
close MYFILE;

my @sorted = sort keys %unique;
my @sorted2 = sort keys %unique2;
 
my @sort;
for my $line ( @sorted ) {
    print "$line";
    }

my @sort2;
for my $line2 ( @sorted2 ) {
    print "$line2\n\t";
    }
