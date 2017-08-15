#!/usr/bin/perl -w

########################################################################
# Script Name:  true_match.pl
# Purpose:      Find true match in the blast results
# Last Updated: 11-07-2004   
#
# What's New:    
#
# Revision:     Based on avg-new-terminus4.lastest.pl
#
# Author:       Weixi Li
# E-mail:       wli2@uky.edu
# Tel:          (859)257-2161
# Address:      200 T.H. Morgan Building
#               Department of Biology
#               University of Kentucky
#               Lexington, KY 40506
#
# *Copyright 2004* All rights reserved.
########################################################################

use Getopt::Long qw(GetOptions);
use strict;
use Bio::SearchIO;
use constant TRUE   =>  1;
use constant FALSE  =>  0;
use constant OK     =>  1;
use constant FAILED =>  0;
use constant SEQ_LINE_FMT  => 60; 
use Fcntl qw/O_RDONLY O_WRONLY O_CREAT O_EXCL/;
use POSIX qw/tmpnam ceil/;

## set umask to avoid granting excessive permissions
umask 027;

## turn on autoflush
select STDOUT; $| = 1; 
my $oldfh = select STDERR; $| = 1; select $oldfh;

## Default Values
## NOTE: these are not real locations on genome server
#        Change this when making cgi script.
my %defaults = ( formatdb                   => '/usr/local/blast/formatdb', 
                 blast                      => '/usr/local/blast/blastall',
                 query_file                 => 'queries.fst', #cc  #contig file
                 subject_file               => 'subjects.fst', #cc  #contig file
                 query_coverage_threshold   => 50,
                 blast_identity_cutoff      => 95,
                 max_hits_to_be_reported    => 5,
                 min_length_for_a_region    => 50,
                 blast_exp_value            => '1E-100', #cc
                 db_preformatted            => FALSE,   #cc
                 blastdb_dir                => '/usr/local/blast/db/',
               );

my %truefalse = ( 1 => 'TRUE', 0 => 'FALSE');
my %yesno = ( 1 => 'yes', 0 => 'no');

## Certain sequence leads to BLAST error
## use this options to exclue those
my %excluded_seqs = (#'PS25' => undef,
                    );  #cc #change this only when you have BLAST error

## Global & actually constants
my $max_tries    = 60; ## max tries to create a dir with unique name
my $path         = '/bin:/usr/bin:/usr/local/bin:/usr/local/blast/bin';


my $hits_excluded_summary           = 'hits_excluded.xls';
my $true_match_summary              = 'true_match_results.xls';
my $raw_blast_result                = 'blast_full_raw_result';
my $raw_blast_tabular_result        = 'blast_tabular_raw_result';
my $analysis_log                    = 'analysis.log';
my $query_seqs_excluded_file        = 'query_excluded.fst';
my $subject_seqs_excluded_file      = 'subject_excluded.fst';
my $query_seqs_final_file           = 'query_final.fst';
my $subject_seqs_final_file         = 'subject_final.fst';
my $temp_db_name                    = 'tempdb';

my $blast_max_alignments    = '5000';  #cc
my $blast_filter            = 'F'; # or 'T' 
#my $blast_strand_top        = '1';  ## blast the top strand of query seq 
#my $blast_strand_bottom     = '2';  ## blast the bottom strand of query seq
my $blast_program           = 'blastn';
#my $blast_cpu_number        = '4';

my $merge_threshold = 0; #cc if the gaps in subj and query are both within this range, the two blast hits will be merged.
                 
#my $base_coverage_threshold           = 1; #cc  ## set to 1 == unique hits only
#my $unique_region_len_threshold       = 50; #cc

## Global Variables  

my %query_seqs;
my %subject_seqs;
my %ori_subject_names;

my $formatdb;
my $blast;
my $query_file;
my $subject_file;
my $blast_db_name;
my $query_coverage_threshold;
my $blast_identity_cutoff;
my $max_hits_to_be_reported;
my $min_length_for_a_region;
my $blast_exp_value;
my $db_preformatted;
my $blastdb_dir;

my $oldeol;

my $resultdir;

## set secure env
$ENV{PATH} = $path;
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};

########################################################################
# Usage
########################################################################
sub Usage {

print <<USAGE;

Usage: $0 [-h][-v] 

Requirements: 1. standalone BLAST (blastall) from NCBI (www.ncbi.nlm.nih.gov)
              2. formatdb from NCBI (www.ncbi.nlm.nih.gov) if you don't 
                 a preformatted database

Description:  This script will find the true matches from the query sequences to
              the target sequences, even if those matches were not shown as top hits
              in the original BLAST search.
              User will be prompted to enter the required information step by step.

Options:

    -h, --help:     Help
    -v, --verbose:  Verbose information

USAGE

}

sub numerically { $a <=> $b }

########################################################################
# Command Line Args
########################################################################
my $help = 0;
my $verbose = 0;

GetOptions( 'help'          => \$help,
            'verbose'       => \$verbose, 
          );

Usage();
exit (0) if $help;

_pause();

########################################################################
# Main Process
########################################################################

while (1) {
    display_menu();
    print "Enter your choice[1-2]: ";
    $_ = <STDIN>;
    _trunc();
    print "\n\n";
    if ($_ ne '1' && $_ ne '2') {
        print "\"$_\" is not a valid choice! Please try again.\n\n";
        next;
    }

    if ($_ eq '1') {

        ## Main Process

        print "########################################################################\n",
              "  Please provide the information asked, default answer is in the brackets.\n",
              "  If you are not sure about an answer, simply hit <ENTER> to continue. \n",
              "  You may return to the main menu at anytime by entering -1.\n",
              "########################################################################\n\n";
        
        _pause();

        make_resultdir()    or next;
        get_query_file()    or rm_resultdir() and next;
        get_subject_db()    or rm_resultdir() and next;
        unless ($db_preformatted) {
            get_subject_file()  or rm_resultdir() and next;
            get_formatdb()      or rm_resultdir() and next;
        }
        get_blast()                     or rm_resultdir() and next;
        get_blast_exp_value()           or rm_resultdir() and next;
        get_blast_identity_cutoff()     or rm_resultdir() and next;
        get_query_coverage_threshold()  or rm_resultdir() and next;
        get_max_hits_to_be_reported()   or rm_resultdir() and next;
        get_min_length_for_a_region()   or rm_resultdir() and next; 

        get_confirmation()  or rm_resultdir() and next;

        ## Execute scripts ...... 
        print "\nNow sit back and relax ... the analysis is in progress ... \n\n";
        sleep 1;

        ## create tmp dirs
        
        ## make blastable database
        unless ($db_preformatted) {
            make_database() or rm_resultdir() and next;
        }

        run_blast()         or rm_resultdir() and next;
        analyze_blast_result()     or rm_resultdir() and next;
        sleep 1;
        print "\nAll analysis tasks finished.\n\n";
        sleep 1;

        print "Results: see directory <$resultdir>.\n\n";

        _pause();

        %query_seqs = ();
        ## End of Main Process
    } else {
        last;
    }
    print "\n";
}
        
print "Thanks for using this script.\n\n";

## End of the main program

sub display_menu
{
    print "\n";
    print "************************************* \n".
          "*             Main  Menu            * \n".
          "*-----------------------------------* \n".
          "*  1. start/restart the script      * \n".
          "*  2. Exit                          * \n".
          "************************************* \n";
    print "\n";
}

sub trunc
{
    my $line = $_[0];
    $line =~ s/^\s+//;
    $line =~ s/^\'+//;
    $line =~ s/^\"+//;
    $line =~ s/\s+$//;
    $line =~ s/\'+$//;
    $line =~ s/\"+$//;
    return $line;
}

sub _trunc
{
    s/^\s+//;
    s/^\'+//;
    s/^\"+//;
    s/\s+$//;
    s/\'+$//;
    s/\"+$//;
}



