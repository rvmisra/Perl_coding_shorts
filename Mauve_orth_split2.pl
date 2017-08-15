#!/usr/bin/perl -w
#Author Raju Misra
#tab input
#open the genome sequence file, note: raw sequence, fasta header removed

my $EC280CS = 0;
my $EC280P1 = 0;
my $EC280P2 = 0;
my $EC540Cat = 0;
my $EC541Cat = 0;
my $X = 0;

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);
###################Unique to 280 CS
if (($EC280CS !~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat =~ /x/g) && ($EC541Cat =~ /x/g))
{
print "Unique to 280CS>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 

close (GENOME) or die( "Cannot close file : $!");   

##################Unique to 280 P1

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 !~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat =~ /x/g) && ($EC541Cat =~ /x/g))
{
print "Unique to 280P1>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 

##################Unique to 280 P2

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 !~ /x/g) && ($EC540Cat =~ /x/g) && ($EC541Cat =~ /x/g))
{
print "Unique to 280P2>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 


##################Unique to 540

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat !~ /x/g) && ($EC541Cat =~ /x/g))
{
print "Unique to 540>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 

##################Unique to 541

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat =~ /x/g) && ($EC541Cat !~ /x/g))
{
print "Unique to 541>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 

#########################################################################
#########################################################################
########## OVERLAPS #####################################################

##################Unique to 540 and 280CSPS

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS !~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat !~ /x/g) && ($EC541Cat =~ /x/g))
{
print "Unique to 540 & 280CSPS>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 

##########################################################
open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 !~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat !~ /x/g) && ($EC541Cat =~ /x/g))
{
print "Unique to 540 & 280CSPS>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 

##########################################################
open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 !~ /x/g) && ($EC540Cat !~ /x/g) && ($EC541Cat =~ /x/g))
{
print "Unique to 540 & 280CSPS>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!");

#########################################################################
#########################################################################
########## OVERLAPS #####################################################

##################Unique to 540 and 541 

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat !~ /x/g) && ($EC541Cat !~ /x/g))
{
print "Unique to 540 & 541>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 


#########################################################################
#########################################################################
########## OVERLAPS #####################################################

##################Unique to 541 and 280CSPS

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS !~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat =~ /x/g) && ($EC541Cat !~ /x/g))
{
print "Unique to 541 & 280CSPS>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 

##########################################################
open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 !~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat =~ /x/g) && ($EC541Cat !~ /x/g))
{
print "Unique to 541 & 280CSPS>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 

##########################################################
open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 !~ /x/g) && ($EC540Cat =~ /x/g) && ($EC541Cat !~ /x/g))
{
print "Unique to 541 & 280CSPS>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!");


#########################################################################
#########################################################################
########## OVERLAPS #####################################################

##################Conserved in ALL

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS !~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat !~ /x/g) && ($EC541Cat !~ /x/g))
{
print "Conserved in all ECs>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 

##################Conserved in ALL

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 !~ /x/g) && ($EC280P2 =~ /x/g) && ($EC540Cat !~ /x/g) && ($EC541Cat !~ /x/g))
{
print "Conserved in all ECs>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 

##################Conserved in ALL

open (GENOME, "mix1.txt") ||  die $!;
while (<GENOME>) {

($EC280CS, $EC280P1, $EC280P2, $EC540Cat, $EC541Cat, $X) = split(/\t/);

if (($EC280CS =~ /x/g) && ($EC280P1 =~ /x/g) && ($EC280P2 !~ /x/g) && ($EC540Cat !~ /x/g) && ($EC541Cat !~ /x/g))
{
print "Conserved in all ECs>" . "\t" . $EC280CS . "\t" . $EC280P1 . "\t" . $EC280P2 . "\t" . $EC540Cat . "\t" . $EC541Cat . "\n";
}	
} 
close (GENOME) or die( "Cannot close file : $!"); 