#!/usr/local/bin/perl

#######################################################################
##
#######################################################################

##  Define Variables
#######################################################################

##  Path Preferences
$path_to_excel_file  = "C:\Perl\bin\Book3.xls";
$path_to_output_file = "C:\Perl\bin\Book3_out.xls";

##  Begin Program
#######################################################################

use Spreadsheet::ParseExcel;

do_main();

##  Subroutines
#######################################################################

sub do_main
{
  my ($oBook, $iR, $iC, $oWkS, $oWkC);
  $oBook = Spreadsheet::ParseExcel::Workbook->Parse($path_to_excel_file);
  open(FILE_OUT, "> $path_to_output_file");
  foreach my $oWkS (@{$oBook->{Worksheet}})
  {
    for (my $iR = $oWkS->{MinRow}; defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ; $iR++)
    {
      print FILE_OUT "   [[" . $oWkS->{Cells}[$iR][1]->Value . "]]: " . $oWkS->{Cells}[$iR][2]->Value . "\n";
    }
  }
  close(FILE_OUT);
}