sub make_resultdir
{
    print "Creating results directory ... ";
    $resultdir = '';
    my ($min, $hour, $mday, $mon, $year);
    my $count = 0;
    my $resultdirprefix = 'trumatch'; #cc
    ($resultdirprefix) = $resultdirprefix =~ /^([^.]+)/;
    while (1) {
        ($min, $hour, $mday, $mon, $year) = 
            (localtime)[1..5];
        $min = ($min + $count) % 60;
        $year += 1900;
        $mon  += 1;
        $mon  = sprintf "%02d", $mon;
        $min  = sprintf "%02d", $min;
        $hour = sprintf "%02d", $hour;
        $mday = sprintf "%02d", $mday;
        $resultdir = "$resultdirprefix-$year-$mon-$mday-$hour:$min";
        unless (-d $resultdir) {
            if (mkdir $resultdir) {last;}
            $resultdir = $ENV{HOME}.'/'.$resultdir;
            unless (-d $resultdir) {
                mkdir $resultdir 
                    or  print "[FAILED]\n"
                    and print STDERR "ERROR: Failed to create result directory!\n\n"
                    and return FAILED;
                last;
            }
        }
        $count++;
        if ($count > $max_tries) {
            print "[FAILED]\n";
            print STDERR "ERROR: Failed to create result directory!\n\n";
            return FAILED;
        }
    }
    $resultdir = $resultdir."/";

    my $file = $resultdir.$analysis_log;
    sysopen(LOG, "$file", O_WRONLY | O_CREAT | O_EXCL)
        or print "[FAILED]\n"
        and print STDERR "ERROR: Can't create new file <$file> for writing: $!\n"
        and return FAILED;

    my $oldfh = select LOG; $| = 1; select $oldfh;

    _print_OK();
}

sub get_query_file
{
    $query_file = '';
    my $_query_file;

    print LOG "*** Getting query sequences ***\n";

    while (1) {
        $_query_file = $defaults{query_file};
        print "Enter a FASTA file containing the query sequences [$_query_file]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if (/^$/ || /\s/ || /;/ || /\\/) {
                print STDERR "ERROR: Illegal file name \"$_\"! \n\n";
                next;
            }
            ($_query_file) = /^(.+)$/;
        }
        sysopen(FH, $_query_file, O_RDONLY) 
            or print STDERR "ERROR: Can't open file <$_query_file> for reading: $!\n\n"
            and next;
        last;
    }

    print "Validating query file, this may take a while ... ";

    $query_file = $_query_file;
    %query_seqs = ();

    my $line_count                   = 0;
    my $query_seqs_raw_count         = 0;
    my $query_seqs_zero_len_count    = 0;
    my $query_seqs_preexcluded_count = 0;
    my $query_seqs_dupe_count        = 0;
    my $query_seqs_final_count       = 0;

    my $appending = FALSE;
    my $query_len = 0;
    my $query_seq;
    my $query_name; # capped
    my $ori_query_name;
    my $def_line;
    my $new_def_line;

    my $final_query_file = $resultdir.$query_seqs_final_file;
    my $excluded_query_file  = $resultdir.$query_seqs_excluded_file;
    sysopen(FINAL, $final_query_file, O_WRONLY | O_CREAT | O_EXCL)
        or print "[FAILED]\n"
        and print LOG "ERROR: Can't create new file <$final_query_file> for writing: $!\n"
        and return FAILED;

    sysopen(EXCLUDED, $excluded_query_file, O_WRONLY | O_CREAT | O_EXCL)
        or print "[FAILED]\n"
        and print LOG "ERROR: Can't create new file <$excluded_query_file> for writing: $!\n"
        and return FAILED;

    while (TRUE) {
        $_ = <FH>;
        if (defined ($_)) {
            $line_count++;
            #s/^\s+//;
            #s/\s+$//;
            next if $_ eq '';
        }
        if (!defined($_) || />/) {
            if (defined($_)) {
                s/^\s+//;
                s/\s+$//;
                unless (/^>(\S.*)$/) {
                    print LOG "WARNING: Invalid FASTA format found at line $line_count in <$_query_file>. \n".
                              "         The sequence below this line may be incorrectly merged with the previous record.\n".
                              "   line: $_\n\n";
                    next;
                }
                $new_def_line = $1;
                $query_seqs_raw_count++;
                #print LOG "\$1 is: $1\n"; ## weird bug, $1 seems to be local
            }
            if ($appending) { ## process the previous record
                $query_len = length $query_seq; 
                if ($query_len == 0) {    
                    print LOG "WARNING: Zero length sequence found at line $line_count in file <$_query_file>: query_name \"$ori_query_name\"\n\n";
                    $query_seqs_zero_len_count++;
                    print EXCLUDED ">$def_line\n";
                } elsif (exists $query_seqs{$query_name}) {
                    print LOG "WARNING: Duplicated query name \"$ori_query_name\" found at line $line_count in <$_query_file>.\n\n";
                    $query_seqs_dupe_count++;
                    print EXCLUDED ">$def_line\n";
                    print_seq(*EXCLUDED, \$query_seq, 0, $query_len-1);
                } elsif (exists $excluded_seqs{$query_name}) {
                    print LOG "WARNING: Query seq \"$ori_query_name\" was excluded as requested at line $line_count in <$_query_file>.\n\n";
                    $query_seqs_preexcluded_count++;
                    print EXCLUDED ">$def_line\n";
                    print_seq(*EXCLUDED, \$query_seq, 0, $query_len-1);
                } else { ## good ones
                    $query_seqs_final_count++;
                    print FINAL ">$def_line\n";
                    print_seq(*FINAL, \$query_seq, 0, $query_len-1);
                    $query_seqs{$query_name} = { 'len'              => $query_len,
                                                 'seq'              => $query_seq,
                                                 'def_line'         => $def_line,
                                                 'query_name'       => $query_name,
                                                 'ori_query_name'   => $ori_query_name,
                                               };
                }
            }

            if (!defined($_)) {last;}

            $query_len   = 0;
            $query_seq   = '';
            $query_name  = '';
            $ori_query_name = '';

            $def_line = $new_def_line;
            #$def_line =~ s/^\s+//;
            #print LOG "def_line: $def_line\n";

            ($query_name) = $def_line =~ /^(\S+)/;
            $ori_query_name = $query_name;
            $query_name =~ tr/a-z/A-Z/;

            $appending = TRUE;
        } else {
            if ($appending) {
                s/\s+//g;
                $query_seq .= $_;
            }
        }
    }

    close FH    or print LOG "WARNING: Can't close file <$_query_file>: $!\n";
    close FINAL or print LOG "WARNING: Can't close file <$final_query_file>: $!\n";
    close EXCLUDED  or print LOG "WARNING: Can't close file <$excluded_query_file>: $!\n";

    print LOG "Original      query sequences count:  $query_seqs_raw_count\n";
    print LOG "Dupe          query sequences count:  $query_seqs_dupe_count\n";
    print LOG "Zero-lengthed query sequences count:  $query_seqs_zero_len_count\n";
    print LOG "Pre-excluded  query sequences count:  $query_seqs_preexcluded_count\n";
    print LOG "Final         query sequences count:  $query_seqs_final_count\n";
    print LOG "Query sequences excluded  file:       <$query_seqs_excluded_file>\n";
    print LOG "Query sequences final file:           <$query_seqs_final_file>\n";

    print LOG "*** Done getting query sequences ***\n\n";

    _print_OK();
    return OK;
}

