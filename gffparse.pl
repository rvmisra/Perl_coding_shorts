#!/usr/bin/perl -w
#Author Raju Misra
#gffparse.pl


my $gffa =0;
my $gffb =0;
my $gffc =0;
my $gffd = 0;
my $gffe = 0;
my $gfff =0;
my $gffg =0;
my $gffh = 0;
my $gffi = 0;
my $gffj =0;

my $coorda = 0;
my $coordb =0;
my $coordc =0;
my $coordd = 0;


#Open file, containing coords information 
open MYFILE, '<', 'coords.txt' or die "Cannot open file.txt: $!";

#while the file is open do something
while ( <MYFILE> ) {
($coorda, $coordb, $coordc, $coordd) = split(/\t/);
#print $coorda . "\t" . $coordb . "\t" . $coordc. "\t" . $coordd;

#open the gff
open (GFF, "gff_tab_196.txt") ||  die $!;
while ( <GFF> ) {
($gffa, $gffb, $gffc, $gffd, $gffe, $gfff, $gffg, $gffh, $gffi, $gffj) = split(/\t/);
#print $gffd . "\t" . $gffe;

if (($gffd > $coordc) && ($gffd < $coordd)) {
print $coorda . "\t" . $coordb . "\t". $gffa . "\t" . $gffb . "\t" . $gffc . "\t" . $gffd . "\t" . $gffe . "\t" . $gfff . "\t" . $gffg . "\t" . $gffh . "\t"  . $gffi;
}
}
close (GFF) or die( "Cannot close file : $!");	


}
close MYFILE;
