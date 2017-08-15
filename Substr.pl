#!/usr/bin/perl -w




 	open (GENOME, "630NA.fasta") ||  die $!;
      	while ($genome = <GENOME>) {
		chomp($genome);
		$Genomepos=substr($genome,755720,550);
	print $Genomepos;
	}
	close (GENOME) or die( "Cannot close file : $!");