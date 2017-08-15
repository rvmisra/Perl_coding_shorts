#!/usr/local/bin/perl
#line_cleaner1.pl
#Author: Raju Misra
#This script removes any line spaces between sequences i.e. strings
#and converts into one continuous string (sequence).


use warnings;
use strict;

#Prompt the user for the name of the file to read.
print "Enter the name of a protein sequence file Darren and then press Enter:\n";
my $fileToRead = <STDIN>;
chomp($fileToRead);
open (PROTEINFILE, $fileToRead) or die( "Cannot open file : $!" );


#open(OUTFILE, ">Line_cleanup_prots4.txt");

#regex to remove line spaces from the given file

while (my $sequenceEntry = <PROTEINFILE>) {

#$sequenceEntry =~ s/gb_[A-Z][0-9][0-9][0-9][0-9][0-9]//g;
#$sequenceEntry =~ s/emb_[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]//g;

#$sequenceEntry =~ s/\n/\n/g;
#$sequenceEntry =~ s/\r/\n/g;
#$sequenceEntry =~ s/\f/\n/g;


#$sequenceEntry =~ s/\W//g;

##############################################################
#removing_FASTA_header  ######################################
##############################################################
##############################################################
#$sequenceEntry =~ s/>.*/NNNNNNNNNN/g;
#$sequenceEntry =~ s/\n/NNNNNNNNNN/g;
#$sequenceEntry =~ s/,.*//g;

#$sequenceEntry =~ s/ /_/g;
###################################################################
#TIDY_16s_alignment_file
###################################################################
###################################################################
#$sequenceEntry =~ s/\;_.*//g;
#$sequenceEntry =~ s/\S[0-9]{9}_//g;
#$sequenceEntry =~ s/Yersinia/Y/g;
#$sequenceEntry =~ s/\"/_/g;
#$sequenceEntry =~ s/\;/_/g;
#$sequenceEntry =~ s/\./_/g;
#$sequenceEntry =~ s/\,/_/g;
#$sequenceEntry =~ s/\(/_/g;
#$sequenceEntry =~ s/\)/_/g;
#$sequenceEntry =~ s/\[/_/g;
#$sequenceEntry =~ s/\]/_/g;

###################################################################

#$sequenceEntry =~ s/ /_/g;

#$sequenceEntry =~ s/\//g;

	
#$sequenceEntry =~ s/>/>\n/g;

#$sequenceEntry =~ s/_c.*//g;
#$sequenceEntry =~ s/_[0-9].*//g;

#$sequenceEntry =~ s/[0-9]//g;

#$sid !~ /\_pestis_/

#$sequenceEntry !~ s/[A]//g;
#$sequenceEntry !~ s/[C]//gi;
#$sequenceEntry !~ s/[T]//gi;
#$sequenceEntry !~ s/[G]//gi;

#$sequenceEntry =~ s/[B]//gi;
#$sequenceEntry =~ s/[D-F]//gi;
#$sequenceEntry =~ s/[H-S]//gi;
#$sequenceEntry =~ s/[U-Z]//gi;

#$sequenceEntry =~ s/[L]//g;
#$sequenceEntry =~ s/[M]//g;
#$sequenceEntry =~ s/[N]//g;
#$sequenceEntry =~ s/[O]//g;
#$sequenceEntry =~ s/[P]//g;
#$sequenceEntry =~ s/[Q]//g;
#$sequenceEntry =~ s/[R]//g;
#$sequenceEntry =~ s/[S]//g;
#$sequenceEntry =~ s/[U]//g;
#$sequenceEntry =~ s/[V]//g;
#$sequenceEntry =~ s/[W]//g;
#$sequenceEntry =~ s/[X]//g;
#$sequenceEntry =~ s/[Y]//g;
#$sequenceEntry =~ s/[Z]//g;
	
#$sequenceEntry =~ s/\n//g;

#$sequenceEntry =~ s/>/\n>/g;
#$sequenceEntry =~ s/____/\n/g;
#$sequenceEntry =~ s/nseq_[0-9]*//g;

#$sequenceEntry =~ s/>/>strain_B_/g;	

#$sequenceEntry =~ s/[0]//g;	



#$sequenceEntry =~ s/ /_/g;
#$sequenceEntry =~ s/\'//g;
#$sequenceEntry =~ s/\"//g;

#$sequenceEntry =~ s/xxxx/2007-05-30/g;
#$sequenceEntry =~ s/\"NULL\"/NULL/g;
#$sequenceEntry =~ s/\(//g;
#$sequenceEntry =~ s/\)//g;
#$sequenceEntry =~ s/\[//g;
#$sequenceEntry =~ s/\]//g;

#$sequenceEntry =~ s/|||/|/g;
#$sequenceEntry =~ s/||/|/g;


#$sequenceEntry =~ s/B/>B/g;
#$sequenceEntry =~ s/\'Ames_Ancestor\'/Ames_Ancestor/g;
#$sequenceEntry =~ s/\'Ames Ancestor\'/Ames Ancestor/g;
#$sequenceEntry =~ s/children\'s/childrens/g;
#$sequenceEntry =~ s/Children\'s/Childrens/g;
#$sequenceEntry =~ s/5\'-/5/g;
#$sequenceEntry =~ s/5\' /5/g;
#$sequenceEntry =~ s/3\'-/3/g;
#$sequenceEntry =~ s/3\' /3/g;

#$sequenceEntry =~ s/\w\'s//g;
#$sequenceEntry =~ s/\'-/-/g;
#$sequenceEntry =~ s/\(\'//g;




#$sequenceEntry =~ s/gap_openings/gap_opening/g;
#$sequenceEntry =~ s/\"\"/\'/g;
#$sequenceEntry =~ s/\"INSERT/INSERT/g;
#$sequenceEntry =~ s/\)\;\"/\)\;/g;	
#$sequenceEntry =~ s/\"/\'/g;

#$sequenceEntry =~ s/amendement/amendment/g;


#$sequenceEntry =~ s/-\.//g;

#########Tidies MS seqs#############

#$sequenceEntry =~ s/\.[A-Z]//g;

#$sequenceEntry =~ s/^[K]\.//g;
#$sequenceEntry =~ s/^[R]\.//g;

#$sequenceEntry =~ s/\.[M]/M/g;
#$sequenceEntry =~ s/\.[A-Z]//g;
#$sequenceEntry =~ s/\.[A-Z]//g;

#########Tidies MS seqs#############
#$sequenceEntry =~ s/\*//g;
#$sequenceEntry =~ s/\@//g;
#$sequenceEntry =~ s/\#//g;
#$sequenceEntry =~ s/=//g;
#$sequenceEntry =~ s/-//g;
#$sequenceEntry =~ s/\$//g;
#$sequenceEntry =~ s/\^//g;
#$sequenceEntry =~ s/\~//g;
#$sequenceEntry =~ s/\+//g;

#$sequenceEntry =~ s/N//g
#$sequenceEntry =~ s/\|/_/g;
#$sequenceEntry =~ s/\.//g;
#$sequenceEntry =~ s/,/_/g;
#$sequenceEntry =~ s/\://g;
#$sequenceEntry =~ s/\;//g;
#$sequenceEntry =~ s/\[//g;
#$sequenceEntry =~ s/\]//g;
#$sequenceEntry =~ s/__/_/g;
#prints the 'cleaned file' to the output file 
#print OUTFILE ("$sequenceEntry");

print ("$sequenceEntry");


}                                                  
close (PROTEINFILE) or die( "Cannot close file : $!");
#close(OUTFILE) or die ("Cannot close file : $!");                                                                                                     
#print "Output in the file: Line_cleanup_prots4\n";
