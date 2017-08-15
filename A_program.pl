#!/usr/bin/perl
###!/usr/local/bin/perl
#BA_blast_parse1.pl
#Author: Ali Al-Shahib

use warnings;
use strict;

my $qid = 0;
my $sid = 0;
my $E = 0;
my $N = 0;
my $Sprime = 0;
my $S = 0;
my $alignlen = 0;
my $nident = 0;
my $npos = 0;
my $nmism = 0;
my $pcident = 0;
my $pcpos = 0;
my $qgaps = 0;
my $qgaplen = 0;
my $sgaps = 0;
my $sgaplen = 0;
my $qframe = 0;
my $qstart = 0;
my $qend = 0;
my $sframe = 0;
my $sstart = 0;
my $send = 0;
my $peptide = '';
my $blastline = '';
my $length = 0;
my @results;
my $result;
my $peptide_letter;


	my %peptides_hash = ();

      	open (PEPTIDES, "CB_peptide_pri_id_DISTINCT.FASTA") ||  die $!;
      	while ($peptide = <PEPTIDES>) {
		chomp($peptide);
		if ($peptide=~/>/g){
			$peptide_letter = substr ($peptide,1);
		}

		$length = length($peptide);
		$peptides_hash{$peptide_letter} = $length;
	}
	close(PEPTIDES);

	my $key;
	my $value;
=begin
	while (($key, $value) = each(%peptides_hash)){

		print  $key."\t".$value."\n";



	}
=cut
	my $total_matches=0;
	
	### loop through all peptides in peptide file
	while (($key, $value) = each(%peptides_hash)){
		
		 my $failed_sid=0;
                 my $passed_length_and_percentage=0;
		my @perfect_score_proteins =();
		my $x=0;
		open (BLAST_OUTPUT, "CB_NEW_FIRST_110609_BLAST.OUTPUT") ||  die $!;

		## for each peptide in the peptide file
		while ($blastline = <BLAST_OUTPUT>) {
      	 		chomp($blastline);
			($qid, $sid, $E, $N, $Sprime, $S, $alignlen, $nident, $npos, $nmism, $pcident, $pcpos, $qgaps, $qgaplen, $sgaps, $sgaplen, $qframe, $qstart, $qend, $sframe, $sstart, $send) = split /\t/, $blastline;         
$x++;	
			next if ($qid ne $key);
			
			if(
			    (int($alignlen)==$value)
				&&
			    ($pcident =~ /100/g)
			   ) {
					$passed_length_and_percentage=1;
					push (@perfect_score_proteins,$sid);
			     }

		}
		 close(BLAST_OUTPUT);	

		if(@perfect_score_proteins < 1) {
			 $failed_sid = 1;
		}

 		if(@perfect_score_proteins > 1) {
                                foreach my $protein_name (@perfect_score_proteins) {

					if ($protein_name !~ /Clostridium_botulinum/g) {
						$failed_sid = 1;
					}
				}
                }

                else {
		    if ($perfect_score_proteins[0]){
                        if ($perfect_score_proteins[0] !~ /Clostridium_botulinum/g) {
                                        $failed_sid=1;
                        }
		   }
                }

		 if($failed_sid==0) {
                                push @results, "$key";
				print "$x: $key=passed\n";
				$total_matches++;
				print "\n\nTOTAL=$total_matches\n\n";
				
                 }

		else {
			print "$x: $key=failed\n";

		}

	}

	 print "\n\nTOTAL MATCHES = " . $total_matches . "\n\n\n";




	open (MYFILE, ">../test_results.txt") ||  die $!;

	my %seen = ();
	foreach $result (@results) {
    		unless ($seen{$result}) {
        		# if we get here, we have not seen it before
        		$seen{$result} = 1;
                	print MYFILE $result."\n";
		}
	}
	
	close MYFILE;

1;
