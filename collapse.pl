#close bracket precedes a bootstrap support value (except for last one)
#just take note of which brackets to remove in the first pass
#second pass removes them

$min_support = 95;	#accept bootstrap support of 95 or better
			#otherwise collapse the tree

while (<>) {
    chomp;

    @chars = split //;
    $alert = 0;
    $boot = "";
    $nestlevel = 0;	#bracket nesting
    %position = ();	#position within nesting
    %remove = ();	#remove this bracket?

    foreach $c (@chars) {
	if (($c =~ /\d/) && ($alert == 1)) {
	    #this is a bootstrap support value
	    $boot .= $c;
	}
	else {
	    if ($alert == 1) {
                $actual_nestlevel = $nestlevel + 1;	#we just closed the bracket

                if ($actual_nestlevel > 1) {
	            #just passed a bootstrap support value
		    if ($boot < $min_support) {
		        $remove{$actual_nestlevel}{$position} = 1;
		    }
		    $boot = "";
		    $alert = 0;
	        }
            }
	}
        if ($c eq ")") {
	    $alert = 1;
	    $nestlevel--;
	}
	if ($c eq "(") {
	    $nestlevel++;
	    $position{$nestlevel}++;
	}
    }
    #
    #now for the second pass
    #
    $alert = 0;
    $boot = "";
    $nestlevel = 0;	#bracket nesting
    %position = ();	#position within nesting
    $tree = "";

    foreach $c (@chars) {
        if ($alert == 2) {
            if (($c =~ /\d/) || ($c eq ".") || ($c eq ":")) {
                next;	#chew up this branch length
	    }
            else {
                $alert = 0;
            }
        }
	if (($c =~ /\d/) && ($alert == 1)) {
	    #this is a bootstrap support value
	    $boot .= $c;
	}
	else {
	    if ($alert == 1) {
	        #just passed a bootstrap support value
                $actual_nestlevel = $nestlevel + 1;	#we just closed the bracket

		if ($remove{$actual_nestlevel}{$position} != 1) {
		    $tree .= $boot;
		    $alert = 0;
		    $boot = "";
		}
                else {
                    $alert = 2;	#chew up branch length associated with this
				#bootstrap support value
		    $boot = "";
                    next;
		}
	    }
            if ($c eq ")") {
	        $alert = 1;
	        if ($remove{$nestlevel}{$position} != 1) {
		    $tree .= $c;
	        }
	        $nestlevel--;
	    }
	    elsif ($c eq "(") {
	        $nestlevel++;
	        $position{$nestlevel}++;
	        if ($remove{$nestlevel}{$position} != 1) {
		    $tree .= $c;
	        }
	    }
	    else {
	        $tree .= $c;
	    }
	}
    }
    print "$tree\n";
}

