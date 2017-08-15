#!/usr/local/bin/perl
#
# This program will read in a fastA file and create a new

# fasta file that is its reverse complement.

# USAGE: perl reverseFasta.pl -fn [FILENAME]

 

use Getopt::Long;

 

&GetOptions("fn=s" => \$fileName);

 

sub reverseComplement {     # SUBROUTINE DEFINITION TO 

   $tmpSeq = $_[0];         # CREATE THE REVERSE COMPLEMENT

                            # OF A SEQUENCE

   $seqRC = "";

   $strLen = length($tmpSeq);

 

   for($I = ($strLen-1); $I >= 0; $I--) {

       $tmpStr = substr($seq, $I, 1);

       if($tmpStr eq "A")    { $seqRC .= "T"; }

       elsif($tmpStr eq "C") { $seqRC .= "G"; }

       elsif($tmpStr eq "G") { $seqRC .= "C"; }

       else                  { $seqRC .= "A"; }

   }

   return($seqRC);

}

 

$seq = "";

open(INFILE, "$fileName");          # open a file for reading

 

$description = <INFILE>;            # retrieve the fasta description

chomp($description);                # remove the "\n"

 

while($line = <INFILE>) {

   chomp($line);                    # remove the "\n"

   $seq .= $line;

}

 

close(INFILE);

 

$newSeq = reverseComplement($seq);  # CALL THE SUBROUTINE

 

$newDesc = $description . " -- REVERSE COMPLEMENT ";

 

$newFileName = ">" . $fileName . ".RC";

open(OUTFILE, $newFileName);        # open a file for writing

print OUTFILE ("$newDesc\n");       # print the seq descriptor

 

$len = length($newSeq);             # This time, we will write

$numLines = $len / 60;              # 60 characters per line

if(($len % 60) != 0) { $numLines++; }

 

for($i = 0; $i < $numLines; $i++) {

   print OUTFILE substr($newSeq, $i * 60, 60), "\n";

}

close(OUTFILE);                     # close the new data file

 
