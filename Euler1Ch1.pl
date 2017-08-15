#!/usr/bin/perl
use strict;
use List::Util qw(reduce);

# find the natural numbers less than 1000 divisible by 3 or 5
my @multiples = ();
foreach (1..999) {
    if ($_ % 3 == 0 || $_ % 5 == 0) 
    { 
	    push(@multiples, $_); 
	}
}

# sum them
print reduce { $a + $b } @multiples;