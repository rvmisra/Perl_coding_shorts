#!/usr/bin/perl
#Parses Mascot dat files, not that it does NOT remove redundancies.
#Output is a list of peptide sequences greater than the score listed, default = 20
	
use warnings;
use strict;

my $MASCOT;
my $mascot;
my $mascot_parsed;
my $mascot_parsed_two;
my $two;
my $one;
my $three;
my $peptide;
my $five;
my $six;
my $score;
my $eight;
my $nine;
my $ten;
my $count = 1;


#Prompt the user for the name of the file to read.
open MYFILE, '<', 'Genprot_541_R3.dat' or die "Cannot open file.txt: $!";


	while (my $mascot = <MYFILE>) {
		
 if($mascot=~s/q[0-9]+_p[0-9]+=[0-9]+,//g){
                $mascot_parsed = $mascot;
        if($mascot_parsed=~s/;\".*//g){
                $mascot_parsed_two = $mascot_parsed;	
	chomp ($mascot_parsed_two);
		($one, $two, $three, $peptide, $five, $six, $score, $eight, $nine, $ten) = split /,/, $mascot_parsed_two;        
		if ($score > 20){
				
		print ">Genprot_541_R3_" . $count++ . "@" . "$peptide" . "\n" . "$peptide\n";												  
	
			
										     }
	}
}
}



close MYFILE;