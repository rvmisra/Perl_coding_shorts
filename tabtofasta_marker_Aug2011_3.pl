#!/usr/bin/perl -w
#Author Raju Misra
#tab input


open (GENOME, "mix1.txt") ||  die $!;
open(OUTFILE, ">Line_cleanup_prots1.txt");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <GENOME>) {
chomp ($sequenceEntry);
$sequenceEntry =~ s/\*/@/g;

#prints the 'cleaned file' to the output file 
print OUTFILE $sequenceEntry;
print OUTFILE "\n";
}                                                  
close (GENOME) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");

##########################################################################

open (GENOME2, "Line_cleanup_prots1.txt") ||  die $!;
open(OUTFILE2, ">E_hermannii_candy_markers2.fasta");
while ( <GENOME2> ) {
chomp;
#split the loci information file, into 3 columns	
my ($Fastahead, $seq, $length, $X) = split(/@/);

print OUTFILE2 ">" . $Fastahead . "@" . $seq . "@" . $length;
print OUTFILE2 "\n";
print OUTFILE2 "$seq";
print OUTFILE2 "\n";

}
	
close (GENOME2) or die( "Cannot close file : $!");
close(OUTFILE2) or die ("Cannot close file : $!");
##################################################################################


#intialises the count, for counting the number of hits
my $count_marker = 0;

open (GENOME3, "E_hermannii_candy_markers2.fasta") ||  die $!;

while (my $sequenceEntry3 = <GENOME3>) {
chomp ($sequenceEntry3);

if ($sequenceEntry3 =~ m/>/) {$count_marker++}
}

close (GENOME3) or die( "Cannot close file : $!");

#prints the final word count

print "Total number of markers: $count_marker";
