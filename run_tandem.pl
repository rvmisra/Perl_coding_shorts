#!/usr/bin/perl -w
#+++
#   Version 1.0
#  	Authors: Mike Galligan and Tim Radabaugh
#
#   Description:  This script prompts the user for a directory path, base file
#     name, and the beginning and end file numbers for a series of files to
#     process and creates a temporary input file Tandem will use for the search.
#     This is repeated for each file.
#
#	  Modification History:  written 04.08.05
#
#   Requirements
#     1. run_tandem_file.xml must be in directory this program executed in.
#---
use Getopt::Long;

$dataBase     = $ARGV[0];    # label in taxonomy file that points to database
$dirPath      = $ARGV[1];    # directory name the user files are in

opendir(Dir, "$dirPath") or die "Cannot open $dirPath\n";

GetOptions( "inputfile=s"=>\$inputXmlFile);


while ($fileName = readdir(Dir)) {
  if ($fileName =~ /\.dta/) {
    ModifyInputFile();
    system("tandem rt_input_template.xml");
  }
}


#+++
# This routine takes the base file name and combines it with file number
# ($NumberOfFiles) and writes the result into the input_template file along
# with an output file name. Tandem looks in the input_template file for it's
# user designated input and output path.
#---
sub ModifyInputFile {

  open (TEMPFILE, ">rt_input_template.xml") or die
    print "ERROR! rt_input_template.xml could not be opened!\n";

  if ($inputXmlFile) { open (INPUT,"<$inputXmlFile") or die
    print "ERROR! Could not open $inputXmlFile!\n";
  }
  else{ open (INPUT,"<run_tandem_file.xml") or die
    print "ERROR! Could not open run_tandem_file!\n";
  }
    

  $InputLine = <INPUT>; #  read the first line
  
  # scan input_template.xml for the lines we need to modify
  # we identify these lines by unique text they are known to contain.

  while (not eof) {
    if ($InputLine =~ m/tag1/)
        {print TEMPFILE "\t<note type=\"input\" label=\"protein, taxon\">".
        $dataBase."</note>\n";}
    elsif ($InputLine =~ m/tag2/)
        {print TEMPFILE "\t<note type=\"input\" label=\"spectrum, ".
        "path\">$dirPath\\".$fileName."</note>\n";}
    elsif ($InputLine =~ m/tag3/)
        {print TEMPFILE "\t<note type=\"input\" label=\"output, ".
        "path\">$dirPath\\".substr($fileName, 0, (length($fileName) - 4)).
        "_out.xml"."</note>\n";}
    else
        {print TEMPFILE "$InputLine";}
        
    $InputLine = <INPUT>;  # get the next line in the file
  }

  print  TEMPFILE "$InputLine"; # prints the last line to the temporary file
  
  close TEMPFILE;
  close INPUT;
}



