#!/usr/local/bin/perl
#testparse2.pl
#Author: Raju Misra

use warnings;
use strict;

#user input for the word to search for
#print "word to lool for: ";
#my $wordtoread = <STDIN>;


#my $word = $wordtoread;
#chomp($word);

#intialises the count, for counting the number of hits
my $count_gi = 0;
my $count_transp = 0;
my $count_ABC = 0;
my $count_drug = 0;
my $count_adhes = 0;
my $count_hypoth = 0;
my $count_toxin = 0;
my $count_flag = 0;
my $count_protea = 0;
my $count_motil = 0;


#Prompt the user for the name of the file to read.
print "Enter the filename and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (INFILE, $fileToRead) or die( "Cannot open file : $!" );

#opns the output file
open(OUTFILE, ">parse_results_BAA_1.txt");
while (my $sequenceEntry = <INFILE>) {

#the magic: goes through the output file, if the word to be searched for is found it
#counts it.
################# gi count #################################
	if ($sequenceEntry =~ m/gi/) {

#increments the counter
$count_gi++
}

################# transp count #################################

if ($sequenceEntry =~ m/transp/) {

#increments the counter
$count_transp++
}

################# ABC trans count #################################

if ($sequenceEntry =~ m/abc/) {

#increments the counter
$count_ABC++
}

################# drug count #################################

if ($sequenceEntry =~ m/drug/) {

#increments the counter
$count_drug++
}

################# adhesion count #################################

if ($sequenceEntry =~ m/adhes/) {

#increments the counter
$count_adhes++
}

################# hypothothetical count #################################

if ($sequenceEntry =~ m/hypoth/) {

#increments the counter
$count_hypoth++
}

################# toxin count #################################

if ($sequenceEntry =~ m/toxin/) {

#increments the counter
$count_toxin++
}

################# flagella count #################################

if ($sequenceEntry =~ m/flag/) {

#increments the counter
$count_flag++
}

################# proteases count #################################

if ($sequenceEntry =~ m/protea/) {

#increments the counter
$count_protea++
}

################# motility count #################################

if ($sequenceEntry =~ m/motil/) {

#increments the counter
$count_motil++
}


}
close (INFILE) or die( "Cannot close file : $!");

#prints the final word count
print OUTFILE "Total number of records contained in the file = $count_gi\n\n";
print OUTFILE "Total number of *transporters* contained in the file *$count_transp* times\n";
print OUTFILE "Total number of *ABC related transporters* contained in the file *$count_ABC* times\n";
print OUTFILE "Total number of *drug related proteins* contained in the file *$count_drug* times\n";
print OUTFILE "Total number of *adhesion related proteins* contained in the file *$count_adhes* times\n";
print OUTFILE "Total number of *hyphothetical proteins* contained in the file *$count_hypoth* times\n";
print OUTFILE "Total number of *toxin related proteins* contained in the file *$count_toxin* times\n";
print OUTFILE "Total number of *flagella related proteins* contained in the file *$count_flag* times\n";
print OUTFILE "Total number of *protease related proteins* contained in the file *$count_protea* times\n";
print OUTFILE "Total number of *motility related proteins* contained in the file *$count_motil* times\n";

close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
print "Open parse_results_BAA_1.txt.\n";