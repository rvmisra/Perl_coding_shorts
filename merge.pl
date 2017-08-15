#!/usr/local/bin/perl
##############################################################################
# Merge all .PKLs and .DTAs in current directory into single MGF             #
##############################################################################
# COPYRIGHT NOTICE                                                           #
# Copyright 2002 Matrix Science Limited  All Rights Reserved.                #
#                                                                            #
# This program may be used and modified within the licensee's organisation   #
# provided that this copyright notice remains intact. Distribution of this   #
# program or parts thereof outside the licensee's organisation without the   #
# prior written consent of Matrix Science Limited is expressly forbidden.    #
##############################################################################
#    $Archive:: /www/bin/merge.pl                                          $ #
#     $Author: johnc $ #
#       $Date: 2010-04-08 16:06:35 $ #
#   $Revision: 1.2 $ #
# $NoKeywords::                                                            $ #
##############################################################################

  open(OUTFILE,">merge.mgf") || die "cannot create merge.mgf";

  while(defined($fileName = glob("*"))){
    if ($fileName =~ /\.dta$/i) {
      open(INFILE,"<$fileName");
      $_ = <INFILE>;
      chomp;
      ($MH, $Z) = split(/\s+/, $_);
      if ($MH && $Z) {
        print OUTFILE "BEGIN IONS\n";
        $MoverZ = ($MH + ($Z - 1) * 1.007276) / $Z;
        print OUTFILE "TITLE=$fileName\n";
        print OUTFILE "CHARGE=$Z+\n";
        print OUTFILE "PEPMASS=$MoverZ\n";
        while (<INFILE>) {
          if (/\d+/) {
            print OUTFILE $_;
          }
        }
        print OUTFILE "\nEND IONS\n\n";
      }
      close INFILE;
    } elsif ($fileName =~ /\.pkl$/i) {
      open(INFILE,"<$fileName");
      $gotHeader = 0;
      $queryNum = 1;
      while (<INFILE>) {
        if ($gotHeader) {
          if (/\d+/) {
            print OUTFILE $_;
          } else {
            $gotHeader = 0;
            print OUTFILE "\nEND IONS\n\n";
          }
        } else {
          chomp;
          ($MoverZ, $junk, $Z) = split(/\s+/, $_);
          if ($MoverZ && $Z) {
            $Z = int($Z);
            print OUTFILE "BEGIN IONS\n";
            print OUTFILE "TITLE=$fileName (query $queryNum)\n";
            print OUTFILE "CHARGE=$Z+\n";
            print OUTFILE "PEPMASS=$MoverZ\n";
            $queryNum++;
            $gotHeader = 1;
          }
        }
      }
      if ($gotHeader) {
        $gotHeader = 0;
        print OUTFILE "\nEND IONS\n\n";
      }
      close INFILE;
    }
  }
  close OUTFILE;
