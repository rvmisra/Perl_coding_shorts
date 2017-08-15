@list = glob("*.afa");	#all the aligned fasta files in this directory
@lengths = ();

#put all the alignment lengths into the @lengths array

foreach $file (@list) {
    open (IN, "< $file");
    $sequence = "";
    
    while (<IN>) {
        chomp;

        if (/^>/) {
            $len = length($sequence);

            if ($len) {
                push (@lengths, $len);
                last;
            }
            next;
        }
        else {
            $sequence .= $_;
        }
    }
}
#===========================================+
#spit out a really simple histogram         |
#                                           |
# NUMBERS YOU WILL PROBABLY WANT TO CHANGE: |
#===========================================+
$low = 0;	#lowest bound
$inc = 50;	#increment
$more = 800;	#"More" is more than $more :-)

print "Bin\tFrequency\n";

for ($j = $low; $j <= $more; $j += $inc) {
    if ($j == $low) {
        $i = $low;
        next;
    }
    #count everything > $i and <= $j
    $freq = 0;
    
    foreach $len (@lengths) {
        if (($len > $i) && ($len <= $j)) {
            $freq++;
        }
    }
    #Excel style, just spit out the upper bound!
    print "$j\t$freq\n";

    $i = $j;	#moving along the interval
}
#Don't forget to do "More"
$freq = 0;

foreach $len (@lengths) {
    if ($len > $more) {
        $freq++;
    }
}
print "More\t$freq\n";

