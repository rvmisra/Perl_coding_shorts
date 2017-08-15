#!/usr/local/bin/perl
#ProteogenBlastParse1_1.pl
#This script creates the marker list from the blast output, where the query number
#has been added to the end!
#
#March 2012
#Author: Raju Misra

use warnings;
use strict;

#Define Variables
#Blast tab split variables
my $AA = 0; #Query
my $BB = 0; #Reference
my $CC = 0; #Percentage id
my $DD = 0; #Alignment length
my $EE = 0;
my $FF = 0;
my $GG = 0;
my $HH = 0;
my $II = 0;
my $JJ = 0;
my $KK = 0; #Bit score
my $LL = 0; #Evalue
my $MM = 0; #Query length
my $NN = 0; #Spare tab, incase of extra tab
my $querynumber = 1;
my @Blastorig = [];
my @BlastparseNR = [];

#*********************************************************************************************
# FASTA header name
my $FASTAhead = "Serratia_marcescens_NCTC1377";  #<--INPUT MARKER FASTA HEADER BETWEEN QUOTE MARKS
#*********************************************************************************************

#*********************************************************************************************
#Blastoutput > INPUT FILE NAME HERE
my $file1in = "S_marcescens_NCTC1377_merge_tab_vs_NR_50des_20al_output.txt"; #<-- INPUT BLAST FILE HERE
#*********************************************************************************************

#*********************************************************************************************
#SET SPECIES OF INTEREST: Between quote marks
my $Speciesofinterest = "serratia marcescens"; #<--INPUT SPECIES OF INTEREST HERE
#*********************************************************************************************

#Blast parse : 100% id and qlen=aliglen
my $fileout1 = "Parse_$file1in";

#Blast parse made non redundant
my $fileoutNR1 = "PARSE_NR_$file1in";


############# SETUP QUERY FILE #########

#Blast query file created from Blast output file
my $fileoutQUERY1 = "Query_$file1in";

#Blast query file created from Blast output file, made non-redundant
my $fileoutQUERYNR1 = "QUERY_NR_$file1in";

######## MARKERS ##########################

#Marker output Non-redundant as the input files (query and blast parsed) were NR.
my $filecompout1 = "MARKER_NR_candidate_$file1in";


########################################################## 
########					PART 1                       #  
########       Blast PARSE querylength = align length    #
########					   &                         #
########		Percentage identity = 100%               #
##########################################################


#Blast input file - opened here
open PROTEINFILE, '<', $file1in or die "Cannot open file.txt: $!"; #$file1in

#Output from Blast parse will be written to here
open(OUTFILE, ">$fileout1"); # --> variable defined as: Parse_$file1in"

#Loop through Blast input file
while (my $line = <PROTEINFILE>) {
chomp $line;
#Split blast output file by the tab
($AA, $BB, $CC, $DD, $EE, $FF, $GG, $HH, $II, $JJ, $KK, $LL, $MM, $NN) = split /\t/, $line;

#Select all those rows of data which has 100% Pcid and 
#the query length = alignment length

if (($DD =~ /$MM/) && ($CC =~ /100/) && ($BB !~ /$Speciesofinterest/gi)) {

#Print to outfile: Query (AA), Reference (BB), PCID (CC), align length (DD), Evalue (LL) and Query length (MM)	
print OUTFILE "$AA" . "\t" . "$BB" . "\t" . "$CC" . "\t" . "$DD" . "\t" . "$LL" . "\t" . "$MM" . "\n";


		} #Close if loop
   }#Close while loop

#Close Input blastfile and output file
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");

#################################################################################
#              BLAST PARSE MADE NON REDUNDANT     								#
#################################################################################

#Open blast parsed output file
open MYFILE, '<', $fileout1 or die "Cannot open file.txt: $!"; # --> Parse_$file1in

#Initialise hash
my %unique;

#Loop through input file
while ( <MYFILE> ) {

#Split the Blast parsed file by the tab
	
my ($c1, $c2, $c3, $c4, $c5, $c6, $c7) = split(/\t/);

    chomp;
#Add contents of col1 i.e. query into a hash as a key value increments by 1
    
        $unique{ "$c1\t" }++;
           
    }
close MYFILE;

#Opens outfile
open(OUTFILE, ">$fileoutNR1"); # -->PARSE_NR_$file1in

#Put the sorted col1 keys into an array - this removes duplicates
my @sorted = sort keys %unique;
#Loop through array of sorted keys and declare them as a new variable, which can called upon
#printing
for my $line ( @sorted ) {
    print OUTFILE $line . "\n";
    }
close OUTFILE;


