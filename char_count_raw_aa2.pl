#!/usr/bin/perl -w
#Author Raju Misra

#open the genome sequence file, note: raw sequence, fasta header removed
open (GENOME, "Line_cleanup_prots4.txt") ||  die $!;
while ( <GENOME> ) {

#split the loci information file, into 3 columns	
my ($Query, $Subject, $id, $al, $mis, $gapopen, $qstart, $qend, $sstart, $send, $eval, $bit, $dbhead, $dbheadlength) = split(/£/);

my $seqlength = length ($dbheadlength);

my $pccov = $al/$dbheadlength;

#if ($dbhead=~/$Subject/g){
	
#	}

	print $pccov;
			
			}
	
close (GENOME) or die( "Cannot close file : $!");