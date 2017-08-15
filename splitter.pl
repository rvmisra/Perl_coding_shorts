#!/usr/local/bin/perl

  use strict;

  unless ($ARGV[0] && -e $ARGV[0]) {
  		print "\nThis utility divides a long DNA sequence into manageable chunks.\n";
  		print "Original forward and reverse frame numbering will be maintained across\nthe new entries.\n";
  		print "Overlap size should be sufficient to avoid a peptide match being lost.\n\n";
  		print "Usage: splitter.pl filename chunk_size overlap_size line_length\n";
  		print "\n";
  		print "       filename     - path to input file (required)\n";
  		print "                      must be a single sequence in FASTA format\n";
  		print "       chunk_size   - nominal size of chunks (optional, default 12000)\n";
  		print "       overlap_size - nominal size of overlaps (optional, default 120)\n";
  		print "       line_length  - line length for sequence data in the output file\n";
  		print "                      (optional, default 60)\n";
  		print "\n";
  		print "Output file will have input filename with prefix \"split_\".\n";
  		print "If output file already exists, it will be overwritten.\n";
  		print "\n";
  		exit 0;
  }
  
  my($chunk_size, $overlap_size, $line_length);
  $chunk_size = 12000 unless ($chunk_size = int($ARGV[1]));		# sequence data will be divided into chunks of this nominal size
  $chunk_size = int(($chunk_size + 2) / 3) * 3;								# $chunk_size must be divisible by 3
  $overlap_size = 120 unless ($overlap_size = int($ARGV[2]));	# overlaps of this nominal size
  $overlap_size = int(($overlap_size + 2) / 3) * 3;						# $overlap_size must be divisible by 3
  $line_length = 60 unless ($line_length = int($ARGV[3]));		# line length for sequence data in the output file
  
  if ($chunk_size < 36 || $overlap_size < 18 || $line_length < 6) {
    die "Silly input values";
  }
  
  if ($ARGV[0] =~ /[\\\/]/) {
	  my($path, $slash, $name) = $ARGV[0] =~ /^(.*)([\\\/])(.*?)$/;
	  open(OUTFILE, ">" . $path . $slash . "split_" . $name);
	} else {
	  open(OUTFILE, ">split_" . $ARGV[0]);
	}  
	
	my ($input_seq, $begin, $end, $accession, $comment, $chunk);

  open(INFILE,"<$ARGV[0]");

  my $title = "";
  my @input;
  while (<INFILE>) {
		chomp;
  	if (/^>/) {
  		if ($title) {
  		  &process;
  		  undef @input;
  		}
  		$title = $_;
  	} else {
			s/[^A-Za-z]//g;
			push @input, $_;
  	}
  }
  if ($title) {
    &process;
  }

  close(INFILE);
  close(OUTFILE);
  print "\nAll done\n";
  exit 0;
  
  sub process {
    
    $title =~ />([^ ]+)\s+(.*)/;
    $accession = $1;
    $comment = $2;

    $input_seq = join "", @input;
    my $base_count = length($input_seq);
    if ($base_count < 2 * $chunk_size) {
    # don't bother to split
      $begin = 1;
      $end = $base_count;
      $chunk = 1;
      &output;
    } else {
      my $remainder = $base_count % 3;
      $begin = 1;
      $end = $chunk_size + $overlap_size + $remainder;
      $chunk = 1;
      while ($end < $base_count) {
      	&output;
        $begin += $chunk_size;
        $end += $chunk_size;
        $chunk++;
      }
      &output;
    }
    
  }

  sub output {

	  my $output_seq = substr($input_seq, $begin - 1, $end - $begin + 1);
	  my $new_title = ">" . $accession . "_" . $chunk . " bases " . $begin . "-" . $end . " " . $comment . "\n";
	  print OUTFILE $new_title;
	  print $new_title;		# progress report
	  my @output = $output_seq =~ /.{1,$line_length}/g;
	  foreach (@output) {
	  	print OUTFILE "$_\n";
	  }
  	
  }
  