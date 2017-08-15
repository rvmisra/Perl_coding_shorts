#!/usr/local/bin/perl
#
# Program Description:
# --------------------

# This program will take large tracks of sequence data in FASTA file format, and produce PCR products in overlapping seqments to span the entire region.  This program is written to divide up the given sequence, based on the users criteria for PCR product size and overlap between adjacent segments, and pass this data to the PCR primer selecting program 'primer3', written at the Whitehead Institute.  Primer3 then chooses primer sets based on specific selection criteria.   The output file is a list of primer sets consisting of the primer sequence, melting temperature (program calculated), primer set "quality" (lower is better), primer position, primer lengths, PCR product length, and amount of overlap between fragments.  

# Input file:  sequence file (FASTA format)
# Output file:  primer_set.out
# Usage:  pcr_overlap.pl <FASTA input file>

# **Note:  You need to install the program Primer3 on your system before running pcr_overlap.pl.  Primer3 can be found at the website:  http://www-genome.wi.mit.edu/

#
#	Usage:  pcr_overlap.pl <FASTA input file>
#  	Edit history:  4 April 1997  Mark J. Rieder
#	Modified:  7 May 1997 Mark J. Rieder
#		Included checks to identify when primers couldn't be found in a region
#	Modified:  24 June 1997 Mark J. Rieder
#		Included fragment size and overlap averages in output.
#	Modified:  05 October 1999 Mark J. Rieder
#		Included fasta output and primer ordering formats and command line input
#		Faster performance.


#  Error message if no input file is given

#$usage = "Usage: pcr_overlap.pl <FASTA input file>";

#  Error message if no primer sets fulfill the selection criteria

$no_primers = "Could not find primers.  Change primer picking criteria or make search region larger by increasing overlap region.";


&parseCommandLine;


#  Open sequence fasta file

$seq_file = $arg{-file};	#  get file with sequence data

open(PRIMERS_OUT,"> $arg{-gene}.primers.txt");	#  output file where primer sets are stored
open(FASTA, "> $arg{-gene}.primers.fasta");	# open fasta output file 

open(SEQFILE,"$arg{-file}") || die;	#  open fasta input file


print "Reading in sequence file...";

while ($linein = <SEQFILE>)	#  read in sequence from input file
{
	chop($linein);
	if ($linein !~ />/)
	{
		$sequence = $sequence.$linein;	#  read in sequence but not the fasta header
	}
}

$_ = $sequence;

$seq_count = tr/acgtnACGTN/acgtnACGTN/;	#  Count the number of bases in the sequence to analyze

print "$seq_count bases\n\n";  #  print number of bases read in from fasta file

#  process sequence to be put into array


@sequence = split("",$sequence);

# set size of PCR product +-15%

$size = $arg{-size};
 
$size_range_lo = $size - $size*0.15;
$size_range_hi = $size + $size*0.15;

$range = "$size_range_lo-$size_range_hi";

# set size of overlap between products to be +-30%

$overlap = $arg{-overlap};
$overlap_lo = $overlap - $overlap*0.30;
$overlap_hi = $overlap + $overlap*0.30;
 
$start_site = $arg{-start};



print PRIMERS_OUT "Search parameters used:\n";  #  Echo search parameters 
print PRIMERS_OUT "Size Range: $size_range_lo-$size_range_hi\n";
print PRIMERS_OUT "Overlap Range:  $overlap_lo-$overlap_hi\n";
print PRIMERS_OUT "Start Site: $start_site\n\n";

print "Search parameters used:\n";  #  Echo search parameters 
print "Size Range: $size_range_lo-$size_range_hi\n";
print "Overlap Range:  $overlap_lo-$overlap_hi\n";
print "Start Site: $start_site\n\n";

if ($start_site <= 100)
{
	die "Start site must be greater than 100 bp\n";
}

#  Initialize variables for summary statistics average size and overlap

