$n = 4;				#number of genomes
%cluster = ();			#which cluster is a sequence in
$c = 0;				#unique cluster ID
%links = ();			#how many links in each cluster
%members = ();			#how many members in each cluster
$saturated = $n ** 2 - $n;	#saturated cluster will have n * (n - 1) links
				#and n members

open (IN, "< reciprocal.out");	#read in the reciprocal best matches

while (<IN>) {
    if (/seq (.+) in genome .+ and seq (.+) in genome .+ is a reciprocal best match/) {
        $a = $1;
        $b = $2;
        
        if (exists $cluster{$a}) {
	    if (exists $cluster{$b}) {
	        if ($cluster{$a} == $cluster{$b}) {
		    #a and b are in the same cluster
		    $links{$cluster{$a}}++;
		}
		else {
	            #merge clusters
		    $old = $cluster{$b};
		    foreach $i (keys %cluster) {
		        if ($cluster{$i} == $old) {
			    $cluster{$i} = $cluster{$a};
			}
		    }
		    $links{$cluster{$a}} += $links{$old};
		    delete ($links{$old});
		    $links{$cluster{$a}}++;
		    $members{$cluster{$a}} += $members{$old};
		    delete ($members{$old});
		}
	    }
	    else {
	        #put b in a's cluster
	        $cluster{$b} = $cluster{$a};
		$links{$cluster{$b}}++;
		$members{$cluster{$b}}++;
	    }
	}
	elsif (exists $cluster{$b}) {
	    #put a in b's cluster
	    $cluster{$a} = $cluster{$b};
	    $links{$cluster{$a}}++;
            $members{$cluster{$a}}++;
	}
	else {
	    #make a new cluster
	    $c++;
	    $cluster{$a} = $c;
	    $cluster{$b} = $c;
	    $links{$c} = 1;
            $members{$c} = 2;
	}
    }
}

foreach $c (keys %links) {
    if (($members{$c} == $n) && ($links{$c} == $saturated)) {
        print "cluster $c is saturated:";
        foreach $seq (keys %cluster) {
	    if ($cluster{$seq} == $c) {
	        print " $seq";
	    }
	}
	print "\n";
    }
}

