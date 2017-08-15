#!/usr/local/bin/perl
# Copyright (C) 1998 Andrew Loree
# $Id: chext.pl,v 1.1.1.1 2003/10/05 21:51:29 andy Exp $
############################################################################
#
# chext - Change file extenstions to 'ext', appending them to the end of the
#         file. Optionally, all other extension can be dropped.  Type 
#         'chext' at the shell prompt for specific usage
#
############################################################################
$version = "1.0";

if ($#ARGV < 1){   # Check arguments
  print <<END_of_usage;
usage: chext [-d] \'FASTA\' files
version $version
Changes file extension to \'FASTA\', by appending to the end of the file.  The \'FASTA\' should not contain a \'.\'

  -d    Optionally, drop all other extensions, and then replace them with
        \'FASTA\'

Copyright (c) 1998, Andrew Loree
END_of_usage

  exit(-1);
}

if ($ARGV[0] eq "-d"){
  $opt_d = 1;
  shift(@ARGV);    
}


$fasta = $ARGV[0];     # Process the extension
if ( $ext !~ /^\./ ){
  $fasta = ".$fasta";    # Add . at the begining if needed
}

# Remove the first ARGV, it's the ext
shift(@ARGV);

foreach $old_filename (@ARGV){                     # Process the files
  if (-f $old_filename){
    if ($opt_d){                                   # Drop all other extensions
      $new_filename = $old_filename;
      if ( $old_filename !~ /\./ ){                    
	$new_filename = $old_filename . $fasta;
      }
      else{
	$new_filename =~ s/\.(.*)/$fasta/;
      }  
    }
    else{
      $new_filename = $old_filename . $fasta;
    }
    if ($new_filename eq $old_filename){            # Don't bother if same name
      next;
    }
    if (-f $new_filename){                          # New file already exists
      print "The file \'$new_filename\' already exists. Replace it [y|n] ?";
      $answer = <STDIN>;
      if ($answer !~ /^y/i){
	next;                 # Next file
      }
    }
    if (rename($old_filename, $new_filename) == 0){
      print "Unable to rename $old_filename to $new_filename\n";
    }
  }
  else{
    print "Invalid filename: $old_filename\n";
  }
}    