$frag_sum = 0;
$overlap_sum = 0;



#  Calculate how much sequence to process first time to begin search

$seq_left_boundary = $start_site - 100;  #  set left boudary region to search
$seq_right_boundary = $start_site + $size_range_hi + 100;  #  set right boundary region   
$start_site = $start_site - $seq_left_boundary;  #  rescale starting point for primer3


$primer_search_region = $start_site;


#  get the correct amount of sequence to search

for ($i = $seq_left_boundary;$i < $seq_right_boundary;++$i)
{
	$search_seq = $search_seq.$sequence[$i];
}


$set_numb = 1;


&p3Parameters;	# set parameters passed to primer3 and run primer3

&parsep3;	# parse primer3 output


$primer_right_old = $primer_right_seq;
$primer_left_old = $primer_left_seq;

#  rescale primer positions to correspond with the original sequence

$primer_left_posit_adj = $seq_left_boundary + $primer_left_posit + 1;
$primer_right_posit_adj = $primer_left_posit_adj + $primer_prod_size - 1;

#  keep track of how much of the original sequence was processed

$seq_processed = $seq_left_boundary + $primer_right_posit;

# save primer set data in the output file

&printPrimer;

#  Begin to accumulate primer size and overlaps for output of summary statistics

$frag_sum = $frag_sum + $primer_prod_size;
$frag_sum_squared = $primer_prod_size**2;

# determine starting point for next primer search

$start_site = $seq_processed - $primer_right_size - $overlap_lo;
$seq_left_boundary = $start_site - ($overlap_hi -$overlap_lo);
$seq_right_boundary = $start_site + $size_range_hi + 100;


$primer_search_region = $overlap_hi - $overlap_lo;	#  this defines region to search for the left primer

#  loop to walk through the remaining sequence while there still is sequence to process

while ($seq_right_boundary < $seq_count - 1)
{
	$search_seq = "";  # initialize search sequence

	for ($i = $seq_left_boundary;$i < $seq_right_boundary;++$i)
	{
		$search_seq = $search_seq.$sequence[$i];
	}


	++$set_numb;

	&p3Parameters;
	
	&parsep3;
	
	
	

	#  Do error checking to see if it returned the same primers from the last selection.

	if ($primer_right_seq eq $primer_right_old || $primer_left_seq eq $primer_left_old)
	{
		die "$no_primers\n";
	}

	$primer_right_old = $primer_right_seq;
	$primer_left_old = $primer_left_seq;

	#  rescale values for the primer positions to correspond to the original sequence

	$primer_left_posit_adj = $seq_left_boundary + $primer_left_posit + 1;
	
	#  calculate sequence overlap with the last primer set

	$frag_overlap = $primer_right_posit_adj - $primer_left_posit_adj - $primer_right_size - $primer_left_size;

	$primer_right_posit_adj = $primer_left_posit_adj + $primer_prod_size - 1;

	$seq_processed = $seq_left_boundary + $primer_right_posit;
	
	
	
	&printPrimer;
	
	
	#  Accumulate fragment sizes and overlaps to caluculate averages 
	
	$frag_sum = $frag_sum + $primer_prod_size;
	$frag_sum_squared = $frag_sum_squared + $primer_prod_size**2;
	$overlap_sum = $overlap_sum + $frag_overlap;
	$overlap_sum_squared = $overlap_sum_squared + $frag_overlap**2;

	# Determine new sequence boundaries and start positiions

	$start_site = $primer_right_posit_adj -$primer_right_size - $overlap_lo;
	$seq_left_boundary = $start_site - ($overlap_hi -$overlap_lo);
	$seq_right_boundary = $start_site + $size_range_hi + 100;
	$seq_size = $seq_right_boundary - $seq_left_boundary;

}

