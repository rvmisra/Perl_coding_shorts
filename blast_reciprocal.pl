$n = 4;		#number of genomes
%best = ();	#what is the best match for this sequence
%genome = ();	#which genome is this sequence from

for ($i = 1; $i <= $n; $i++) {
    for ($j = 1; $j <= $n; $j++) {
        if ($i != $j) {
            open (IN, "< g".$i."_g".$j."_top.txt");

	    while (<IN>) {
	        chomp;
		($a, $b) = split /\t/;
		$best{$a}{$j} = $b;
		$genome{$a} = $i;
	    }
	}
    }
}
open (OUT, "> reciprocal.out");

foreach $a (keys %best) {
    foreach $j (keys %{$best{$a}}) {
        $match_a = $best{$a}{$j};			#a's best match
        $match_b = $best{$match_a}{$genome{$a}};	#b's best match

	if ($match_b == $a) {				#b's best match is a
	    print OUT "seq $a in genome $genome{$a} and seq $match_a in genome $genome{$match_a} is a reciprocal best match\n";
	}
    }
}
close (OUT);

