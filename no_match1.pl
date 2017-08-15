#!/usr/local/bin/perl
#no_match1.pl
#Author Raju Misra

use warnings;
use strict;

my $sentence = "The quick brown fox";

if ($sentence !~ /The/)
{
	print "match";
}
else
{
	print "no match";
}