#!/usr/bin/perl -w
#Author Raju Misra
#Euler1


@thr = ();
$count = 0;
my $total = 0;

while ($count < 10) {
	$i= $count++;
	$three=3*$i;
	
	#print $three;
	push(@thr, $three); 
    
	if ($thr < 10) {
	
	print "@thr\n";
   }
   }