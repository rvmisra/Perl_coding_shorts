#!/usr/local/bin/perl

# Converts input (default STDIN or file) in 2 column tab-delimited format into FASTA
# formated output (default STDOUT or file).  Column one of input should be sequence title
# and column two the sequence. Optional tag -l allows the line legth to be set (default is 60).
# Tag -x allows allows FastFormat to ignore extra columns and accept single column
# input (just title).  Tag -e causes spacing characters in sequences (i.e. '-' characters) to be edited out.
# Use -q option for quality score sequences to prevent score splitting at end of lines.
# ************
# Author: J. Cristobal Vera
# Please cite: J. Critobal Vera, et al. (2008). Rapid transcriptome characterization for a nonmodel organism using 454 pyrosequencing.
# Molecular Ecology, doi: 10.1111/j.1365-294X.2008.03666.x


# defaults, initializations, and constants
my $help = "\nFastaFormat 1.0\nConverts input in 2 column tab-delimited format (title and sequence) into FASTA formated output.\n".
          "\t-i  Option: allows input file to be specified.  Optional, default is STDIN.\n".
          "\t-o  Option: allows output file to be specified.  Optional, default is STDOUT.\n".
          "\t-l  Option: allows the formated sequence line legth to be set. Optional, default is 60.\n".
          "\t-x  Switch: causes FastFormat to ignore extra columns and accept single column input (i.e. just the title).\n".
          "\t-e  Switch: causes spacing characters in sequences (i.e. '-' characters) to be edited out.\n".
          "\t-q  Switch: convert quality scores to fasta format.\n".
          "\t-p  Switch: platform safe mode.  Removes ALL newlines and carriage returns\n\t\t as well as tabs and spaces from end of strings.\n".
          "************\nAuthor: J. Cristobal Vera\nPlease cite: J. Critobal Vera, et al. (2008).\nRapid transcriptome characterization for a nonmodel organism using 454 pyrosequencing.\nMolecular Ecology, doi: 10.1111/j.1365-294X.2008.03666.x\n";
my $usage = "\n\nFastaFormat -i [Input File Name] -l [Sequence Line Length] -o [Output File Name] -x {Ignore Column Numbers} -e {Remove Spacing Characters} -q {Platform Safe}\n";
my $infh = STDIN;
my $outfh = STDOUT;
my $seqend = 60;
my $ignore = 0;
my $edit = 0;
my $i = 0;
my $x = 0;
my $q = 0;
my $p = 0;
my ($sequence);
my @sequence;

#process command line tags
my $cmds = join ' ',@ARGV;
my @cmds = split /\-/,$cmds;
foreach my $tag (@cmds){
  $tag =~ s/ $//;
  if ($tag =~ m/^h(.*)/){
    die "\n$help\n$usage\n";
  }
  if ($tag =~ m/^i (.*)/){
    $infh = IN;
    open ($infh, "<$1") or die "Cannot open $1:$!\n";
  }
  if ($tag =~ m/^o (.*)/){    
    $outfh = OUT;
    open ($outfh, ">$1") or die "Cannot create $1:$!\n";
  }
  if ($tag =~ m/^l (.*)/){
    $seqend = $1;
  }
  if ($tag =~ m/^x(.*)/){
    $ignore = 1;
  }
  if ($tag =~ m/^e(.*)/){
    $edit = 1;
  }
  if ($tag =~ m/^q(.*)/){
    $q = 1;
  }
  if ($tag =~ m/^p(.*)/){
    $p = 1;
  }
}

#main loop
while (my $line = <$infh>) {
  ++$i;
  chomp $line;
  $line = SuperChomp($line) if ($p);
  @tmp = split /\t/, $line;
  if ((@tmp == 2) || $ignore) {
    print $outfh ">$tmp[0]\n";
    $sequence = $tmp[1];
    $sequence =~ s/\-//g if ($edit);
    @sequence = split //,$sequence if (!$q);
    @sequence = split / /,$sequence if ($q);
    while ( scalar @sequence > $seqend ) {
      my @seq = splice @sequence,0,$seqend;
      $line = join "",@seq if (!$q);
      $line = join " ",@seq if ($q);
      $line .= ' ' if ($q);
      $line =~ s/ {2,}/ /g;
      print $outfh "$line\n";
    }
    $line = join "",@sequence if (!$q);
    $line = join " ",@sequence if ($q);
    $line .= ' ' if ($q);
    $line =~ s/ {2,}/ /g;
    print $outfh "$line\n";
    ++$x;
  }
  #ignores title lines, comments, etc
  elsif ($tmp[0] =~ m/^\#/){} 
  elsif ($tmp[0] =~ m/^\=/){}
  elsif ($tmp[0] =~ m/^\*/){
    print $outfh ">$line\n\n";
  }
  else{
    if (@tmp > 2) {
      die "ERROR!  Too many columns at line: $i\nLine: $line\n";
    }
    else{
      die "ERROR!  Too few columns at line: $i\nLine: $line\n";
    }
  }
}
print STDERR "\nNumber of sequences converted to FASTA format: $x\n";

# Removes ALL newlines and carriage returns from a string.  Also removes tabs and spaces from end of string.
sub SuperChomp{
  my ($string) = @_;
  my $gone = 0;
  $string =~ s/\n//g;
  $string =~ s/\r//g;
  until ($gone){
    $gone = 1;
    if ($string =~ s/ +$//){
      $gone = 0;
    }
    if ($string =~ s/\t+$//){
      $gone = 0;
    }
  }
  return $string;
}