$frag_ave = $frag_sum/$set_numb;
$overlap_ave = $overlap_sum/($set_numb - 1);
$frag_std = (($frag_sum_squared - ($frag_sum**2/$set_numb))/($set_numb - 1))**0.5;
$overlap_std = ((($overlap_sum_squared - ($overlap_sum**2/($set_numb - 1)))/($set_numb - 2)))**0.5;

#  Output primer statistics for each set

printf PRIMERS_OUT "Summary Statistics for Primer Sets:\nAve. Frag. Size = %5d +/- %3d\nAve. Overlap = %5d +/- %3d\n\n" , $frag_ave, $frag_std, $overlap_ave, $overlap_std;

exit;


sub p3Parameters
{

	#call primer3 with the correct sequence parameters for search for the first search

	open(P3_INPUT,">p3_input");  #  all parameter values for primer3 are written to the file 'p3_input'

	#  search parameters defined by primer3 -- see primer3 documentation

	print P3_INPUT "SEQUENCE=$search_seq\n";
	print P3_INPUT "PRIMER_PRODUCT_SIZE_RANGE=$range\n";
	print P3_INPUT "TARGET=$primer_search_region,1\n";
	#print P3_INPUT "PRIMER_SELF_ANY=4\n";
	#print P3_INPUT "PRIMER_SELF_END=3\n";
	#print P3_INPUT "PRIMER_GC_CLAMP=1\n";
	print P3_INPUT "PRIMER_MAX_GC=70\n";
	print P3_INPUT "PRIMER_OPT_SIZE=23\n";
	print P3_INPUT "PRIMER_MAX_POLY_X=3\n";
	print P3_INPUT "PRIMER_MIN_SIZE=18\n";
	print P3_INPUT "PRIMER_MAX_SIZE=28\n";
	print P3_INPUT "=";

	#open(P3_INPUT,">p3_input");  #  all parameter values for primer3 are written to the file 'p3_input'

	close(P3_INPUT);



	#  call primer3 using input parameters and temporarily storing results in file 'out'

	#$set_numb = 1;
	print "Picking primer set $set_numb...\n";

	system("primer3 < p3_input > out");

}


sub parsep3
{


	#  save results	

	open(OUT_FILE,"out");
	
	
	while ($linein = <OUT_FILE>)
	{
		chop($linein);
		if ($linein =~ /PRIMER_LEFT_SEQUENCE=/)	#  get sequence of left side primer
		{
			@primer_left_seq = split(/=/,$linein);
			$primer_left_seq = @primer_left_seq[1];
		}

		if ($linein =~ /PRIMER_RIGHT_SEQUENCE=/)  # get sequence of right side primer
		{
			@primer_right_seq = split(/=/,$linein);
			$primer_right_seq = @primer_right_seq[1];
		}

		if ($linein =~ /PRIMER_LEFT_TM=/)  #  get left primer melting temperature
		{
			@primer_left_tm = split(/=/,$linein);
			$primer_left_tm = @primer_left_tm[1];
		}

		if ($linein =~ /PRIMER_RIGHT_TM=/)  #  get right primer melting temperature
		{
			@primer_right_tm = split(/=/,$linein);
			$primer_right_tm = @primer_right_tm[1];
		}

		if ($linein =~ /PRIMER_PAIR_QUALITY=/)  #  get primer set quality
		{
			@primer_pair_quality = split(/=/,$linein);
			$primer_pair_quality = @primer_pair_quality[1];
		}
	
		if ($linein =~ /PRIMER_LEFT=/)	#  get left primer position and size
		{
			@tmp = split(/=/,$linein);
			$tmp = @tmp[1];
			@primer_left_posit = split(/,/,$tmp);
			$primer_left_posit = @primer_left_posit[0];
			$primer_left_size = @primer_left_posit[1];
		}

		if ($linein =~ /PRIMER_RIGHT=/)	#  get right primer position and size
		{
			@tmp = split(/=/,$linein);
			$tmp = @tmp[1];
			@primer_right_posit = split(/,/,$tmp);
			$primer_right_posit = @primer_right_posit[0];
			$primer_right_size = @primer_right_posit[1];
		}

		if ($linein =~ /PRIMER_PRODUCT_SIZE=/)	# get PCR product size
		{
			@primer_prod_size = split(/=/,$linein);
			$primer_prod_size = @primer_prod_size[1];
		}

		if ($linein =~ /PRIMER_LEFT_SELF_ANY=/)	# get complementarity stats
		{
			@primer_left_self = split(/=/,$linein);
			$primer_left_self = @primer_left_self[1];
		}
	
		if ($linein =~ /PRIMER_RIGHT_SELF_ANY=/)	# get complementarity stats
		{
			@primer_right_self = split(/=/,$linein);
			$primer_right_self = @primer_right_self[1];
		}

		if ($linein =~ /PRIMER_PAIR_COMPL_ANY=/)	# get pair stats 
		{
			@primer_pair_compl_any = split(/=/,$linein);
			$primer_pair_compl_any = @primer_pair_compl_any[1];
		}

		if ($linein =~ /PRIMER_PAIR_COMPL_END=/)	# get pair stats
		{
			@primer_pair_compl_end = split(/=/,$linein);
			$primer_pair_compl_end = @primer_pair_compl_any[1];
		}
	}
	close(OUT_FILE);
	
}


