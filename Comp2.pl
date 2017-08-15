#Compare two lists and print only unique ones in list1 (A)
#Comp2.pl
#Author Raju Misra
#!/usr/bin/perl

use warnings;
use strict;

my @A;
my @B;
my @C;

my $list1 = 0;
my $list2 = 0;


############ blast file - list2 ##################################

open (LIST2, "list2.txt") ||  die $!;
while (my $list2 = <LIST2>) {
push @B,$list2; 

}

##################### Query file list 1 ############################                                                                                                
     	open (LIST1, "list1.txt") ||  die $!;
      	while (my $list1 = <LIST1>) { 
		push @A,$list1; 
}	
####################################################################


@C=map{!${{map{$_,1}@B}}{$_}&&$_||undef}@A; #Compares list 1 (query) with list 2 (blast output)

print "@C\n";

#print "@C\n";
#}


close (LIST1) or die( "Cannot close file : $!");
close(LIST2);