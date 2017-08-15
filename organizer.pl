#/usr/local/bin/perl -w
# Script for running dtaselect on multiple dir in a given location
# filter.pl ver 0.99b April 12 2004
# Nirav Merchant nirav@arl.arizona.edu
# Needs activstate perl on PC
use strict;
use Spreadsheet::WriteExcel;
use Getopt::Long;
use File::Spec;
# Location of dtaselect batch file which calls actual Java program
my $dtaselect = "c:\\dtaselect\\dtaselect --here";
# my $dtaselect = "c:\\temp\\dtaselect\\dtaselect --here";
# The 3 types of arguments given to dtaselect program.
# Creating hash to store that
my %option = (
                "low" => " -1 1.5 -2 2.0 -3 3.0 -d 0.05 -y 1 -p 1",
                "high" => " -1 1.8 -2 2.5 -3 3.5 -d 0.08 -y 1 -p 1",
                "vhigh" =>" -1 1.8 -2 2.5 -3 3.5 -d 0.1 -y 2 -p 2",
                "none" => " "
                );
# Command line args is the parent dir where the sub dir (one deep) with
# sequest output for dtaselect to process are located
my $usage = "$0 -type (low|high|vhigh|none) -loc (Full path to directory with sequest output)\n
Optional args: -ext (dir name mask to use i.e lm2129*)
               -excel (filename to save results)\n
               -- any options to be given to dtaselect e.g -- -l artifact\n";
# option variable with default value
my ($loc,$type,$excel_file,$dta_args,$dta_opt_args,$ext);
#Set some defaults for extension to look for and excel file to save data
#If user supplies them on command line these get over written
$ext = "*";
$excel_file = "results.xls";
         GetOptions ('loc=s' => \$loc, 'type=s' => \$type ,
         'excel:s'=> \$excel_file, 'ext:s'=>\$ext  );
# Basic error checking for input
# Making type lowercase for correct matching
# If user provides args after -- it will be appended to the option
$dta_opt_args = join(" ",@ARGV);
my $type = lc($type);
if (exists($option{$type})) { $dta_args = $option{$type} . " ". $dta_opt_args; }
      else { die "Error: Unkown value $type for Type\n\n$usage" ;}
# Check to see of directory to start exists
if ( !-d $loc )  { die "Error: Cannot find location: $loc\n\n$usage" ; }
          else {
          #Making file path operating system safe.
                $loc = File::Spec->canonpath($loc);
          }
# Optional file name to save final excel tabulations else goes to results.xls
  if(!File::Spec->file_name_is_absolute( $excel_file )) {
# If file is not full path then we will save it to the directory where files
# from sequest are located
      $excel_file = $loc. "/$excel_file";
   }
   # No filename for excel specified: use default results.xls
      else     { $excel_file = $loc."/$excel_file";
                          }

###########################################################3

# List all files using glob and provided extension
my @files = glob("$loc/$ext");
# Create a empty workbook
my $workbook   = Spreadsheet::WriteExcel->new("$excel_file") or
die "Cannot create spreadsheet $excel_file";

# Keep a log of what dtaselect saw in each subdir
my $trace = "> trace.txt";
# Array to store directory names
my @dir;
foreach my $f (@files) {
# See if the list contains a directory
if (-d $f) { 
	  push (@dir,$f);
#Change dir to where we need to run dtaselect
# We called it with --here it will process files in that dir
		chdir("$f");
		print "Running dtaselect in $f\n";
		print "$dtaselect  $dta_args $trace\n";
my $out = system("$dtaselect  $dta_args $trace") ;
    if($out != 0) { die "Error running $dtaselect" }
#Go back to main directory
	  chdir("$loc");
# If dtaselect run was success we will have a output filter file
# dtaselect-filter.txt and it is tab dilimited
if( -e "$f/dtaselect-filter.txt") {
		my $sheet = $f;
		open( TABFILE, "$sheet/dtaselect-filter.txt") or
    die "cannot open dtaselect-filter.txt in $sheet";
#Since we use full path name and we want the directory name to be Worksheet name
# We will split on / or \ to respect unix and windows style of path
    my @name =split(/\/|\\/,$sheet);
# The last element will be the name
  $sheet = pop(@name);
    print "CREATING WORKSHEET: $sheet\n";
	my $worksheet = $workbook->add_worksheet($sheet);
#Now work through the dtaselect-filter.txt file
# Move its data into excel rows and columns
		my $row = 0;
		
		while (<TABFILE>) {
		    chomp;
		    # Split on single tab
		    my @Fld = split('\t', $_);
		
		    my $col = 0;
		    foreach my $data (@Fld) {
		    
		   $worksheet->write($row, $col, "$data") ;
		        $col++;
		    }
		    $row++;next;	} # end while
		    
		    close(TABFILE);
		    
		    } else { print "WARNING: Failed dtaselect run\n";}	# end if -e		
				
				
 } # end if -d

	} # end foreach
#No we are done print some statistics
my $all = join("\n",@dir);
my $count = scalar(@dir);
if($count==0) { die "Did not find any directories matching $ext in $loc\n";}
$workbook->close();
print "######\nWorked on $count Directories:\n$all\n";
print "\n\t ==>Saved Collated Results to: $excel_file \n\n######\n";