sub get_subject_db 
{
    my $_db_preformatted;
    $blast_db_name = '';

    while (1) {
        $_db_preformatted = $defaults{db_preformatted};
        print "Do you have a formatted database for BLAST? [$yesno{$_db_preformatted}]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if ($_ =~ /^Y$/i || $_ =~ /^YES$/i) {
                $_db_preformatted = TRUE;
            } elsif ($_ =~ /^N$/i || $_ =~ /^NO$/i) { 
                $_db_preformatted = FALSE;
            } else {
                print STDERR "ERROR: invalid response \"$_\" \n\n";
                next;
            }
        }

        print "\n";
        last;
    }

    $db_preformatted = $_db_preformatted;
    if ($db_preformatted) {
        # get the directory of the db files

        $blastdb_dir = '';
        my $_blastdb_dir = '';
        my @filenames;

        while (1) {
            $_blastdb_dir = '';
            if (exists $ENV{BLASTDB} && defined $ENV{BLASTDB}) {
                ($_blastdb_dir) = $ENV{BLASTDB} =~ /^([-\/\@\w.]*)$/;
            } else {
                $_blastdb_dir = $defaults{blastdb_dir};
            }
            print "Enter the directory where the blastable database is located [$_blastdb_dir]: ";
            $_ = <STDIN>;
            return FAILED if $_ eq "-1\n";
            if ($_ !~ /^\s+$/) {
                _trunc();
                if ($_ =~ /^([-\/\@\w.]+)$/) {
                    $_blastdb_dir = $1;
                } else {
                    print STDERR "ERROR: illegal directory name \"$_\" \n\n";
                    next;
                }
            }
            unless (-d $_blastdb_dir) {
                print STDERR "ERROR: Directory \"$_blastdb_dir\" does not exist! \n\n";
                next;
            }
            opendir DIR, "$_blastdb_dir/"
                or warn "ERROR: Failed to open dir <$_blastdb_dir>: $!\n"
                and next;
            @filenames = readdir DIR
                or warn "ERROR: readdir on <$_blastdb_dir> failed.\n"
                and next;
            @filenames = grep {!/^\./} @filenames;
            closedir DIR or warn "WARNING: Fail to close dir <$_blastdb_dir>: $!\n";
            unless (@filenames) { 
                warn "ERROR: Directory <$_blastdb_dir> seems to be empty.\n";
                next;
            }

            print "\n";
            last;
        }

        $blastdb_dir = $_blastdb_dir;

        # get the name of the db
        my $_blast_db_name;
        while (1) {
            print "Enter the name of the genome database: ";
            $_blast_db_name = <STDIN>;
            $_blast_db_name = trunc($_blast_db_name);
            return FAILED if $_blast_db_name eq "-1";
            if ($_blast_db_name =~ /^([\w\@-_.]+)$/) {
                $_blast_db_name = $1;
            } else {
                print STDERR "ERROR: \"$_blast_db_name\" is not a valid database name! \n\n";
                next;
            }
            # verify the db name;
            unless (grep {/^\Q$_blast_db_name\E/i} @filenames) {
                warn "ERROR: Database files do not exist for database \"$_blast_db_name\"\n";
                next;
            }
            print "\n";
            last;

        }
        $blast_db_name = $_blast_db_name;
    } 

    return OK;  ## now all the difference will depend on the value of $db_preformatted, 
                ## if it is true, the db_name should be defined at this point
}

sub get_subject_file
{
    $subject_file = '';
    my $_subject_file;

    print LOG "*** Getting subject sequences ***\n";

    while (1) {
        $_subject_file = $defaults{subject_file};
        print "Enter a FASTA file containing the subject sequences [$_subject_file]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if (/^$/ || /\s/ || /;/ || /\\/) {
                print STDERR "ERROR: Illegal file name \"$_\"! \n\n";
                next;
            }
            ($_subject_file) = /^(.+)$/;
        }
        sysopen(FH, $_subject_file, O_RDONLY) 
            or print STDERR "ERROR: Can't open file <$_subject_file> for reading: $!\n\n"
            and next;
        last;
    }

    print "Validating subject sequences file, this may take a while ... ";

    $subject_file = $_subject_file;
    %subject_seqs = ();

    my $line_count                     = 0;
    my $subject_seqs_raw_count         = 0;
    my $subject_seqs_zero_len_count    = 0;
    my $subject_seqs_preexcluded_count = 0;
    my $subject_seqs_dupe_count        = 0;
    my $subject_seqs_final_count       = 0;

    my $appending = FALSE;
    my $subject_len = 0;
    my $subject_seq;
    my $subject_name; # capped
    my $ori_subject_name;
    my $def_line;
    my $new_def_line;

    my $final_subject_file = $resultdir.$subject_seqs_final_file;
    my $excluded_subject_file  = $resultdir.$subject_seqs_excluded_file;
    sysopen(FINAL, $final_subject_file, O_WRONLY | O_CREAT | O_EXCL)
        or print "[FAILED]\n"
        and print LOG "ERROR: Can't create new file <$final_subject_file> for writing: $!\n"
        and return FAILED;

    sysopen(EXCLUDED, $excluded_subject_file, O_WRONLY | O_CREAT | O_EXCL)
        or print "[FAILED]\n"
        and print LOG "ERROR: Can't create new file <$excluded_subject_file> for writing: $!\n"
        and return FAILED;

    while (TRUE) {
        $_ = <FH>;
        if (defined ($_)) {
            $line_count++;
            #s/^\s+//;
            #s/\s+$//;
            next if $_ eq '';
        }
        if (!defined($_) || />/) {
            if (defined($_)) {
                s/^\s+//;
                s/\s+$//;
                unless (/^>(\S.*)$/) {
                    print LOG "WARNING: Invalid FASTA format found at line $line_count in <$_subject_file>. \n".
                              "         The sequence below this line may be incorrectly merged with the previous record.\n".
                              "   line: $_\n\n";
                    next;
                }
                $new_def_line = $1;
                $subject_seqs_raw_count++;
                #print LOG "\$1 is: $1\n"; ## weird bug, $1 seems to be local
            }
            if ($appending) { ## process the previous record
                $subject_len = length $subject_seq; 
                if ($subject_len == 0) {    
                    print LOG "WARNING: Zero length sequence found at line $line_count in file <$_subject_file>: subject_name \"$ori_subject_name\"\n\n";
                    $subject_seqs_zero_len_count++;
                    print EXCLUDED ">$def_line\n";
                } elsif (exists $subject_seqs{$subject_name}) {
                    print LOG "WARNING: Duplicated subject name \"$ori_subject_name\" found at line $line_count in <$_subject_file>.\n\n";
                    $subject_seqs_dupe_count++;
                    print EXCLUDED ">$def_line\n";
                    print_seq(*EXCLUDED, \$subject_seq, 0, $subject_len-1);
                } elsif (exists $excluded_seqs{$subject_name}) {
                    print LOG "WARNING: Subject seq \"$ori_subject_name\" was excluded as requested at line $line_count in <$_subject_file>.\n\n";
                    $subject_seqs_preexcluded_count++;
                    print EXCLUDED ">$def_line\n";
                    print_seq(*EXCLUDED, \$subject_seq, 0, $subject_len-1);
                } else { ## good ones
                    $subject_seqs_final_count++;
                    print FINAL ">$def_line\n";
                    print_seq(*FINAL, \$subject_seq, 0, $subject_len-1);
                    $subject_seqs{$subject_name} = { 'len'              => $subject_len,
                                                 'seq'              => $subject_seq,
                                                 'def_line'         => $def_line,
                                                 'subject_name'       => $subject_name,
                                                 'ori_subject_name'   => $ori_subject_name,
                                               };
                }
            }

            if (!defined($_)) {last;}

            $subject_len   = 0;
            $subject_seq   = '';
            $subject_name  = '';
            $ori_subject_name = '';

            $def_line = $new_def_line;
            #$def_line =~ s/^\s+//;
            #print LOG "def_line: $def_line\n";

            ($subject_name) = $def_line =~ /^(\S+)/;
            $ori_subject_name = $subject_name;
            $subject_name =~ tr/a-z/A-Z/;

            $appending = TRUE;
        } else {
            if ($appending) {
                s/\s+//g;
                $subject_seq .= $_;
            }
        }
    }

    close FH    or print LOG "WARNING: Can't close file <$_subject_file>: $!\n";
    close FINAL or print LOG "WARNING: Can't close file <$final_subject_file>: $!\n";
    close EXCLUDED  or print LOG "WARNING: Can't close file <$excluded_subject_file>: $!\n";

    print LOG "Original      subject sequences count:  $subject_seqs_raw_count\n";
    print LOG "Dupe          subject sequences count:  $subject_seqs_dupe_count\n";
    print LOG "Zero-lengthed subject sequences count:  $subject_seqs_zero_len_count\n";
    print LOG "Pre-excluded  subject sequences count:  $subject_seqs_preexcluded_count\n";
    print LOG "Final         subject sequences count:  $subject_seqs_final_count\n";
    print LOG "Subject sequences excluded  file:       <$subject_seqs_excluded_file>\n";
    print LOG "Subject sequences final file:           <$subject_seqs_final_file>\n";

    print LOG "*** Done getting subject sequences ***\n\n";

    _print_OK();
    return OK;
}


