#!/usr/local/bin/perl
#VF_class.pl
#This script counts the number of records a dataset has based upon gi accession numbers.  It then does a crude breakdown of the
# file based on the fasta description, counting the number of records which mathc one of the different virulence classes.
#NB. This script is very crude and is only meant to give a quick count of data and not a thorough analysis!
#Author: Raju Misra; October 2006

use warnings;
use strict;

#intialises the count, for counting the number of hits

my $count_capsule = 0;
my $count_flagella = 0;
my $count_taxis = 0;
my $count_sporulation = 0;
my $count_pilli = 0;
my $count_phage =0;
my $count_fimbr =0;
my $count_histidine =0;

#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">parse_results_SGvfs_count_strainA.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
################# capsule #################################
	if ($sequenceEntry =~ m/capsu/) {

#increments the counter
$count_capsule++
}

################# flagella #################################

if ($sequenceEntry =~ m/flag/) {

#increments the counter
$count_flagella++
}

################# taxis #################################

if ($sequenceEntry =~ m/taxis/) {

#increments the counter
$count_taxis++
}

################# sporulation #################################

if ($sequenceEntry =~ m/spor/) {

#increments the counter
$count_sporulation++
}

################# pilli #################################

if ($sequenceEntry =~ m/pill/) {

#increments the counter
$count_pilli++
}

################# phage #################################

if ($sequenceEntry =~ m/phag/) {

#increments the counter
$count_phage++
}


################# fimbrae #################################

if ($sequenceEntry =~ m/fimbr/) {

#increments the counter
$count_fimbr++
}


################# histidine #################################

if ($sequenceEntry =~ m/histidine/) {

#increments the counter
$count_histidine++
}

}
close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Total number of *capsule related prots* contained in the file *$count_capsule* times\n";
print OUTFILE "Total number of *flagella related prots* contained in the file *$count_flagella* times\n";
print OUTFILE "Total number of *taxis related prots* contained in the file *$count_taxis* times\n";
print OUTFILE "Total number of *spore related prots* contained in the file *$count_sporulation* times\n";
print OUTFILE "Total number of *pilli related proteins* contained in the file *$count_pilli* times\n";
print OUTFILE "Total number of *phage related proteins* contained in the file *$count_phage* times\n";
print OUTFILE "Total number of *fimbrae related proteins* contained in the file *$count_fimbr* times\n";
print OUTFILE "Total number of *histidine related proteins* contained in the file *$count_histidine* times\n";
close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "parse_results_SGvfs_count_strainA.txt.\n";