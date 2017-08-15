#!/usr/bin/perl -w

# Script for combining multiple dat files
# with a delimiter blank/new line
# new_combine.pl
# Martin VanWinkle marty@arl.arizona.edu
# Needs perl

my $path_to_append="C:\\Perl\\bin\\append.pl";

my @files = glob("*");

foreach my $file (@files)
{
	next if ($file eq "." ||
		 $file eq ".." ||
		 !-d($file)
		 );
		 
	#print $file,"\n";
	
	chdir "$file";
		my $append_out="$file"."_combined";
		my $cmd="$path_to_append -i *.dta -o $append_out".".txt";
		# my $cmd="$path_to_append -i *.dta -o $file"."_combined.txt";
		print "Working folder:", `cd`,"\n";
		print `$cmd`;
		$cmd="move $append_out".".txt"." ..";
		print `$cmd`;
		print "\n";
	chdir "..";
	if (-e ("$append_out".".txt"))
	{
		$cmd="rename $append_out".".txt"." $append_out".".dta";
		print `$cmd`;
	}
}
