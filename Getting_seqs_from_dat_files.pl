#!/usr/bin/perl
#This program parses out MASCOT .dat files and outputs the peptide sequence with a score cut-off set below.
#Author: Ali Al-Shahib

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
my $result;
my @peptide;
my $seen;
my $promptString;
my $defaultValue;
my $user_score;
my $dam;
my $required_score;
my $raw;
my $x = 0;
my $mascot_one;
my $mascot_two;
my $mascot_three;
my @lines;
my $line;
my @mascots;
my @results;
my @label;
my $label;
my $protein;

	
	my $fileToRead = <STDIN>;
	chomp($fileToRead);
	open (MASCOT, $fileToRead) or die( "Cannot open file : $!" );
	
	while ($mascot = <MASCOT>) {
                chomp($mascot);
	if($mascot=~/FILE=/g){
		$mascot_one = $mascot;
	if ($mascot_one=~s/FILE=[A-Z]:\\.*\\.*\\//g){  
		$mascot_two = $mascot_one;
	if ($mascot_two=~s/.RAW//g){
                $mascot_three = $mascot_two; #Name fo RAW files
	}
	}
	}
        elsif($mascot=~s/q[0-9]+_p[0-9]+=[0-9]+,//g){
                $mascot_parsed = $mascot;
        if($mascot_parsed=~s/;".*//g){
                $mascot_parsed_two = $mascot_parsed;	
	chomp ($mascot_parsed_two);
		($one, $two, $three, $peptide, $five, $six, $score, $eight, $nine, $ten) = split /,/, $mascot_parsed_two;        
		if ($score > 20){
		push @results, "$mascot_three,$peptide";
        }

		}

	}

}
	my %seen = ();
	foreach $result (@results) {
			($mascot_three,$peptide)= split /,/, $result;
    		unless ($seen{$peptide}) {
        		# if we get here, we have not seen it before
        		$seen{$peptide} = 1;
			$x++;
                	print $mascot_three,"_",$x, "\t", $peptide, "\n";
	}
	}
	
close (MASCOT);

#until ($protein=~/^\s*$/);
 exit;
1;