sub printPrimer
{

	local ($univ_forward, $univ_reverse);
	

	$univ_forward = TGTAAAACGACGGCCAGT;
	$univ_reverse = CAGGAAACAGCTATGACC;
	
	
	
	
	print PRIMERS_OUT  "$primer_left_seq  $primer_left_tm\n$primer_right_seq  $primer_right_tm\n$primer_pair_quality\n$primer_right_self  $primer_left_self\n$primer_pair_compl_any  $primer_pair_compl_end\n$primer_left_posit_adj $primer_left_size\n$primer_right_posit_adj $primer_right_size\n$primer_prod_size , $frag_overlap\n\n";

	if ($set_numb <= 9)
	{
		$primer_id_for = $arg{-gene}."0".$set_numb."0";
		$primer_id_rev = $arg{-gene}."0".$set_numb."1";
	}
	else
	{
		$primer_id_for = $arg{-gene}.$set_numb."0";
		$primer_id_rev = $arg{-gene}.$set_numb."1";
	}
	
	if (!$arg{-nouniv})
	{
		$print_primer_left_seq = $univ_forward.$primer_left_seq;
		$print_primer_right_seq = $univ_reverse.$primer_right_seq;
		print FASTA ">$primer_id_for\n$print_primer_left_seq\n>$primer_id_rev\n$print_primer_right_seq\n";

	}
	else
	{
		print FASTA ">$primer_id_for\n$primer_left_seq\n>$primer_id_rev\n$primer_right_seq\n";
	}
	
	

}







sub parseCommandLine
{

    local ( $usage ) = "pcr_overlap\t[-file]\t[-gene]\n\t\t<-start>\n\t\t<-size>\n\t\t<-overlap>\n\t\t<-nouniv>\n";

    # default values

    $arg{-file} = '';
    $arg{-gene} = '';
    $arg{-size} = 1000;
    $arg{-overlap} = 180;
    $arg{-start} = 150;
    $arg{-nouniv} = '';
    

    # parse the command line

    for ( $i = 0; $i <= $#ARGV; $i++ )
    {
    	if ( "-nouniv" =~ $ARGV[$i])
    	{
    	    	$arg{-nouniv} = 1;
   		next;
    	}
    	else
    	{
    		$arg{-nouniv} = 0;
    	} 
        
        
        if ( $ARGV[$i] =~ /^-/ )
         {
	    $arg{$ARGV[$i]} = $ARGV[$i+1];
         }
    }
    
  
    # file arg is required

    die ( $usage ) if ( ! $arg{-file} || ! $arg{-gene} );

}
