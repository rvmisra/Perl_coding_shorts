#Compare two lists and print only unique ones in list1 (A)
#Comp1.pl
#Author Raju Misra
#!/usr/bin/perl

@A = qw (tom dick harry); #Query list of peps headers
@B = qw (peter paul dick harry); #Blast output of query seqs

@C=map{!${{map{$_,1}@B}}{$_}&&$_||undef}@A; #Compares list 1 (query) with list 2 (blast output)
#@C = keys %{ { map { $_, 1} (@A, @B) } };
print "@C\n";