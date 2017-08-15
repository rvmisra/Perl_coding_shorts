#!/usr/local/bin/perl -w
#
# 	usage: xtandem_prep.pl -a -d DTA-select.txt -m -c [Yy/Nn]
#
#	author: Patrick Degnan updated: 121204
# Modified by Nirav@arl.arizona.edu to add Windoz comptability
# and some command line defaults   011605
#
# Modified by sjmiller@email.arizona.edu  20 oct 05
#  Add -mult flag to indicate that subdirectories are treated as separate groups
##
use File::Copy;		#Copy PERL Module
use Getopt::Long;
use Cwd;

##
## Set file name variables to suit you
$inexcel="inexcel";
$singlexcel="singlexcel";
$notinexcel="notinexcel";

## DO NOT reset these variables!!
$path = cwd;
chomp($path);
$have_summaryfile="F";
$have_name="F";
$header="F";
$comp='N';

## Print command line options

unless(defined(@ARGV)){
    print STDERR "Usage: $0 [options]\nOptions are:\n";
    print STDERR "\t-a\tUse default file name DTASelect-filter.txt\n";
	print STDERR "\t-d\tProvide Equivalent DTASelect-filter.txt file\n";
	print STDERR "\t-m\tTreat subdirectories as multiple groups.\n";
	print STDERR "\t-w\tPrint warning messages for missing files.\n";
	print STDERR "\t-c\tCompress [Yy] or [Nn] [IF TAR and GZIP not available-DO NOT USE Y ON WINDOWS]";
	exit;
}

GetOptions(	"auto:s"=>\$auto,"dtafile:s"=>\$dta,"mult"=>\$mult,"compress=s"=>\$comp,"warn"=>\$warn);
if(defined $auto) {$dta = "DTASelect-filter.txt";
                    print STDERR "Using default file name $dta\n"; }
			
# @subd will be list of subdirectories and . (excluding $inexcel, etc.)
@subd = ('.');
@files = glob("*");
  foreach $f (@files) {
  if (-d $f && $f !~ "$inexcel" && $f !~ "$notinexcel" && $f !~ "$singlexcel") {
    push @subd, $f;
  }
}

foreach $dir (@subd) {
    print STDERR "Searching directory \'$dir\' ...\n";
    if (! -f "$dir/$dta") {
	  if ($mult) {
        print STDERR "\tNo DTASelect file $dir/$dta - skipping to next subdirectory.\n";
      }
      next;
    }
   
    open(DTA, "<$dir/$dta") or die "Cannot open file $dir/$dta\n";

    while($line=<DTA>) {
	    chomp($line);

##	Get the name of the run from top of the DTASelect-filter.txt
##	Then open the 3 new files for concatenated mass specs
##
	    if ($line=~/^[A-Z]\:\\/ && $have_name eq "F") {
		    @getname=split(/\\/,$line);
		    $len=@getname;
		    $run_name=$getname[($len-1)];
		    $run_name =~ s/\s//g;
		    $have_name="T";
			
		    print STDERR "The run name is [$run_name]\n"; 	##debug
			if ($mult || $dir eq '.') { 
			    print STDERR "Making $dir/$inexcel, etc\n";
                mkdir("$dir/$inexcel");		##Making the three subdirectories
                mkdir("$dir/$singlexcel");
                mkdir("$dir/$notinexcel");
		        open(INE,">$dir/$run_name.$inexcel.ta") or die "Cannot open $dir/$run_name.$inexcel.ta";
		        open(SIE,">$dir/$run_name.$singlexcel.ta") or die "Cannot open $dir/$run_name.$singlexcel.ta";
		        open(NIE,">$dir/$run_name.$notinexcel.ta") or die "Cannot open $dir/$run_name.$notinexcel.ta";
	            $have_summaryfile = "T";
				$destdir = $dir;
			}
			if ($have_summaryfile eq "F") {
                mkdir("$inexcel");		##Making the three subdirectories
                mkdir("$singlexcel");
                mkdir("$notinexcel");
			    open(INE,">$run_name.$inexcel.ta") or die "Cannot open $run_name.$inexcel.ta";
		        open(SIE,">$run_name.$singlexcel.ta") or die "Cannot open $run_name.$singlexcel.ta";
		        open(NIE,">$run_name.$notinexcel.ta") or die "Cannot open $run_name.$notinexcel.ta";
	            $have_summaryfile = "T";
				$destdir = '.';
			}
	    }

	    @columns=split(/\t/,$line);
##
##	Script skips top lines of DTASelect-filter.txt file until it finds the header line
##	(i.e. we don't want to try and start moving the files until we have filenames to move)
##
	    #print "cols[0] is $columns[0]\n";
	    #print "header is $header\n";
	    if (defined $columns[0] && $columns[0]=~ "Unique" && $header eq "F") {
	  	    $header="T";
		    #print "I have hit the header line: [$header]\n"	##debug
	    } elsif ($header eq "T") {
		
##
##	Now that $header is true we start getting ready to move files based on the number of hits 
##	there are to any given protein from the  database
##
		    $len=@columns;
		    if ($len == 9 ) {
			    $num_dtas=$columns[1];
			    print "For protein [$columns[0]] there are [$columns[1]] files\n"; 	#debug
##
##	These lines with 9 columns are Protein match lines and tell us how many hits there are to that protein
##		
		    } elsif ($len == 12) {
##
##	Lines with 12 columns have the *dta files in their second column [1]
##	Make the decision if it should be moved to the $singlexcel if there is only one hit
##	OR to the inexcel when there are multiple hits
##	
			    $file_name="$columns[1].dta";
			    $file_name =~ s/\s//g;
			    #print STDERR "file $dir/$file_name!\n";
			    $base_name = $file_name;
			    if (! -f "$dir/$file_name") {
                    @f = split(/\./,$file_name);
                    $file_name = "$f[0]/$file_name";
		         	#print STDERR "Newfile $file_name\n";
                    if (!-f "$dir/$file_name") {
                        if (defined $warn) {
						    print STDERR "Warning: Cannot find $dir/$file_name - skipping\n";
                        }
						next;
                    }
                }
 
			    if ($num_dtas == 1) {
			    	#print "Singleton[$file_name]\t[$num_dtas]\n";	#debug
				
				    &Write(SIE,"$dir/$file_name",%Multi_hit);				#subroutine to write to concatenated file
				    if (defined($Multi_hit{$file_name})) {
				    	if (!copy("$path/$dir/$inexcel/$base_name","$destdir/$singlexcel/$base_name")) {
                            print STDERR "Copy to $destdir/$singlexcel/$base_name failed:$!\n";
                        }
			    	} else {
					    if (!rename "$dir/$file_name", "$destdir/$singlexcel/$base_name") {
                            print STDERR "Rename to $destdir/$singlexcel/$base_name failed: $!\n";
                        }
				    }
				
				    #print "Moving SNGL $file_name\n";	#debug
			    } else {
				    #print "Not Singleton[$file_name]\t[$num_dtas]\n";
				    $Multi_hit{$file_name}=T;
				    &Write(INE,"$dir/$file_name",%Multi_hit);				#same subroutine call
				    #print "Moving NS $destdir/$file_name\n";	#debug
				    if (!rename "$dir/$file_name", "$destdir/$inexcel/$base_name") {
         		        print STDERR "Rename to $destdir/$inexcel/$base_name failed: $!\n";
        		    }
			    } #end num_dtas != 1	
		    } #end $len == 12
	    } else { next; }  #end header eq "T
	} # end while $line = <DTA>
    close(DTA);

##
##	Time to move the rest of the *dta files to the $notinexcel
##

	if (!$mult) {
	  splice(@last_to_move);
      foreach $f (@subd) {
        push @last_to_move, glob("$f/*.dta");
      }
	} else {
      @last_to_move=glob("$dir/*.dta");
	}
    #print STDERR "ltm is @last_to_move\n";
  
    foreach $extra (@last_to_move){
	    &Write(NIE,$extra,%Multi_hit);			#subroutine call
	    $extra2 = $extra;
	    $extra2 =~  s/.*\///;
        #print "Moving extra $extra to $destdir/$notinexcel/$extra2\n";
	    if (!rename $extra, "$destdir/$notinexcel/$extra2") {
            print STDERR "Rename to $destdir/$notinexcel/$extra2 failed: $!\n";
        }
    }

##
##	Clean up files: rename concatenated files and if Compression requested ... do so
##
    if ($mult) {
	    #print "CLOSING INE,SIE,NIE\n";
	    close(INE);
        close(SIE);
        close(NIE);
		$have_summaryfile="F";
        $have_name="F";
        $header="F";
    } 
} #end foreach $subd
close(INE);
close(SIE);
close(NIE);