sub get_formatdb
{
    $formatdb = '';
    my $_formatdb;

    while (1) {
        $_formatdb = '';
        if ($_ = `which formatdb 2>/dev/null`) {
            _trunc();
            if ($_ =~ /^(\/\S+formatdb)$/) {
                $_formatdb = $1;
            }
        } 

        $_formatdb = $defaults{formatdb} unless $_formatdb;
        print "Enter the location for formatdb [$_formatdb]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if ($_ =~ /^([-\/\@\w.]+formatdb)$/) {
                $_formatdb = $1;
            } else {
                print STDERR "ERROR: illegal location of file \"$_\" \n\n";
                next;
            }
        }
        unless (-e $_formatdb) {
            print STDERR "ERROR: \"$_formatdb\" does not exist! \n\n";
            next;
        }
        print "\n";
        last;
    }

    $formatdb    = $_formatdb;
    return OK;
}

sub get_blast
{
    $blast = '';
    my $_blast = '';

    while (1) {
        $_blast = '';
        if ($_ = `which blastall 2>/dev/null`) {
            _trunc();
            if ($_ =~ /^(\/\S+blastall)$/) {
                $_blast = $1;
            }
        } 

        $_blast = $defaults{blast} unless $_blast;
        print "Enter the location for blast [$_blast]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if ($_ =~ /^([-\/\@\w.]+blastall)$/) {
                $_blast = $1;
            } else {
                print STDERR "ERROR: illegal location of file \"$_\" \n\n";
                next;
            }
        }
        unless (-e $_blast) {
            print STDERR "ERROR: \"$_blast\" does not exist! \n\n";
            next;
        }
        print "\n";
        last;
    }

    $blast = $_blast;
    return OK;
}

sub get_blast_exp_value
{
    $blast_exp_value = '';
    my $_blast_exp_value;
    while (1) {
        $_blast_exp_value = $defaults{blast_exp_value};
        print "Enter the E-value of BLAST [$_blast_exp_value]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if(/^(\d*?\.?\d+(?:[E|e][+|-]?\d+)?)$/) {
                $_blast_exp_value =  $1;
            } else {
                print STDERR "ERROR: Invalid expect value: \"$_\" \n\n";
                next;
            }
        }
        print "\n";
        last;
    }

    $blast_exp_value = $_blast_exp_value;
    return OK;
}

sub get_blast_identity_cutoff
{
    $blast_identity_cutoff = '';
    my $_blast_identity_cutoff;
    while (1) {
        $_blast_identity_cutoff = $defaults{blast_identity_cutoff};
        print "When a BLAST HSP has an identity percent lower than a threshold,\n".
              "it will not be processed.\n".
              "Enter the minimum identity percent cutoff [$_blast_identity_cutoff]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if(/^(\d+(?:\.\d+)?\%?)$/) {
                $_blast_identity_cutoff =  $1;
                $_blast_identity_cutoff =~ s/\%$//;
            } else {
                print STDERR "ERROR: Invalid BLAST identity cutoff: \"$_\" \n\n";
                next;
            }
        }
        print "\n";
        last;
    }

    $blast_identity_cutoff = $_blast_identity_cutoff;
    return OK;
}

sub get_query_coverage_threshold
{
    $query_coverage_threshold = '';
    my $_query_coverage_threshold;
    while (1) {
        $_query_coverage_threshold = $defaults{query_coverage_threshold};
        print "When the distance from the query start or query stop of a BLAST HSP \n".
              "to the corresponding ends of query sequence is greater than a threshold,\n".
              "the HSP will not be considered a full-length match and therefore not processed.\n".
              "Use 'none' to skip this full-length match check.\n";
        print "Enter the query full length match threshold [$_query_coverage_threshold]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if(/^(\d+)$/ || /^none$/i) {
                $_query_coverage_threshold =  $1;
            } else {
                print STDERR "ERROR: Invalid query full length match threshold: \"$_\" \n\n";
                next;
            }
        }
        print "\n";
        last;
    }

    $query_coverage_threshold = $_query_coverage_threshold;
    return OK;
}

sub get_max_hits_to_be_reported
{
    $max_hits_to_be_reported = '';
    my $_max_hits_to_be_reported;
    while (1) {
        $_max_hits_to_be_reported = $defaults{max_hits_to_be_reported};
        print "TruMatch divides the query sequence into different regions based on \n".
              "the number of hits matched to that region. If a region is matched for \n".
              "more than a certain number of times, it will not be reported.\n".
              "Use 'all' if all hit regions should be reported.\n".
              "Enter the max number of hits to be reported [$_max_hits_to_be_reported]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if(/^(\d+)$/ || /^all$/i) {
                $_max_hits_to_be_reported =  $1;
            } else {
                print STDERR "ERROR: Invalid number of hits to be reported: \"$_\" \n\n";
                next;
            }
        }
        print "\n";
        last;
    }

    $max_hits_to_be_reported = $_max_hits_to_be_reported;
    return OK;
}

sub get_min_length_for_a_region
{
    $min_length_for_a_region = '';
    my $_min_length_for_a_region;
    while (1) {
        $_min_length_for_a_region = $defaults{min_length_for_a_region};
        print "TruMatch divides the query sequence into different regions based on \n".
              "the number of hits matched to that region. If length of a region is \n".
              "less than a threshold, it will not be reported.\n".
              "Enter the min length for a region to be reported [$_min_length_for_a_region]: ";
        $_ = <STDIN>;
        return FAILED if $_ eq "-1\n";
        if ($_ !~ /^\s+$/) {
            _trunc();
            if(/^(\d+)$/) {
                $_min_length_for_a_region =  $1;
            } else {
                print STDERR "ERROR: Invalid min length: \"$_\" \n\n";
                next;
            }
        }
        print "\n";
        last;
    }

    $min_length_for_a_region = $_min_length_for_a_region;
    return OK;
}

