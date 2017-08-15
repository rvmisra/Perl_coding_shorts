#!/usr/local/bin/perl -w

# Find all single peptide hits in a Sequest output file (Tab-delimited txt format)
# and check which of these are also in an Xtandem singles output file (txt format).  
# Create a Tab-delimited txt file that lists the singles common to both input files
# and shows revised statistics with sequest-only hits subtracted from the nonredundant
# protein and peptide totals

# Author: Susan Miller, Arizona Research Labs Biotechnology Computing Facility
# 17 Jun 05
#
# 24 Jun 05 sjm
#	Report number of xtandem singles matching multiple peptide sequest hits
#
# 29 Nov 05 sjm
#   Output modified DTASelect file with added Xtandem info

use Getopt::Long;

GetOptions("combine" => \$comb);
$usage = "Usage: $0 Sequest_txtfile XtandemSingles_txtfile\n";
$sequest = $ARGV[0];
$xtndmsngl = $ARGV[1];
if (!defined $sequest || !defined $xtndmsngl) {
    die $usage;
}

@parts = split (/\_/, $sequest);
for ($i = 0; $i < $#parts-1; $i++) {
  $basename .= $parts[$i].'_';
}
$basename .= $parts[$i];

open(SFIL, "$sequest") or die "Cannot open file $sequest\n";
open(XFIL, "$xtndmsngl") or die "Cannot open file $xtndmsngl\n";
open(OFIL, ">CommSngl_$basename") or die "Cannot write file CommSngl_$basename\n";
if (defined $comb) {
  open(CFIL, ">XtDTA_$basename") or die "Cannot write file XtDTA_$basename\n";
}

# Check that this is a sequest file
$slin = <SFIL>;
if ($slin!~ /^DTASelect/) {
	die "First file not recognized as Sequest output\n$usage";
}

#initialize counters
$xtcount = $sqcount = $xtonly = $sqonly = $both = $snglxt_multseq = 0;

print STDERR "Parsing $sequest...\n";
while ($slin = <SFIL>) {
	# skip over most of the rows of the header
    if ($slin =~ /^Locus/) { last; }
}
# Print 2 rows of column headers
chop($slin);
chop($slin);
$hdr1 = "$slin\t\t\t\t\t\t\t";
#print OFIL $hdr1;

$xlin = <XFIL>;
chop($xlin);
@col = split(/\t/, $xlin);

# find column header for identifiers
$ccount = $found = 0;
foreach $c (@col) {
  if ($c =~ /^identifier/i || $c =~ /^accession/i) {
    $found = 1;
  } else {
    $hdr1 .= "\t$c";
    #print OFIL "\t$c";
  }
  if (!$found) {
    $ccount++;
  }
}
print OFIL "$hdr1\n";

$slin = <SFIL>;
print OFIL "$slin";

while ($slin = <SFIL>) {
    # Pick out the IDs that are single peptide hits
	@col = split(/\t/,$slin);
	if ($col[1] =~ /^Proteins/) { last; }
	$nprot = $col[1];
	if ($nprot > 1) {
	   $sqmult{$col[0]} = $nprot;
	   for ($i = 0; $i < $nprot; $i++) {
	       $slin = <SFIL>;
	   }
	   next;
	}
	chop($slin);
	chop($slin);
	$sqinfo{$col[0]} = $slin;
	#print STDERR "KEY !$col[0]! VAL $slin\n";	
	# get info from next row
	$slin = <SFIL>;
	$sqinfo2{$col[0]} = $slin;
					
}

print STDERR "Parsing $xtndmsngl...\n";
while ($xlin = <XFIL>) {
	chop($xlin);
    $xtcount++;
    @col = split(/\t/, $xlin);
	$desc = $col[$ccount];
	@word = split(/\s+/, $desc);
	$id = $word[0];
	$id =~ s/\"//g;
	if (!defined $sqinfo{$id}) { 
		$xtonly++;
		#print "$id xtandem ONLY\n";
	}
	if (defined $sqmult{$id}) {
	  $snglxt_multseq++;
	}
	splice(@col, $ccount, 1);
	$xtinfo{$id} = join("\t", @col);
	#print STDERR "KEY !$id! VAL $xtinfo{$id}";
}

while(($key, $value) = each(%sqinfo)) {
	$sqcount++;
    if (!defined $xtinfo{$key}) {
		$sqonly++;
		#print "$key SEQUEST ONLY\n";
	}
}

while(($key, $value) = each(%sqinfo)) {
    if (defined $xtinfo{$key}) {
		$both++;
	    #print "$key in BOTH\n"; 
		
		print OFIL $sqinfo{$key};
		print OFIL "\t\t\t\t\t\t\t\t$xtinfo{$key}\n";
		print OFIL "$sqinfo2{$key}";
	}
}

$slin = <SFIL>;
$slin = <SFIL>;
$slin = <SFIL>;
@col = split(/\t/, $slin);
$nrProt = $col[1];
$nrPep = $col[2];
print OFIL "Sequest singles\t$sqcount\n";
print OFIL "Xtandem singles\t$xtcount\n";
print OFIL "Common Singles\t$both\n";
print OFIL "Xtandem-only Singles\t$xtonly\n";
print OFIL "Single Xtandem/Multiple Sequest\t$snglxt_multseq\n";
print OFIL "Singles eliminated from Sequest\t$sqonly\n";
print OFIL "Nonredundant proteins\t$nrProt\tRevised\t",$nrProt - $sqonly,"\n";
print OFIL "Nonredundant peptides\t$nrPep\tRevised\t",$nrPep - $sqonly,"\n";
close OFIL;
close SFIL;
print STDERR "Comparison file name is CommSngl_$basename\n";


if (defined $comb) { # Re-read DTA file and combine with XTandem info
  open(SFIL, "$sequest") or die "Cannot open file $sequest\n";
  while ($slin = <SFIL>) {
	# print the rows of the header
    if ($slin =~ /^Locus/) { last; }
	print CFIL $slin;
  }
  print CFIL "$hdr1\n";
  $slin = <SFIL>;
  print CFIL "$slin";

  while ($slin = <SFIL>) {
    # Pick out the IDs that are single peptide hits
	@col = split(/\t/,$slin);
	if ($col[1] =~ /^Proteins/) { last; }
	$nprot = $col[1];
	if ($nprot > 1) {
      print CFIL $slin;
	  for ($i = 0; $i < $nprot; $i++) {
	    $slin = <SFIL>;
		print CFIL $slin;
	  }
	} else {
	   $key = $col[0];
	   if (defined $xtinfo{$key}) {
		 print CFIL $sqinfo{$key};
		 print CFIL "\t\t\t\t\t\t\t\t$xtinfo{$key}\n";
		 print CFIL "$sqinfo2{$key}";
	   }
	   $slin = <SFIL>; # skip since sqinfo contains info
	}				
  }
  print CFIL "Sequest singles\t$sqcount\n";
  print CFIL "Xtandem singles\t$xtcount\n";
  print CFIL "Common Singles\t$both\n";
  print CFIL "Xtandem-only Singles\t$xtonly\n";
  print CFIL "Single Xtandem/Multiple Sequest\t$snglxt_multseq\n";
  print CFIL "Singles eliminated from Sequest\t$sqonly\n";
  print CFIL "Nonredundant proteins\t$nrProt\tRevised\t",$nrProt - $sqonly,"\n";
  print CFIL "Nonredundant peptides\t$nrPep\tRevised\t",$nrPep - $sqonly,"\n";
  close CFIL;
  close SFIL;
  print STDERR "Combined DTA/XTandem file name is XtDTA_$basename\n";

}