###################################################################################
#                 Part 2                                                          #
#Make the query file NR, based on Blast output file                               #
#Using Blast query as all queries will be used for blast search, queries based on #
#MS/MS DB search, which is DB dependent. That is, only mathches that are in the DB#
#will be printed.  MS/MS searches don't denovo sequence.                          #
###################################################################################

#Open blast output file
open PROTEINFILE, '<', $file1in or die "Cannot open file.txt: $!"; # --> $file1in
#Open output file for redundant list of queries
open(OUTFILE, ">$fileoutQUERY1"); # --> Query_$file1in

#Loop through Blast output file (opened input file)
while (my $line = <PROTEINFILE>) {
chomp $line;

#Split blast output file by the tab
($AA, $BB, $CC, $DD, $EE, $FF, $GG, $HH, $II, $JJ, $KK, $LL, $MM, $NN) = split /\t/, $line;

#Print to outfile: Query (AA), Reference (BB), PCID (CC), align length (DD), Evalue (LL) and Query length (MM)	

print OUTFILE "$AA" . "\t" . "$BB" . "\t" . "$CC" . "\t" . "$DD" . "\t" . "$LL" . "\t" . "$MM" . "\n";

}

#Close input and output file
close (PROTEINFILE) or die( "Cannot close file : $!");
close(OUTFILE) or die ("Cannot close file : $!");

#################################################################################
#         Blast output file - used for queries is made non-redundant            #
#################################################################################

#Open query file from section above
open MYFILE2, '<', $fileoutQUERY1 or die "Cannot open file.txt: $!"; # --> Query_$file1in

#Initialise hash
my %unique2;

#Loop through file
while ( <MYFILE2> ) {
#Split blast parsed file by tab
my ($c1, $c2, $c3, $c4, $c5, $c6, $c7) = split(/\t/);

    chomp;
#Add contents of col1 i.e. query into a hash as a key value increments by 1
        $unique2{ "$c1\t" }++;

            
    }
close MYFILE2;

#Open output file - NR query list to be written to

open(OUTFILE2, ">$fileoutQUERYNR1"); #my $fileoutQUERYNR1 = "QUERY_NR_$file1in";

#Put the sorted col1 keys into an array - this removes duplicates
my @sorted2 = sort keys %unique2;

#Loop through array of sorted keys and declare them as a new variable, which can called upon
#printing
for my $line2 ( @sorted2 ) {
    print OUTFILE2 $line2 . "\n";
    }
close OUTFILE2;

###########################################################################
# Comparison of Query file (from Blast) vs. Blast parse (100pcid & ql=al) #
#               PERL version of vlookup                                   #
###########################################################################


### OPEN FILE ####
#The query list#
open (GENOME, "$fileoutQUERYNR1") ||  die $!; # -> Query list made NR

#initialise hash #####

my %hash;

#### loop through the file ####
while (my $line = <GENOME> ) {
	   chomp($line);
	   
	    
#### split a tab seperated text file, 2 columns, by the @ sign (as used in query file for blast)
#into two variables	   
 
      (my $word1,my $word2) = split /@/, $line;
	   
#### convert col1 into the hash key (word1) and col2 into the hash value (word2) #####       
       $hash{$word1} = $word2;
	 
	   }
###### test if you can read and that everything is in the hash as expected ######
#while ( my ($k,$v) = each %hash ) {
#    print "Key $k => value $v\n";
#}    
close GENOME;  

########################################################################################
# The blast output. Shorter list to compare with. Blast parse (100pcid & ql =al) file  #
########################################################################################

open (GENOME2, "$fileoutNR1") ||  die $!; # -> Blastparse NR file
my %hash2;
while (my $line2 = <GENOME2> ) {
	   chomp($line2);
       (my $word12,my $word22) = split /@/, $line2;
	   $hash2{$word12} = $word22;
	 
	   }
# Print hash for testinf purposes
#while ( my ($k2,$v2) = each %hash2 ) {
#    print "Key2 $k2 => value2 $v2\n";
#}    
close GENOME2;  

#################################################################################
#Initialise count for printing fasta name
my $count_N = 1;

#Open output file to write marker list to
open(MARKEROUTFILE, ">$filecompout1");

#Reverses hash2, the blastparse nr list
my %reversed_hash2 = reverse %hash2;
#Using grep write to array if the value in the query list does not match
#the reversed hash (blastparse list)... Need to explain better!!
my @missing = grep ! exists $reversed_hash2{ $_ }, values %hash;

#Loop through array, for each value init i.e. the marker print out
foreach (@missing) {

	#Fasta header_count_@_sequence
	print MARKEROUTFILE ">$FASTAhead" . "_" .  $count_N++ . "@" . $_;
    print MARKEROUTFILE "\n"; #Print new line
	print MARKEROUTFILE "$_\n"; #Print sequence here
}
close MARKEROUTFILE;