############################################################################
# Final confirmation
############################################################################
sub get_confirmation
{
  while (1) {
    print "###########################################################\n",
          "# Please review the values you have chosen.                \n",
          "# To modify, select one of the following:                  \n",
          "###########################################################\n",
          "  1 - Query sequences file:      [$query_file]             \n";
    if ($db_preformatted) {
        print 
          "  2 - Subject database:          [$blast_db_name]              \n",
          "  3 - BLAST program location:    [$blast]                      \n",
          "  4 - BLAST expect value:        [$blast_exp_value]            \n",
          "  5 - BLAST identity% cutoff:    [$blast_identity_cutoff%]      \n",
          "  6 - Query full length coverage threshold:   [$query_coverage_threshold]\n",
          "  7 - Max hits for a region to be reported:   [$max_hits_to_be_reported] \n",
          "  8 - Min length for a region to be reported: [$min_length_for_a_region] \n";
    } else {
        print 
          "  2 - Subject sequences file:    [$subject_file]              \n",
          "  3 - formatdb location:         [$formatdb]                      \n",
          "  4 - BLAST program location:    [$blast]                      \n",
          "  5 - BLAST expect value:        [$blast_exp_value]            \n",
          "  6 - BLAST identity% cutoff:    [$blast_identity_cutoff%]      \n",
          "  7 - Query full length coverage threshold:   [$query_coverage_threshold]\n",
          "  8 - Max hits for a region to be reported:   [$max_hits_to_be_reported] \n",
          "  9 - Min length for a region to be reported: [$min_length_for_a_region] \n";

    }
    print "===========================================================\n",
          "  y - Accept above values and continue the script          \n",
          "  n - Abort the script                                     \n",
          "###########################################################\n";
    while (1) {
        print "Please enter your choice: ";
        $_ = <STDIN>;
        _trunc();
        return FAILED if $_ eq "-1";
        if (/^[1-9YN]$/i || /^YES$/i || /^NO$/i) {
            last;
        } else {
            print STDERR "ERROR: \"$_\" is not a valid choice!\n\n";
        }
    }
    if (/^Y/i) { 
        print LOG 
              "###########################################################\n",
              "# Script running parameters                                \n",
              "###########################################################\n",
              "  1 - Query sequences file:      [$query_file]             \n";
        if ($db_preformatted) {
            print LOG
              "  2 - Subject database:          [$blast_db_name]              \n",
              "  3 - BLAST program location:    [$blast]                      \n",
              "  4 - BLAST expect value:        [$blast_exp_value]            \n",
              "  5 - BLAST identity% cutoff:    [$blast_identity_cutoff%]      \n",
              "  6 - Query full length coverage threshold:   [$query_coverage_threshold]\n",
              "  7 - Max hits for a region to be reported:   [$max_hits_to_be_reported] \n",
              "  8 - Min length for a region to be reported: [$min_length_for_a_region] \n";
        } else {
            print LOG
              "  2 - Subject sequences file:    [$blast_db_name]              \n",
              "  3 - formatdb location:         [$formatdb]                      \n",
              "  4 - BLAST program location:    [$blast]                      \n",
              "  5 - BLAST expect value:        [$blast_exp_value]            \n",
              "  6 - BLAST identity% cutoff:    [$blast_identity_cutoff%]      \n",
              "  7 - Query full length coverage threshold:   [$query_coverage_threshold]\n",
              "  8 - Max hits for a region to be reported:   [$max_hits_to_be_reported] \n",
              "  9 - Min length for a region to be reported: [$min_length_for_a_region] \n";
        }
        print LOG "###########################################################\n\n";
        return OK;
    }
    if (/^N/i) { return FAILED;}

    if ($db_preformatted) {
        SWITCH: {
            if (/^1/) { print "The query file input cannot be modified.\n".
                              "Please restart the script.\n\n";
                              return FAILED;   last SWITCH; }
            if (/^2/) { get_subject_db()   or return FAILED;   last SWITCH; }
            if (/^3/) { get_blast()   or return FAILED;   last SWITCH; }
            if (/^4/) { get_blast_exp_value()         or return FAILED;   last SWITCH; }
            if (/^5/) { get_blast_identity_cutoff()         or return FAILED;   last SWITCH; }
            if (/^6/) { get_query_coverage_threshold() or return FAILED; last SWITCH;}
            if (/^7/) { get_max_hits_to_be_reported() or return FAILED; last SWITCH;}
            if (/^8/) { get_min_length_for_a_region() or return FAILED; last SWITCH;}
        }
    } else {
        SWITCH: {
            if (/^1/) { print "The query file input cannot be modified.\n".
                              "Please restart the script.\n\n";
                              return FAILED;   last SWITCH; }
            if (/^2/) { print "The subject file input cannot be modified.\n".
                              "Please restart the script.\n\n";
                              return FAILED;   last SWITCH; }
            if (/^3/) { get_formatdb()   or return FAILED;   last SWITCH; }
            if (/^4/) { get_blast()      or return FAILED;   last SWITCH; }
            if (/^5/) { get_blast_exp_value()         or return FAILED;   last SWITCH; }
            if (/^6/) { get_blast_identity_cutoff()         or return FAILED;   last SWITCH; }
            if (/^7/) { get_query_coverage_threshold() or return FAILED; last SWITCH;}
            if (/^8/) { get_max_hits_to_be_reported() or return FAILED; last SWITCH;}
            if (/^9/) { get_min_length_for_a_region() or return FAILED; last SWITCH;}
        }
    }
    print "Modifications have been made. Please review these values again.\n\n";
    _pause();
  }
}

sub make_database
{
    print "Creating BLAST compatible database ... ";
    print LOG "*** Creating BLAST compatible database ***\n";
    my $cmd = "$formatdb -i $resultdir/$subject_seqs_final_file -p F -n $resultdir/$temp_db_name";
    #cc limit database size to 200M
    print LOG "command: $cmd\n";
    system($cmd) == 0 
        or print "[FAILED]\n"
        and print STDERR "ERROR: Command \"$cmd\" failed: $!\n\n"
        and return FAILED;
    _print_OK();
    print LOG "*** Done creating BLAST compatible database ***\n\n";
    return OK;
}

sub run_blast
{
    print "BLAST searching query sequences ... ";
    print LOG "*** BLAST searching query sequences ...\n";
    
    ## set BLASTDB env variable (again?)
    my $db_name;
    if ($db_preformatted) {
        $ENV{BLASTDB} = $blastdb_dir;
        $db_name = $blast_db_name;
    } else {
        $ENV{BLASTDB} = $resultdir;
        $db_name = $temp_db_name;
    }

    ## need to do two blast here, one for telomere, the other for subtelomere
    my $query_file  = $resultdir.$query_seqs_final_file;
    my $result_file = $resultdir.$raw_blast_result;

    my $blast_cmd = "$blast -p $blast_program -d $db_name -i $query_file ".
              "-e $blast_exp_value -o $result_file -F $blast_filter ".
              "-b $blast_max_alignments -v $blast_max_alignments ";
              #"-b $blast_max_alignments -a $blast_cpu_number";
              #      ">/dev/null 2>&1";  
    print LOG "command: $blast_cmd\n";

    #system($blast_cmd) == 0 
    `$blast_cmd` eq ''
        or print "[FAILED]\n"
        and print STDERR "ERROR: Command \"$blast_cmd\" failed: $!\n\n"
        and return FAILED;

    $result_file = $resultdir.$raw_blast_tabular_result;
    $blast_cmd = "$blast -p $blast_program -d $db_name -i $query_file -m 9 ".
              "-e $blast_exp_value -o $result_file -F $blast_filter ".
              "-b $blast_max_alignments ";
              #"-b $blast_max_alignments -a $blast_cpu_number";
              #      ">/dev/null 2>&1";  

    #system($blast_cmd) == 0 
    `$blast_cmd` eq ''
        or print "[FAILED]\n"
        and print STDERR "ERROR: Command \"$blast_cmd\" failed: $!\n\n"
        and return FAILED;

    _print_OK();
    print LOG "*** Done BLAST searching query sequences ...\n\n";
    return OK;
}

