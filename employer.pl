#!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Raju Misra

use warnings;
use strict;

#open the employeesfile
open (EMPLOYEES,"employees.txt");

#for each line
while ($line =) {

#remove thecarriage return
chomp $line;

#split the linebetween tabs
#and get thedifferent elements
($name,$department, $salary) = split /\t/, $line;

#go to the nextline unless the name starts with "Mr "
next unless$name =~ /^Mr /;

#go to the nextline unless the salary is more than 25000.
next unless$salary > 25000;

#go to the nextline unless the department is R&D.
next unless$department eq "R&D";

#since allemployees here are male,
#remove theparticle in front of their name
$name =~ s/Mr//;

print"$name\n";
}
close (EMPLOYEES);
