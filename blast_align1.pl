use Bio::SearchIO;
use Bio::AlignIO;

my $blast_report = new Bio::SearchIO ('-format' => 'blast',
				      '-file'   => $ARGV[0]);
my $result = $blast_report->next_result;
my $pattern = $ARGV[1];
my $out = Bio::AlignIO->newFh(-format => 'clustalw' );

while( my $hit = $result->next_hit()) {
    if ($hit->name() =~ /$pattern/i ) {
	while( my $hsp = $hit->next_hsp()) { 
	    my $aln = $hsp->get_aln();
	    print $out $aln;
	}
    }
}