sub analyze_blast_result
{
    print "Analyzing BLAST result ... ";
    print LOG "*** Analyzing BLAST result ***\n";

    my $result_file = $resultdir.$raw_blast_result;

    my $line_count = 0;
    my $query;
    my $subject;
    my $q_start;
    my $q_stop;
    my $s_start;
    my $s_stop;
    my $s_strand;
    my $identity;
    my $alignment_len;
    my $e_value;
    my $score;
    my $len;
    my $ori_query;
    my $ori_subject;
    my $query_len;
    my $subject_len;
    my $exclude_hit;
    my $temp;
    my $mismatches;
    my $gaps;
    my $subject_rank;

    my $in = new Bio::SearchIO(-format => 'blast', 
                               -file   => $result_file);

    while( my $result = $in->next_result ) {
        while( my $hit = $result->next_hit ) {
            while( my $hsp = $hit->next_hsp ) {
                $query    = $result->query_name;
                $subject  = $hit->name;
                $identity = $hsp->percent_identity;
                $alignment_len = $hsp->hsp_length;
                $q_start  = $hsp->start('query');
                $q_stop   = $hsp->end('query');
                $s_start  = $hsp->start('hit');
                $s_stop   = $hsp->end('hit');
                $e_value  = $hsp->evalue;
                $score    = $hsp->bits;
                $gaps     = $hsp->gaps('total');
                $mismatches = scalar($hsp->seq_inds('query', 'nomatch'));
                $subject_rank = $hit->rank;

                $s_strand = $hsp->strand('subject');
## Note: for blastn, the strand of query is always '+' (or +1 in bioperl), the difference is reflected in the strand of subject

                $ori_query   = $query;
                $ori_subject = $subject;

                $query_len   = $result->query_length;
                $subject_len = $hit->length;

                $exclude_hit = FALSE;

                $query   =~ tr/a-z/A-Z/;  # ensure uniqueness and facilitate hashing
                $subject =~ tr/a-z/A-Z/;  # ensure uniqueness and facilitate hashing
                $ori_subject_names{$subject} = $ori_subject;

                if ($q_start > $q_stop) {
                    print LOG "WARNING: Unexpected in blastn result <$result_file>: \n".
                              "         query start ($q_start) > query stop ($q_stop)\n".
                              "         query_name ($ori_query) subject_name ($ori_subject) \n";
                    next;
                }

                if (!exists $query_seqs{$query}) {
                    print LOG "WARNING: query name \"$query\" cannot be found in query_seqs hash in file <$result_file>.\n";
                    next;
                }

                if ($query_len != $query_seqs{$query}{len}) {
                    print LOG "WARNING: The query length reported by BLAST ($query_len) is not consistent with\n".
                              "         the query length obtained from the query sequences file ($query_seqs{$query}{len}).\n".
                              "         query_name ($ori_query) subject_name ($ori_subject) \n";
                    next;
                }

                if ($s_strand == 1) {
                    $s_strand = '+';
                } elsif ($s_strand == -1) {
                    $s_strand = '-';
                    $temp = $s_start;
                    $s_start = $s_stop;
                    $s_stop = $temp;
                } else {
                    print LOG "WARNING: Unknown subject strand ($s_strand): query_name ($ori_query) subject_name ($ori_subject) \n";
                    next;
                }

                unless ($identity >= $blast_identity_cutoff) { #cc
                    if (exists $query_seqs{$query}{excluded_hits}) {
                        unless (exists $query_seqs{$query}{excluded_hits}{$subject}) {
                            $query_seqs{$query}{excluded_hits}{$subject} = [];
                        }
                    } else { ## this is the first blast hits for this query, setup data structures
                        $query_seqs{$query}{excluded_hits} = { 
                            $subject => [],
                            };
                    }

                    push @{$query_seqs{$query}{excluded_hits}{$subject}},
                         {'q_start' => $q_start, 
                          'q_stop'  => $q_stop, 
                          's_start' => $s_start, 
                          's_stop'  => $s_stop, 
                          's_strand' => $s_strand,
                          'score'   => $score,
                          'evalue'  => $e_value,
                          'identity' => $identity,
                          'alignment_len' => $alignment_len,
                          'gaps'             => $gaps,
                          'mismatches'       => $mismatches,
                          'subject_rank'     => $subject_rank,
                          'ori_query_name'   => $ori_query,
                          'ori_subject_name' => $ori_subject,
                          'excluded_reason'  => 'Low identity percent',
                          'query_len'        => $query_len,
                          'subject_len'      => $subject_len,
                         };
                    next;
                }

                $exclude_hit    = FALSE;

                unless ($query_coverage_threshold =~ /none/i) {

                    if ($s_strand eq '+') {
                        ## add query length check here !
                        if ($q_start > $query_coverage_threshold) { #cc
                            if ($s_start > $query_coverage_threshold) {
                                $exclude_hit = TRUE;
                            }
                        } 
                        if ($q_stop < $query_len - $query_coverage_threshold) { #cc
                            if ($s_stop < $subject_len - $query_coverage_threshold) {
                                $exclude_hit = TRUE;
                            }
                        } 
                    } else { # $s_strand eq '-'
                        if ($q_start > $query_coverage_threshold) { #cc
                            if ($s_start < $subject_len - $query_coverage_threshold) {
                                $exclude_hit = TRUE;
                            }
                        } 
                        if ($q_stop < $query_len - $query_coverage_threshold) {
                            if ($s_stop > $query_coverage_threshold) { #cc
                                $exclude_hit = TRUE;
                            }
                        } 
                    }

                    if ($exclude_hit) { #new
                        if (exists $query_seqs{$query}{excluded_hits}) {
                            unless (exists $query_seqs{$query}{excluded_hits}{$subject}) {
                                $query_seqs{$query}{excluded_hits}{$subject} = [];
                            }
                        } else { ## this is the first blast hits for this query, setup data structures
                            $query_seqs{$query}{excluded_hits} = { 
                                $subject => [],
                                };
                        }

                        push @{$query_seqs{$query}{excluded_hits}{$subject}},
                             {'q_start' => $q_start, 
                              'q_stop'  => $q_stop, 
                              's_start' => $s_start, 
                              's_stop'  => $s_stop, 
                              's_strand' => $s_strand,
                              'score'   => $score,
                              'evalue'  => $e_value,
                              'identity' => $identity,
                              'alignment_len' => $alignment_len,
                              'gaps'             => $gaps,
                              'mismatches'       => $mismatches,
                              'subject_rank'     => $subject_rank,
                              'ori_query_name'   => $ori_query,
                              'ori_subject_name' => $ori_subject,
                              'excluded_reason'  => 'Not a full length hit',
                              'query_len'        => $query_len,
                              'subject_len'      => $subject_len,
                             };
                        next;
                    }
                }

                if (exists $query_seqs{$query}{blast_hits}) {
                    unless (exists $query_seqs{$query}{blast_hits}{$subject}) {
                        $query_seqs{$query}{blast_hits}{$subject} = [];
                    }
                } else { ## this is the first blast hits for this query, setup data structures
                    $query_seqs{$query}{blast_hits} = { 
                        $subject => [],
                        };
                }

                push @{$query_seqs{$query}{blast_hits}{$subject}},
                     {'q_start' => $q_start, 
                      'q_stop'  => $q_stop, 
                      's_start' => $s_start, 
                      's_stop'  => $s_stop, 
                      's_strand' => $s_strand,
                      'score'   => $score,
                      'evalue'  => $e_value,
                      'identity' => $identity,
                      'alignment_len' => $alignment_len,
                      'gaps'             => $gaps,
                      'mismatches'       => $mismatches,
                      'subject_rank'     => $subject_rank,
                      'ori_query_name'   => $ori_query,
                      'ori_subject_name' => $ori_subject,
                      'query_len'        => $query_len,
                      'subject_len'      => $subject_len,
                     };
            }
        }
    }

## sort excluded hits
## output excluded hits
    my $file = $resultdir.$hits_excluded_summary;
    my $excluded_reason;

    sysopen(EXCLUDED, "$file", O_WRONLY | O_CREAT | O_EXCL)
        or print "[FAILED]\n"
        and print STDERR "ERROR: Can't create new file <$file> for writing: $!\n"
        and return FAILED;

    print EXCLUDED "Query\tSubject\tExcluded Reason\tSubject Rank in Hits List\tIdentity%\tAlignment Length\tMismatches\tGaps\Query Start\tQuery End\tQuery Length\tHit Strand\tSubject Start\tSubject End\tSubject Length\tE-value\tBit Score\n";

    my $excluded_hits_ref;
    my $query_seq_len;
    my $subject_contig_len;
    my $hit_identity; #new
    my $query_first_hit   = TRUE;
    my $subject_first_hit = TRUE;
    my $hit_segments_ref;

    foreach my $query_name (sort keys %query_seqs) {
        if (exists $query_seqs{$query_name}{excluded_hits}) {
            $excluded_hits_ref = $query_seqs{$query_name}{excluded_hits};
        } else {
            print EXCLUDED "$query_seqs{$query_name}{ori_query_name}\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\n";
            next;
        }
        $query_first_hit = TRUE;
        foreach my $subject (sort keys %$excluded_hits_ref) {
            $hit_segments_ref = $excluded_hits_ref->{$subject};
            sort_blast_hits($hit_segments_ref);
            $subject_first_hit = TRUE;
            foreach my $ref (@$hit_segments_ref) {
=begin comment
                if ($query_first_hit) {
                    print EXCLUDED "$ref->{ori_query_name}\t";
                    $query_first_hit = FALSE;
                } else { 
                    print EXCLUDED "......\t";
                }
                if ($subject_first_hit) {
                    print EXCLUDED "$ref->{ori_subject_name}\t";
                    $subject_first_hit = FALSE;
                } else { 
                    print EXCLUDED "......\t";
                }
=end comment
=cut

    #print EXCLUDED "Query\tSubject\tExcluded Reason\tSubject Rank in Hits List\tIdentity%\tAlignment Length\tMismatches\tGaps\Query Start\tQuery End\tQuery Length\tHit Strand\tSubject Start\tSubject End\tSubject Length\tE-value\tBit Score\n";
                print EXCLUDED "$ref->{ori_query_name}\t$ref->{ori_subject_name}\t";
                print EXCLUDED 
                  "$ref->{excluded_reason}\t$ref->{subject_rank}\t$ref->{identity}\t$ref->{alignment_len}\t".
                  "$ref->{mismatches}\t$ref->{gaps}\t".
                  "$ref->{q_start}\t$ref->{q_stop}\t$ref->{query_len}\t".
                  "$ref->{s_strand}\t$ref->{s_start}\t$ref->{s_stop}\t$ref->{subject_len}\t".
                  "$ref->{evalue}\t$ref->{score}\n";
=begin comment
                $ori_query          = $ref->{ori_query_name};
                $ori_subject        = $ref->{ori_subject_name};
                $excluded_reason    = $ref->{excluded_reason};
                $identity           = $ref->{identity};
                $alignment_len      = $ref->{alignment_len};
                $q_start            = $ref->{q_start};
                $q_stop             = $ref->{q_stop};
                $query_len          = $ref->{query_len};
                $s_start            = $ref->{s_start};
                $s_stop             = $ref->{s_stop};
                $subject_len        = $ref->{subject_len};
                $e_value            = $ref->{evalue};
                $score              = $ref->{score};
=end comment
=cut
            }
        }
        print EXCLUDED "\n";
    }

    close EXCLUDED or print LOG "WARNING: Can't close file <$file>: $!\n";

## sort valid blast hits
## find regions
## output hits overlaped with regions 

    $file = $resultdir.$true_match_summary;

    sysopen(RESULT, "$file", O_WRONLY | O_CREAT | O_EXCL)
        or print "[FAILED]\n"
        and print STDERR "ERROR: Can't create new file <$file> for writing: $!\n"
        and return FAILED;

    print RESULT "Query\tHit Cardinality\tHit Regions with the Given Cardinality\tSubject\tSubject Rank in the Hits List\tIdentity%\tAlignment Length\tMismatches\tGaps\tQuery Start\tQuery End\tQuery Length\tHit Strand\tSubject Start\tSubject End\tSubject Length\tE-value\tBit Score\n";

    $query_first_hit   = TRUE;
    $subject_first_hit = TRUE;
    my $cardinality_first_hit = TRUE;
    foreach my $query_name (sort keys %query_seqs) {
        my $blast_hits_ref;
        if (exists $query_seqs{$query_name}{blast_hits}) {
            $blast_hits_ref = $query_seqs{$query_name}{blast_hits};
        } else {
            if (exists $query_seqs{$query_name}{excluded_hits}) {
                print RESULT "$query_seqs{$query_name}{ori_query_name}\tAll hits excluded due to low identity percent or full length coverage check.\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\n";
            } else {
                print RESULT "$query_seqs{$query_name}{ori_query_name}\tNo hits at all.\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\n";
            }
            next;
        }
        $query_len = $query_seqs{$query_name}{len};
        my @query_bases_coverage = (0) x $query_len; #new
        foreach my $subject (keys %$blast_hits_ref) {
            $hit_segments_ref = $blast_hits_ref->{$subject};
            sort_blast_hits($hit_segments_ref);
            my @query_bases_recorded = (FALSE) x $query_len; #new
            foreach my $ref (@$hit_segments_ref) {
                $q_start            = $ref->{q_start};
                $q_stop             = $ref->{q_stop};
                for (my $i = $q_start - 1; $i < $q_stop; $i++) {
                    if (!$query_bases_recorded[$i]) {
                        $query_bases_coverage[$i] += 1;
                        $query_bases_recorded[$i] = TRUE; # make sure we record each base only once for each contig. 
                    }
                }
            }
        }
        $query_seqs{$query_name}{unique_regions} = get_unique_regions(\@query_bases_coverage);
        my $unique_regions_ref = $query_seqs{$query_name}{unique_regions};
        $query_seqs{$query_name}{ranked_blast_hits} = {};
        my $ranked_blast_hits_ref = $query_seqs{$query_name}{ranked_blast_hits};
        foreach my $subject (keys %$blast_hits_ref) {
            $hit_segments_ref = $blast_hits_ref->{$subject};
            foreach my $ref (@$hit_segments_ref) {
                $q_start            = $ref->{q_start};
                $q_stop             = $ref->{q_stop};
                foreach my $cardinality (keys %$unique_regions_ref) {
                    if (overlap_with_given_regions($q_start, $q_stop, $unique_regions_ref->{$cardinality})) {
                        if (exists $ranked_blast_hits_ref->{$cardinality}) {
                            if (exists $ranked_blast_hits_ref->{$cardinality}{$subject}) {
                                push @{$ranked_blast_hits_ref->{$cardinality}{$subject}}, $ref;
                            } else {
                                $ranked_blast_hits_ref->{$cardinality}{$subject} = [$ref,];
                            }
                        } else {
                            $ranked_blast_hits_ref->{$cardinality} = {$subject => [$ref,],};
                        }
                    }
                }
            }
        }
        $query_first_hit = TRUE;
        my $printed = FALSE;
        foreach my $cardinality (sort numerically keys %$ranked_blast_hits_ref) {
            $cardinality_first_hit = TRUE;
            my $region_string = '';
            foreach my $span_ref (@{$unique_regions_ref->{$cardinality}}) {
                $region_string .= "$span_ref->{start}--$span_ref->{stop}; ";
            }
            $region_string =~ s/\;\s+$//;

            my @segments = ();
            foreach my $subject (sort keys %{$ranked_blast_hits_ref->{$cardinality}}) {
                $hit_segments_ref = $ranked_blast_hits_ref->{$cardinality}{$subject};
                foreach my $ref (@$hit_segments_ref) {
                    push @segments, $ref;
                }
            }

            sub by_bit_score {
                $b->{score} <=> $a->{score}
            }

            foreach my $ref (sort by_bit_score @segments) {
                print RESULT "$ref->{ori_query_name}\t$cardinality\t$region_string\t$ref->{ori_subject_name}\t";
                print RESULT 
                  "$ref->{subject_rank}\t$ref->{identity}\t$ref->{alignment_len}\t".
                  "$ref->{mismatches}\t$ref->{gaps}\t".
                  "$ref->{q_start}\t$ref->{q_stop}\t$ref->{query_len}\t".
                  "$ref->{s_strand}\t$ref->{s_start}\t$ref->{s_stop}\t$ref->{subject_len}\t".
                  "$ref->{evalue}\t$ref->{score}\n"; 
                $printed = TRUE;
            }
        }
        if (!$printed) {
            print RESULT "$query_seqs{$query_name}{ori_query_name}\tNo hits reported due to the length and cardinality requirements on hit regions.\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\t---\n";
        }
        print RESULT "\n";
    }

    close RESULT or print LOG "WARNING: Can't close file <$file>: $!\n";

=begin comment
    # we need some statistics here:
    # how many seqs have no blast_hits (what are they?)
    # how many seqs have unique blast_hits (what are they?)
    # how many seqs have non-unique blast_hits (what are they?)
    # the uniqueness is defined by the number of queries being hit

    my %tel_seqs_with_no_hits = ();
    my %tel_seqs_with_unique_hits = ();
    my %tel_seqs_with_more_hits = ();
    my %prd_seqs_with_no_hits = ();
    my %prd_seqs_with_unique_hits = ();
    my %prd_seqs_with_more_hits = ();

    my $count_tel_seqs_with_no_hits = 0;
    my $count_tel_seqs_with_unique_hits = 0;
    my $count_tel_seqs_with_more_hits = 0;
    my $count_prd_seqs_with_no_hits = 0;
    my $count_prd_seqs_with_unique_hits = 0;
    my $count_prd_seqs_with_more_hits = 0;

    foreach my $tel_seq (keys %tel_seqs) {
        # each $tel_seq is different, don't have to check uniqueness
        if (exists $tel_seqs{$tel_seq}{blast_hits}) {
            if (scalar (keys %{$tel_seqs{$tel_seq}{blast_hits}}) == 1) {
                $tel_seqs_with_unique_hits{$tel_seq} = undef;
                $count_tel_seqs_with_unique_hits++;
            } else {
                $tel_seqs_with_more_hits{$tel_seq} = undef;
                $count_tel_seqs_with_more_hits++;
            }
        } else {
            $tel_seqs_with_no_hits{$tel_seq} = undef;
            $count_tel_seqs_with_no_hits++;
        }
    }

    # sub numerically { $a <=> $b }
    print LOG "Tel seqs with no blast hits: $count_tel_seqs_with_no_hits \n";
    foreach my $tel_seq (sort keys %tel_seqs_with_no_hits) {
        print LOG "$tel_seq ";
    }
    print LOG "\n";
    print LOG "Tel seqs with unique blast hits: $count_tel_seqs_with_unique_hits \n";
    foreach my $tel_seq (sort keys %tel_seqs_with_unique_hits) {
        print LOG "$tel_seq ";
    }
    print LOG "\n";
    print LOG "Tel seqs with two or more blast hits: $count_tel_seqs_with_more_hits \n";
    foreach my $tel_seq (sort keys %tel_seqs_with_more_hits) {
        print LOG "$tel_seq ";
    }
    print LOG "\n\n";

=end comment
=cut

    print LOG "*** Done analyzing BLAST result ***\n\n";
    _print_OK();
    return OK;
}