foreach $dir (@subd) {
    print STDERR "Renaming .ta files in $dir to .dta\n";
	@ta = glob("$dir/*.ta");
	foreach $tfil (@ta) {
	  $dta = $tfil;
	  $dta =~ s/ta$/dta/;
      if (!rename "$tfil", "$dta") {
        print STDERR "Rename failed: $!\n";
      }
	}

    if ($comp=~/[Yy]/) {
	    if (-d "$dir/$inexcel") {
	        system("tar cvf $dir/$inexcel/in.tar $dir/$inexcel/*dta");
	        system("gzip $dir/$inexcel/in.tar");
		}
	    if (-d "$dir/$singlexcel") {
	        system("tar cvf $dir/$singlexcel/single.tar $dir/$singlexcel/*dta");
	        system("gzip $dir/$singlexcel/single.tar");
		}
	    if (-d "$dir/$notinexcel") {
	        system("tar cvf $dir/$notinexcel/notin.tar $dir/$notinexcel/*dta");
	        system("gzip $dir/$notinexcel/notin.tar");
		}
	    #system("rm $dir/*excel/*dta");  # This is dangerous!  Uncomment if you are brave.
    }
}
if ($comp=~/[Yy]/) {
    print STDERR "Files have been tarred and compressed - verify that .gz files are OK and you may remove the original .dta files\n";
}

##
##	[Write] subroutine writes *dta to particular concatenated file
##

sub Write{

	my ($out_file,$dta_file,%More_than_one)=@_;
	
	my $end = $dta_file;
	$end =~ s/.+\///;
	if ($out_file eq "SIE" && defined($More_than_one{$dta_file})) {
		
		##	CASE defined for peptides hitting multiple proteins 1 and >1.
		##
		#print "[$dta_file] is singleton, is already in $inexcel\n";  	##debug
		#print "[$out_file] is SIE\n";	#debug
		open(IN,"<$path/$dir/$inexcel/$dta_file") or die "Cannot open $path/$dir/$inexcel/$dta_file\n";
		$line=<IN>;
		chomp($line);
		print $out_file "$line $end\n";
		while ($line=<IN>) {
			chomp($line);
			print $out_file "$line\n";
		}
		print $out_file "\n";
		close(IN);	
		
	} else {
		if (-e "$dta_file") {
			#print "[$dta_file] is not singleton to go in $inexcel\n";
			open(IN,"<$dta_file") or die "Cannot open $dta_file\n";
			$line=<IN>;
			chomp($line);
			print $out_file "$line $end\n";
			while ($line=<IN>) {
				chomp($line);
				print $out_file "$line\n";
			}
			print $out_file "\n";
			close(IN);
		}
	}	

}


