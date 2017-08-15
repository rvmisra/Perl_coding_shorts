#make xref database from genome faa files
open (OUT, "> xref_db.txt");

for ($i = 1; $i <= 7; $i++) {
    open (IN, "< g$i.faa");

    while (<IN>) {
        if (/^>/) {
            if (/gi\|(\d+)\|/) {	#NCBI format
		print OUT "$1\t$i\n";
            }
            if (/gene(\d+)/) {		#JGI format
		print OUT "$1\t$i\n";
            }
	}
    }
}