sub _pause
{
    print "Press any key to continue ... \n";
    `stty -echo >/dev/null 2>&1`;
    `stty raw >/dev/null 2>&1`;
    sysread(STDIN, $_, 1); # get a key stroke
    `stty cooked >/dev/null 2>&1`;
    `stty echo >/dev/null 2>&1`;
    print "\n";
}

sub rm_resultdir
{
    #if ($resultdir && (-d $resultdir)) {
    #    system("rm -rf $resultdir >/dev/null 2>&1");
    #}
    return OK;  ## must return 1 even if don't delete
                ## otherwise the " or .. and .. and next" won't work
                ## in the main process
}

sub _print_OK
{
    sleep 1;
    print "[OK]\n\n";
    sleep 1;
}

sub revcomp 
{
    my $outputseq = reverse(split //, $_[0]); 
    $outputseq =~ tr/ACGTacgt/TGCAtgca/; 
    return $outputseq;
}

sub sort_blast_hits
{
    ## Make sure all the hits have the same direction 
    ## before you call this routine!!
    
    my $blast_hits = shift @_;
    unless (defined $blast_hits) {
        print LOG "WARNING: Undefined array passed to sort_blast_hits()\n";
        return FAILED;
    }
    unless (@$blast_hits) {  ## allow empty array to be passed in, just throw whatever craps back
        return OK;
    }
    ## check if all start and stop relative positions are consistent
    ## some checking needs to be done here 
    ## also needs to decide which part of the code below will get executed

    ## sort the list of hits by the start values
    
    my ($i, $j, $index_min);
    for ($i = 0; $i < @$blast_hits; $i++) {
        #print STDERR "Sort core: \$i = $i\n";
        if ($blast_hits->[$i]{q_start} > $blast_hits->[$i]{q_stop}) {
            print LOG "WARNING: q_start ($blast_hits->[$i]{q_start}) > q_stop ($blast_hits->[$i]{q_stop})\n";
            return FAILED;
        }
    }
    for ($i = 0; $i < @$blast_hits; $i++) {
        #print STDERR "Sort core: \$i = $i\n";
        $index_min = $i;
        for ($j = $i+1; $j < @$blast_hits; $j++) {
            if ($blast_hits->[$j]{q_start} < $blast_hits->[$index_min]{q_start}) {
                $index_min = $j; 
            }
        }
        my $temp = $blast_hits->[$i];
        $blast_hits->[$i] = $blast_hits->[$index_min];
        $blast_hits->[$index_min] = $temp;
    }
    return OK;
}

sub get_unique_regions
{
    my $base_coverage_ref       = shift @_;
    
    my $query_seq_len = scalar @$base_coverage_ref;

    my %unique_regions = ();
    my ($active_span_start, $active_span_stop);
    my %len_excluded_regions = ();

    my $expending = FALSE;
    my $i;

    my $current_cardinality;
    for ($i = 0; $i < $query_seq_len; $i++) {
        if ($expending) {
            if ($base_coverage_ref->[$i] != $current_cardinality) {
                ## current span ended
                $active_span_stop  = $i - 1;
                if ($active_span_stop - $active_span_start + 1 >= $min_length_for_a_region) {
                    ## add one to adjust to the real world index
                    if (exists $unique_regions{$current_cardinality}) {
                        push @{$unique_regions{$current_cardinality}}, {'start' => $active_span_start + 1,
                                           'stop'  => $active_span_stop + 1,
                                          };
                    } else {
                        $unique_regions{$current_cardinality} = [ {'start' => $active_span_start + 1,
                                           'stop'  => $active_span_stop + 1,},
                                                                ];
                    }
                } else {
                    if (exists $len_excluded_regions{$current_cardinality}) {
                        push @{$len_excluded_regions{$current_cardinality}}, {'start' => $active_span_start + 1,
                                           'stop'  => $active_span_stop + 1,
                                          };
                    } else {
                        $len_excluded_regions{$current_cardinality} = [ {'start' => $active_span_start + 1,
                                           'stop'  => $active_span_stop + 1,},
                                                                ];
                    }
                }
                if ($base_coverage_ref->[$i] == 0) {
                    $expending = FALSE;
                } else {
                    $active_span_start  = $i;
                    $current_cardinality = $base_coverage_ref->[$i];
                    $expending = TRUE;
                }
            }    
        } else {
            if ($base_coverage_ref->[$i] > 0) {
                ## new span starts
                $active_span_start  = $i;
                $current_cardinality = $base_coverage_ref->[$i];
                $expending = TRUE;
            }
        }
    }
    if ($expending) {
        ## already the end of the sequence, still expending
        $active_span_stop  = $i - 1;
        if ($active_span_stop - $active_span_start + 1 >= $min_length_for_a_region) {
            ## add one to adjust to the real world index
            if (exists $unique_regions{$current_cardinality}) {
                push @{$unique_regions{$current_cardinality}}, {'start' => $active_span_start + 1,
                                   'stop'  => $active_span_stop + 1,
                                  };
            } else {
                $unique_regions{$current_cardinality} = [ {'start' => $active_span_start + 1,
                                   'stop'  => $active_span_stop + 1,},
                                                        ];
            }
        } else {
            if (exists $len_excluded_regions{$current_cardinality}) {
                push @{$len_excluded_regions{$current_cardinality}}, {'start' => $active_span_start + 1,
                                   'stop'  => $active_span_stop + 1,
                                  };
            } else {
                $len_excluded_regions{$current_cardinality} = [ {'start' => $active_span_start + 1,
                                   'stop'  => $active_span_stop + 1,},
                                                        ];
            }
        }
    }

    my %cardinalities_to_be_deleted = ();
    unless ($max_hits_to_be_reported =~ /all/i) {
        foreach my $cardinality (keys %unique_regions) {
            if ($cardinality > $max_hits_to_be_reported) {
                $cardinalities_to_be_deleted{$cardinality} = undef;
            }
        }
        foreach my $cardinality (keys %cardinalities_to_be_deleted) {
            delete $unique_regions{$cardinality};
        }
     }   

    #print STDERR "Valid unique regions count (len >= $unique_region_len_threshold): ".scalar(@unique_regions)."\n";
    #print STDERR "Skipped unique regions count (len < $unique_region_len_threshold): $skipped_span_count\n";

    return \%unique_regions;
}

sub overlap_with_given_regions
{
    ## expected: query_start, query_stop, ref to unique_regions
    my ($query_start, $query_stop, $unique_regions_ref) = @_;

    if ($query_start > $query_stop) {
        warn "\nWarning: Unexpected: query_start ($query_start) > query_stop ($query_stop). Checking overlaps with unique regions will return FALSE\n";
        return FALSE;
    }

    my ($span_start, $span_stop);

    foreach my $span_ref (@$unique_regions_ref) {
        if ($query_start <  $span_ref->{start} &&
            $query_stop  >= $span_ref->{start}) {
            return TRUE;
        } 
        if ($query_start >=  $span_ref->{start} &&
            $query_start <=  $span_ref->{stop}) {
            ## now we overlap, but how much? 
            return TRUE;
        }
    }
    
    return FALSE;
}

sub print_seq
{
    ## to make it more efficient, passing by ref
    my ($fh, $read_seq_ref, $start, $stop) = @_; 
    my $start_index = $start;
    my $end_index;
    while ($start_index <= $stop) {
        $end_index = $start_index + SEQ_LINE_FMT - 1;
        $end_index = ($end_index < $stop) ? $end_index : $stop;
        print $fh substr($$read_seq_ref, $start_index, $end_index - $start_index + 1), "\n";
        $start_index = $end_index + 1;
    }
    print $fh "\n";
}
