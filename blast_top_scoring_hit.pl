$n = 4;		#number of genomes

for ($i = 1; $i <= $n; $i++) {
    for ($j = 1; $j <= $n; $j++) {
        if ($i == $j) {
            next;
        }
        open (IN, "< g".$i."_g".$j.".txt");
        open (OUT, "> g".$i."_g".$j."_top.txt");

        $old_gi = -1;

        while (<IN>) {
            chomp;
    
            if (/^#/) {
                next;			#skip -m9 comment line
            }
            @a = split /\t/;
            @gi1a = split /\|/, $a[0];	#pull out the query gi number
            @gi2a = split /\|/, $a[1]; 	#pull out the subject gi number
            $gi1 = $gi1a[1];
            $gi2 = $gi2a[1];
        
            if ($gi1 != $old_gi) {
                print OUT "$gi1\t$gi2\n";
                $old_gi = $gi1;
            }
        }
        close (IN);
        close (OUT);
    }
}

