#!/usr/bin/perl
 
use strict ;
 
my $file = $ARGV[0] ;
my $number = $ARGV[1] ;
 
unless($file && $number > 0) {
  print "second argument must be present and greater then 0\n" ;
  &usage() ;
}
 
open (FF, "<$file") || die "$!" ;
 
my $counter = 1 ;
my $fileno = 1 ;
my $stored ;
my $ext = fasta;

my $fileconc =  my $file.my $fileno;

while (<FF>) {
  if(/^>/) {
    if($counter > $number) {
	my $fileconc =  my $file.my $fileno;
	          &format_output($stored, "$fileconc.$ext") ;
      $counter = 1 ;
      $fileno++ ;
      $stored = "" ;
    }
    $counter++ ;
  }
 
  $stored .= $_ ;
}
 
&format_output($stored, "$fileconc.$ext") if($stored) ;
 
exit 0 ;
 
sub format_output {
  my ($stored, $file) = @_ ;
  if(-f $file) { die "File $file exists. Delete it first, run split.pl later\n" ; }
  open(FO, ">$file") || die "$!" ;
  print FO $stored ;
  close FO ;
}
 
sub usage {
  print "Usage: split.pl <filename> <sequences per file>\n" ;
  exit 1 ;
}
 
