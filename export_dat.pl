#!/usr/local/bin/perl
##############################################################################
# Export Mascot search results                                               #
##############################################################################
# COPYRIGHT NOTICE                                                           #
# Copyright 1998-2006 Matrix Science Limited  All Rights Reserved.           #
#                                                                            #
# This program may be used and modified within the licensee's organisation   #
# provided that this copyright notice remains intact. Distribution of this   #
# program or parts thereof outside the licensee's organisation without the   #
# prior written consent of Matrix Science Limited is expressly forbidden.    #
##############################################################################
#    $Archive:: /www/cgi/export_dat.pl                                     $ #
#     $Author: johnc $ #
#       $Date: 2010-03-16 08:58:09 $ #
#   $Revision: 1.49 $ #
# $NoKeywords::                                                            $ #
##############################################################################
 use strict;                                                                #
##############################################################################

# The following (case insensitive) URL arguments are recognised:
#
# file                      - relative path to result file (required)
# sessionid                 - Mascot security sessionID
# do_export                 - 1 to export results, 0 to display form, -1 to display command line arguments
# export_format             - "XML" or "CSV" or "mzIdentML" or "pepXML" or "DTASelect" or MascotDAT or MGF or ...
# _sigthreshold             - probability significance threshold, default 0.05
# report                    - max number of hits to be reported, (0 = AUTO)
# _server_mudpit_switch     - if queries / entries greater than this value, switch to Mudpit scoring, default 0.001
# _ignoreionsscorebelow     - cut off on MS/MS ions scores
# show_same_sets            - 1 to display all proteins that match the same set of peptides, otherwise just one per hit
# _showsubsets              - display protein hits that are missing up to this fraction of the protein score of the main hit
# _requireboldred           - 1 to report protein hits only if they include at least one bold, red peptide match
# unigene                   - UniGene index species to be used to cluster hits
# _showallfromerrortolerant - 1 to display all hits from an error tolerant search, including garbage (no UI)
# _onlyerrortolerant        - 1 to display only error tolerant matches from a new style error tolerant search
# _noerrortolerant          - 1 to display no error tolerant matches from a new style error tolerant search
# _show_decoy_report        - 1 to display report for the integrated decoy search (Mascot 2.2. & later)
# search_master             - Over-ride toggle for show_header, show_decoy, show_mods, show_params, show_format, show_masses
# show_header               - 1 to include a block containing search level information
# show_decoy                - 1 to include a block containing decoy search information
# show_mods                 - 1 to include a block containing variable modifications information
# show_params               - 1 to include a block containing search parameters
# show_format               - 1 to include a block containing format parameters
# show_masses               - 1 to include a block containing residue and element masses
# show_unassigned           - 1 to include a block containing unassigned matches
# protein_master            - Over-ride toggle for all protein info
# peptide_master            - Over-ride toggle for all peptide info
# query_master              - Over-ride toggle for all query info

#
# If the following (case insensitive) URL arguments are set to 1, the corresponding fields 
# are included in the report unless over-ridden by "master" checkbox
#
  my @columns;
  push @columns, "prot_hit_num";  # always forced to 1
  push @columns, "prot_acc";      # always forced to 1
  push @columns, "prot_desc";
  push @columns, "prot_score";
  push @columns, "prot_thresh";
  push @columns, "prot_expect";
  push @columns, "prot_mass";
  push @columns, "prot_matches";
  push @columns, "prot_matches_sig";    # slaved off prot_matches
  push @columns, "prot_sequences";      # slaved off prot_matches
  push @columns, "prot_sequences_sig";  # slaved off prot_matches
  push @columns, "prot_cover";
  push @columns, "prot_len";
  push @columns, "prot_pi";
  push @columns, "prot_tax_str";
  push @columns, "prot_tax_id";
  push @columns, "prot_seq";
# prot_empai (no entry in header row)
# prot_quant (no entry in header row)
  push @columns, "pep_query";     # always forced to 1
  push @columns, "pep_rank";      # always forced to 1
  push @columns, "pep_isbold";    # always forced to 1
  push @columns, "pep_isunique";  # always forced to 1
  push @columns, "pep_exp_mz";    # always forced to 1
  push @columns, "pep_exp_mr";
  push @columns, "pep_exp_z";
  push @columns, "pep_calc_mr";
  push @columns, "pep_delta";
  push @columns, "pep_start";
  push @columns, "pep_end";
  push @columns, "pep_miss";
  push @columns, "pep_score";
  push @columns, "pep_homol";
  push @columns, "pep_ident";
  push @columns, "pep_expect";
  push @columns, "pep_res_before";  # slaved off pep_seq
  push @columns, "pep_seq";
  push @columns, "pep_res_after";  # slaved off pep_seq
  push @columns, "pep_frame";
  push @columns, "pep_var_mod";
  push @columns, "pep_var_mod_pos";  # slaved off pep_var_mod
  push @columns, "pep_num_match";
  push @columns, "pep_scan_title";
# pep_quant (no entry in header row)

# 'Global' variables
  my(
    $anyPepSumMatch,           # $objResFile->anyPeptideSummaryMatches($sec_peptides)
    $delimiter,                # delimiter for CSV is "," by default
    $export_format,            # "XML" or "CSV", etc.
    %fastaLen,                 # cache for protein length values returned by ms-getseq.exe
    %fastaMasses,              # cache for any masses that have to be retrieved via ms-getseq.exe
    %fastapI,                  # cache for pI values returned by ms-getseq.exe
    %fastaTitles,              # cache for any FASTA titles that have to be retrieved via ms-getseq.exe
    $fileIn,                   # relative path to result file, passed as required URL argument
    $fileNameRoot,             # root of result file name, e.g. F123456
    $ignoreIonsScoreBelow,     # cut off on MS/MS ions scores
    $massDP,                   # number of decimal places in formatted mass values
    %masses,                   # mass values for residues and terminii
    $mass_type,                # MONO or AVE
    $minPepLen,                # peptides shorter than $minPepLen are ignored when generating Peptide summary 
    $msresFlags,               # flags used to create Mascot Parser summary object
    $mudpitSwitch,             # if queries / entries greater than this value, switch to Mudpit scoring, default 0.001
    $myName,                   # file name of this script for links to self (not complete path)
    $numHits,                  # max number of hits to be reported
    $objDatFile,               # Mascot parser mascot.dat file object
    $objMascotOptions,         # Mascot parser configuration options object
    $objMassesFile,            # Mascot parser masses file object
    $objModFile,               # Mascot parser mod_file object
    $objParams,                # Mascot parser search parameters object
    $objProtein,               # Mascot parser protein object
    $objResFile,               # Mascot parser result file object
    $objSummary,               # Mascot parser result summary object (may be protein or peptide)
    $objUmodConfigFile,        # Mascot parser Unimod configuration file object
    $objUnigeneOptions,        # Mascot parser configuration unigene object
    $protColumnCount,          # Used to align peptide match data in CSV output 
    $queryColumnCount,         # Used to align peptide match data in CSV output 
    @queryList,                # Track which queries are assigned to listed proteins for mzIdentML
    $reportType,               # 'peptide' or 'concise'
    $RequireBoldRed,           # 1 to report protein hits only if they include at least one bold, red peptide match
    $sec_peptides,             # SEC_PEPTIDES or SEC_DECOYPEPTIDES 
    $sec_summary,              # SEC_SUMMARY or SEC_DECOYSUMMARY 
    %seqCache,                 # cache for protein sequences returned by ms-getseq.exe
    $session,                  # Mascot security session object
    $sessionID,                # Mascot security sessionID
    $shipper,                  # flag set to 'TRUE' if this is Mascot for intranet, 'FALSE' for public internet site
    $ShowDecoyReport,          # 1 to display report for the integrated decoy search (Mascot 2.2. & later)
    $ShowAllFromErrorTolerant, # 1 to display all hits from an error tolerant search, including garbage
    $OnlyErrorTolerant,        # 1 to display only error tolerant matches from a new style error tolerant search
    $NoErrorTolerant,          # 1 to display only standard matches from a new style error tolerant search
    $ShowSubSets,              # display protein hits that are missing up to this fraction of the protein score of the main hit
    $sigThreshold,             # probability significance threshold (OneInXprobRnd)
    %taxNames,                 # cache for looking up taxonomy name string from tax ID
    $thisScript,               # CGI object
    $tmpChecked,               # temp variable used to toggle state of CHECKED
    $UniGeneFile,              # path to a UniGene index file
    $URI,                      # URL as far as Mascot root directory, if executed as CGI, otherwise "../"
    %urlParams,                # keys are URL parameter names in lower case, values are names in original case
    %vmMass,                   # variable modification mass
    %vmString,                 # variable modification name
    $objQuantFile,             # Mascot parser ms_quant_configfile object
    $objQuantMethod,           # Mascot parser quant_method object
    @quantDataByQuery,         # intensity information for each query, used for quantitation
    @quantFormatControlText,   # contains the HTML text for the quant format controls
    @quantWarnings,            # contains the HTML text for any warnings returned by quant routines
    @quantCorrFactor,          # normalisation correction factors, used for quantitation
    @query_title_list,         # list of query titles, HTML escaped, index is query number
    $quant_subs_active,        # set to 1 quant_subs.pl has been loaded
    @quantDataByHit,           # quantitation ratios for a single protein hit
    %PAI,                      # track # observed peptides for emPAI
    $OldStyleErrTolReport,     # 1 to suppress certain parts of the report as per old-style error tolerant search
    $objUmodConfigFile2,       # For finding the IDs from PSI-MS-MOD names. When record_id is not in the .dat file, go to unimod.xml
    );

# set current directory to script location for FastTrack on NT
# chdir also handles a Windows drive letter change
  if ($ENV{'WINDIR'} && $0 =~ /(.*)[\\\/]/) {
    chdir($1);
  }

# delimiter for CSV can be changed
  $delimiter = ",";
  
 # required Perl packages
  use lib "../bin";
  #use lib qw(/fs/ispider/sw/FDRAnaysis/msparser/perl_modules/);
  #use lib qw(/fs/ispider/sw/FDRAnaysis/msparser/perl_modules/auto/msparser);
  use lib qw(../../msparser/perl_modules/);
  use lib qw(../../msparser/perl_modules/auto/msparser);  
  use msparser;
  use CGI;
  use CGI::Carp qw(fatalsToBrowser);
  use HTTP::Request::Common;
  use LWP::UserAgent;

  $| = 1; # set autoflush on STDOUT

# create CGI object
  $thisScript = new CGI;
 
# pull in some common subroutines
  require "./common_subs.pl";
  
# www.pl contains the code to decrypt result file names
# its existence indicates that this script is running on the public web site
  if (-e "./www.pl") {
    do "./www.pl";
    $shipper = 'FALSE';
  } else {
    $shipper = 'TRUE';
  }

# get the name of this script for creating URL links to self
#  $myName = $thisScript->url(-relative=>1);
  ($myName) = $0 =~ /([^\\\/]*)$/;

# taint mode requires path to be set explicitly
# Unix path may be required to find decompression utilities in &common_subs::decompress()
  if ($ENV{'WINDIR'}){
    $ENV{"PATH"} = "";
  } else {
    $ENV{"PATH"} = "/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin";
  }
# to bypass taint mode check on the path, comment out above lines and uncomment following line
# ($ENV{"PATH"}) = $ENV{"PATH"} =~ /(.*)/;

# create hash for URL arguments, so that we can always use lower case keys
  foreach ($thisScript->param) {
    if ($urlParams{lc($_)} && $urlParams{lc($_)} ne $_) {
      die("URL parameter names must use consistent case");
    }
    $urlParams{lc($_)} = $_;
  }

# some protein options not permitted on public web site
  if ($shipper eq 'FALSE') {
    $thisScript->param(-name=>$urlParams{'prot_cover'}, -value=>'');
    $thisScript->param(-name=>$urlParams{'prot_len'}, -value=>'');
    $thisScript->param(-name=>$urlParams{'prot_pi'}, -value=>'');
    $thisScript->param(-name=>$urlParams{'prot_tax_str'}, -value=>'');
    $thisScript->param(-name=>$urlParams{'prot_tax_id'}, -value=>'');
    $thisScript->param(-name=>$urlParams{'prot_seq'}, -value=>'');
  }

# save export_format in variable to make script more readable
  $export_format = "XML" unless ($export_format = $thisScript->param($urlParams{'export_format'}));

# verify the result file exists, decompress if necessary
# untaint the file path. This regex may need fine tuning
  $fileIn = $thisScript->param($urlParams{'file'})
    || die("No result file name supplied");
  ($fileIn) = $fileIn =~ /([\/\w\-.$%&()[\]:]+)/;
  if ($fileIn) {
    unless (-e &common_subs::decompress($fileIn)) {
      die("result file does not exist ", $fileIn);
    }
  } else {
    die("result filename could not be untainted");
  }
  
# create a datfile file object
  $objDatFile = new msparser::ms_datfile("../config/mascot.dat");
# abort on fatal error. Note that isValid() is true if there are only warnings
  unless ($objDatFile->isValid) {
    my $errorList = "Mascot Parser error(s):<BR>\n";
    my $objErr = $objDatFile->getErrorHandler();
    for (my $i = 1; $i <= $objErr->getNumberOfErrors(); $i++) {
      $errorList .= $objErr->getErrorNumber($i) 
        . ": " . $objErr->getErrorString($i) . "<BR>\n";
    }
    die $errorList;
  }
  $objMascotOptions = $objDatFile->getMascotOptions;
  $objUnigeneOptions = $objDatFile->getUniGeneOptions;

# see whether to use ms_mascotresfile::RESFILE_USE_CACHE flag
  my $resfileCache = $objMascotOptions->getResfileCache;
  if ($resfileCache) {
    $resfileCache = " " . $resfileCache . " ";
    if ($resfileCache =~ /[,\s]$myName[,\s]/i) {
      $resfileCache = $msparser::ms_mascotresfile::RESFILE_USE_CACHE;
    } else {
      $resfileCache = $msparser::ms_mascotresfile::RESFILE_NOFLAG;
    }
  } else {
    $resfileCache = $msparser::ms_mascotresfile::RESFILE_USE_CACHE;  # default
  }
  my $resultsCache = $objMascotOptions->getResultsCache;
  if ($resultsCache) {
    $resultsCache = " " . $resultsCache . " ";
    if ($resultsCache =~ /[,\s]$myName[,\s]/i) {
      $resultsCache = $msparser::ms_peptidesummary::MSPEPSUM_USE_CACHE;
    } else {
      $resultsCache = $msparser::ms_peptidesummary::MSPEPSUM_NONE;
    }
  } else {
    $resultsCache = $msparser::ms_peptidesummary::MSPEPSUM_USE_CACHE;  # default
  }
  my $resfileCacheDirectory = $objMascotOptions->getCacheDirectory;

# create Mascot Parser result file object
  $objResFile = new msparser::ms_mascotresfile(&common_subs::decompress($fileIn), 
                                                0, 
                                                "", 
                                                $resfileCache, 
                                                $resfileCacheDirectory);

# abort on fatal error. Note that isValid() remains true if there are only warnings
  unless ($objResFile->isValid) {
    my $errorList = "Mascot Parser error(s):<BR>\n";
    for (my $i = 1; $i <= $objResFile->getNumberOfErrors(); $i++) {
      $errorList .= $objResFile->getErrorNumber($i) 
        . ": " . $objResFile->getErrorString($i) . "<BR>\n";
    }
    die($errorList, " ", $fileIn);
  }
  
# create a Mascot Parser searchparams object
  $objParams = new msparser::ms_searchparams($objResFile);
  
# Security
  $sessionID = "" unless ($sessionID = $thisScript->param($urlParams{sessionid}));
  $session = new msparser::ms_session($sessionID);
  if ($session->isValid) {
    unless ($session->canResultsFileBeViewed($objParams->getUSERID)) {
      print $thisScript->header( -charset => "utf-8" );
      &common_subs::printHeader1("Matrix Science - Not authorised");
      &common_subs::printHeader2("", "Not authorised", 1);
      print "<B><FONT COLOR=#FF0000>Sorry, "
        . $session->getUserName 
        . " is not authorised to export this result report</FONT></B>";
      &common_subs::printFooter;
      print "</BODY>\n";
      print "</HTML>\n";
      exit 1;
    }
  } else {
    print $thisScript->header( -charset => "utf-8" );
    &common_subs::printHeader1("Matrix Science - Not logged in");
    &common_subs::printHeader2("", "Not logged in", 1);
    &common_subs::go2login(&common_subs::urlEscape($thisScript->self_url), $session->getLastError, &common_subs::urlEscape($session->getLastErrorString));
    &common_subs::printFooter;
    print "</BODY>\n";
    print "</HTML>\n";
    exit 1;
  }

# validate a variety of mascot.dat and URL parameters
  &validateParams();
  
# branch here if we require the form
  if ($thisScript->param($urlParams{'do_export'}) == 0) {
    &formatControls();
    exit 0;
  } elsif ($thisScript->param($urlParams{'do_export'}) == -1) {
    &display_args();
    exit 0;
  }

  if ($export_format eq "MascotDAT") {
  # Branch off to download raw Mascot result file
    exit &mascotDAT();
  }
  
  if ($export_format eq "MGF") {
  # Branch off to download MGF peak list
    exit &exportMGF();
  }
  
# pepXML and DTASelect only valid for MS/MS
  if ($export_format eq "pepXML" && $reportType eq 'concise') {
    die("pepXML format is not valid for peptide mass fingerprint results ", $fileIn);
  }
  if ($export_format eq "DTASelect" && $reportType eq 'concise') {
    die("DTASelect format is not valid for peptide mass fingerprint results ", $fileIn);
  }

# fixed settings for DTASelect
  if ($export_format eq "DTASelect") {
    $ShowSubSets = 1;
    $numHits = 0;
    $RequireBoldRed = 0;
  }

# if this is an old-style error tolerant search, may need to decompress the parent
  if ($objResFile->isErrorTolerant()) {
    if ($objParams->getErrTolParentFilename()) {
      &common_subs::decompress($objParams->getErrTolParentFilename());
    }
  # set value for $OldStyleErrTolReport
    if ($ShowAllFromErrorTolerant || $OnlyErrorTolerant) {
      $OldStyleErrTolReport = 1;
    } elsif (!$objResFile->doesSectionExist($msparser::ms_mascotresfile::SEC_ERRTOLSUMMARY)) {
      $OldStyleErrTolReport = 1;
    } else {
      $OldStyleErrTolReport = 0;
    }
  } else {
    $OldStyleErrTolReport = 0;
  }

# quant_subs.pl required for emPAI or if search includes quantitation
# emPAI is always on if we have MS/MS results and at least 100 spectra
# unless integrated decoy or old style ET
# if integrated ET, emPAI uses only non-ET matches
  if ($objParams->getQUANTITATION() 
    && lc($objParams->getQUANTITATION()) ne "none") {
    $quant_subs_active = 1;
  } elsif (!$anyPepSumMatch
    || ($objParams->getDECOY() > 0 && $ShowDecoyReport)
    || $thisScript->param($urlParams{'export_format'}) eq "DTASelect"
    || $thisScript->param($urlParams{'export_format'}) eq "pepXML") {
    $quant_subs_active = 0;
  } else {
    $quant_subs_active = 1;
  }
  my($minExpMoverZ, $maxExpMoverZ);
  if ($quant_subs_active) {
  # pull in the quantitation subroutines
    do "./quant_subs.pl";
  # byte leaking messes up output
    $quant_subs::noKeepAlive = 1;
  # make temporary file, if required
    &quant_subs::create_text_file(&common_subs::decompress($fileIn));
  # get experimental mass range estimate
    ($minExpMoverZ, $maxExpMoverZ) = &quant_subs::emPAI_mz_range($objResFile);
  }
       
# $objQuantMethod will encapsulate any quantitation method
# report can only handle multiplex and reporter protocols
# but may need $objQuantMethod for (say) mods and isotope shifts
  if ($objParams->getQUANTITATION() 
    && lc($objParams->getQUANTITATION()) ne "none") {

    $objQuantFile = new msparser::ms_quant_configfile();
    $objQuantFile->setSchemaFileName(
      "http://www.matrixscience.com/xmlns/schema/quantitation_2"
      . " ../html/xmlns/schema/quantitation_2/quantitation_2.xsd "
      . "http://www.matrixscience.com/xmlns/schema/quantitation_1"
      . " ../html/xmlns/schema/quantitation_1/quantitation_1.xsd");
	#"../html/xmlns/schema/quantitation_1"
      #. " ../html/xmlns/schema/quantitation_1/quantitation_1.xsd");
      
    if ($objResFile->getQuantitation($objQuantFile)) {
    # abort on fatal error. Note that isValid() remains true if there are only warnings
      unless ($objQuantFile->isValid) {
        die(&common_subs::checkErrorHandler($objQuantFile), " ", $fileIn);
      }
      $objQuantMethod = $objQuantFile->getMethodByName($objParams->getQUANTITATION());
      if ($objQuantMethod) {
        my $errorList = $objQuantFile->validateDocument();
        if ($errorList) {
          die("Mascot Parser error(s): ", $errorList, " ", $fileIn);
        }
        my $tempString = uc($objQuantMethod->getProtocol->getType());
        if ($quant_subs_active && ($tempString eq "MULTIPLEX" || $tempString eq "REPORTER")) {
        # pull in stats subroutines
          require "./quant_stats.pl";
        # read any URL arguments and create text for format controls 
        # text is not used, but need to call the routine to set or over-ride defaults
          &quant_subs::quantFormatControls($objQuantMethod, $thisScript, \%urlParams, \@quantFormatControlText);
        # warn if trying to use unsupported features
          &quant_subs::quantWarnings($objQuantMethod, \@quantWarnings);
        # preparation for specific protocols
          my($return, $errorString);
          if ($tempString eq "MULTIPLEX") {
            ($return, $errorString) = &quant_subs::prep_multiplex($objQuantMethod, $objParams, $objResFile);
            unless ($return) {
              die("Cannot proceed with quantitation: $errorString ", $fileIn);
            }
          } elsif ($tempString eq "REPORTER") {
            ($return, $errorString) = &quant_subs::prep_reporter($objQuantMethod, $objParams, $objResFile);
            unless ($return) {
              die("Cannot proceed with quantitation: $errorString ", $fileIn);
            }
          }
        }
      }
    }
  }

# create Mascot Parser summary object of the required type
  if ($reportType eq 'concise') {
    $msresFlags = $msparser::ms_mascotresults::MSRES_MAXHITS_OVERRIDES_MINPROB
                | $msparser::ms_mascotresults::MSRES_GROUP_PROTEINS 
                | $msparser::ms_mascotresults::MSRES_SHOW_SUBSETS;
    if (!$objResFile->isErrorTolerant()
      && $objParams->getDECOY() > 0
      && $ShowDecoyReport) {
      $msresFlags = $msresFlags | $msparser::ms_mascotresults::MSRES_DECOY;
    }
    $objSummary = new msparser::ms_proteinsummary(
      $objResFile, 
      $msresFlags, 
      $sigThreshold,
      $numHits
    );
  } else {
    $msresFlags = $msparser::ms_mascotresults::MSRES_MAXHITS_OVERRIDES_MINPROB
                | $msparser::ms_mascotresults::MSRES_GROUP_PROTEINS;
    if ($ShowSubSets > 0) {
      $msresFlags = $msresFlags | $msparser::ms_mascotresults::MSRES_SHOW_SUBSETS;
    }
    if ($RequireBoldRed) {
      $msresFlags = $msresFlags | $msparser::ms_mascotresults::MSRES_REQUIRE_BOLD_RED;
    }
    if ($objResFile->isErrorTolerant()) {
      if ($objResFile->doesSectionExist($msparser::ms_mascotresfile::SEC_ERRTOLSUMMARY)) {
      # new-style integrated ET search
        if ($OnlyErrorTolerant) {
          $msresFlags = $msresFlags | $msparser::ms_mascotresults::MSRES_ERR_TOL;
        } elsif ($NoErrorTolerant) {
        # parser default
        } else {
          $msresFlags = $msresFlags | $msparser::ms_mascotresults::MSRES_INTEGRATED_ERR_TOL;
        }
      }
      if ($ShowAllFromErrorTolerant) {
        $msresFlags = $msresFlags | $msparser::ms_mascotresults::MSRES_SHOW_ALL_FROM_ERR_TOL;
      }
    }
    if ($objResFile->getNumQueries() / $objResFile->getNumSeqsAfterTax() > $mudpitSwitch) {
      $msresFlags = $msresFlags | $msparser::ms_mascotresults::MSRES_MUDPIT_PROTEIN_SCORE;
    }
    if (!$objResFile->isErrorTolerant()
      && $objParams->getDECOY() > 0
      && $ShowDecoyReport) {
      $msresFlags = $msresFlags | $msparser::ms_mascotresults::MSRES_DECOY;
    }
    $objSummary = new msparser::ms_peptidesummary(
      $objResFile, 
      $msresFlags,
      $sigThreshold, 
      $numHits, 
      $UniGeneFile,
      $ignoreIonsScoreBelow,
      $minPepLen,
      "",
      $resultsCache
    );
  }
  
# abort on fatal error. Note that isValid() is true if there are only warnings
  unless ($objResFile->isValid) {
    my $errorList = "Mascot Parser error(s):<BR>\n";
    for (my $i = 1; $i <= $objResFile->getNumberOfErrors(); $i++) {
      $errorList .= $objResFile->getErrorNumber($i) 
        . ": " . $objResFile->getErrorString($i) . "<BR>\n";
    }
    die($errorList, " ", $fileIn);
  }

# create an ms_umod_configfile object from the result file unimod section
  $objUmodConfigFile = new msparser::ms_umod_configfile;
  unless ($objResFile->getUnimod($objUmodConfigFile)) {
  # old results file with no unimod section, use current unimod.xml
    $objUmodConfigFile = new msparser::ms_umod_configfile("../config/unimod.xml",
      "../html/xmlns/schema/unimod_2/unimod_2.xsd");
  }
        
# add in any modifications locally defined in any quant method
  if ($objQuantMethod) {  
    for (my $i = 0; $i < $objQuantMethod->getNumberOfModificationGroups(); $i++) {
      my $objModGroup = $objQuantMethod->getModificationGroupByNumber($i);
      for (my $j = 0; $j < $objModGroup->getNumberOfLocalDefinitions(); $j++) {
        &quant_subs::includeLocalDef($objModGroup->getLocalDefinition($j), $objUmodConfigFile);
      }
    }
    for (my $i = 0; $i < $objQuantMethod->getNumberOfComponents(); $i++) {
      my $objComponent = $objQuantMethod->getComponentByNumber($i);
      for (my $j = 0; $j < $objComponent->getNumberOfModificationGroups(); $j++) {
        my $objModGroup = $objComponent->getModificationGroupByNumber($j);
        for (my $k = 0; $k < $objModGroup->getNumberOfLocalDefinitions(); $k++) {
          &quant_subs::includeLocalDef($objModGroup->getLocalDefinition($k), $objUmodConfigFile);
        }
      }
    }
  }

# use this to create an ms_masses object
  $objMassesFile = new msparser::ms_masses($objUmodConfigFile); 
  
# create an ms_modfile object from the ms_umod_configfile object
# this now has all the mods used in the search
  $objModFile = new msparser::ms_modfile($objUmodConfigFile, $msparser::ms_umod_configfile::MODFILE_FLAGS_ALL);
# abort on fatal error. Note that isValid() is true if there are only warnings
  unless ($objModFile->isValid) {
    my $errorList = "Mascot Parser error(s):<BR>\n";
    my $objErr = $objModFile->getErrorHandler();
    for (my $i = 1; $i <= $objErr->getNumberOfErrors(); $i++) {
      $errorList .= $objErr->getErrorNumber($i) 
        . ": " . $objErr->getErrorString($i) . "<BR>\n";
    }
    die $errorList;
  }
    
# msparser MASS_TYPE
  $mass_type = $msparser::MASS_TYPE_MONO;
  if (lc($objParams->getMASS()) eq "average") {
    $mass_type = $msparser::MASS_TYPE_AVE;
  }

# Create hash for masses and variable mods
  my $i = 1;
  while (my $nextKey = $objResFile->enumerateSectionKeys($msparser::ms_mascotresfile::SEC_MASSES, $i)) {
    if ($nextKey =~ /^delta(\d+)/i) {
      my $letter = $1;
      if ($letter > 9) {
        $letter = chr($1+55);
      }
      ($vmMass{$letter}, $vmString{$letter}) = 
        split(/,/, $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_MASSES, $nextKey), 2);
    } elsif ($nextKey =~ /^Ignore(\d+)$/i) {
    } elsif ($nextKey =~ /^FixedMod(\d+)$/i) {
    } elsif ($nextKey =~ /^FixedModResidues(\d+)$/i) {
    } elsif ($nextKey =~ /^FixedModNeutralLoss(\d+)$/i) {
    } elsif ($nextKey =~ /^NeutralLoss(\d+)$/i) {
    } elsif ($nextKey =~ /^NeutralLoss(\d+)_master$/i) {
    } elsif ($nextKey =~ /^NeutralLoss(\d+)_slave$/i) {
    } elsif ($nextKey =~ /^NeutralLoss\d_/i) {
    } elsif ($nextKey =~ /^ReqPepNeutralLoss(\d+)$/i) {
    } elsif ($nextKey =~ /^PepNeutralLoss(\d+)$/i) {
    } else {
      $masses{lc($nextKey)} = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_MASSES, $nextKey);
    }
    $i++;
  }
# result files earlier than 1.9 don't list electron mass
  $masses{electron} = 0.000549 unless $masses{electron};
  
# parse out result file name root
  ($fileNameRoot) = $fileIn =~ /([^\/\\]*)\.dat$/;

# output HTTP header
  if ($ENV{'SERVER_NAME'}) {
    if ($export_format eq "XML" || $export_format eq "pepXML") {
      print $thisScript->header( -type => "text/xml",
                                 -charset => "utf-8",
                                 -attachment => "$fileNameRoot.xml");
    } elsif ($export_format eq "mzIdentML") {
      print $thisScript->header( -type => "text/xml",
                                 -charset => "utf-8",
                                 -attachment => "$fileNameRoot.mzid");
    } elsif ($export_format eq "CSV") {
      print $thisScript->header( -type => "application/vnd.ms-excel",
                                 -charset => "utf-8",
                                 -attachment => "$fileNameRoot.csv");
    } elsif ($export_format eq "DTASelect") {
      print $thisScript->header( -type => "text/plain",
                                 -charset => "utf-8",
                                 -attachment => "DTASelect.txt");
    } else {
      print $thisScript->header( -charset => "utf-8" );
    }
  }

# print document opening tags
  if ($export_format eq "XML") {
    print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    print "<mascot_search_results xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"";
    print " xmlns=\"http://www.matrixscience.com/xmlns/schema/mascot_search_results_2\"";
    print " xsi:schemaLocation=\"http://www.matrixscience.com/xmlns/schema/mascot_search_results_2 ";
    if ($ENV{'SERVER_NAME'}) {
      $URI = $thisScript->url(-path_info=>1);
      ($URI) = $URI =~ /^(.*\/).+?\/$myName/;
      print $URI;
    } else {
      $URI = "../";
      print "http://www.matrixscience.com/";
    }
    print "xmlns/schema/mascot_search_results_2/mascot_search_results_2.xsd\"";
    print "  majorVersion=\"2\" minorVersion=\"1\">\n";
  } elsif ($export_format eq "CSV") {
    if ($ENV{'SERVER_NAME'}) {
      $URI = $thisScript->url(-path_info=>1);
      ($URI) = $URI =~ /^(.*\/).+?\/$myName/;
    } else {
      $URI = "../";
    }
  } elsif ($export_format eq "pepXML") {
    print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    print "<msms_pipeline_analysis";
    print " xmlns=\"http://regis-web.systemsbiology.net/pepXML\"";
    print " xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"";
    print " xsi:schemaLocation=\"http://regis-web.systemsbiology.net/pepXML ";
    if ($ENV{'SERVER_NAME'}) {
      $URI = $thisScript->url(-path_info=>1);
      ($URI) = $URI =~ /^(.*\/).+?\/$myName/;
      print $URI;
    } else {
      $URI = "../";
      print "http://www.matrixscience.com/";
    }
    print "xmlns/schema/pepXML_v18/pepXML_v18.xsd\"";
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime(time);
    my $timestamp = sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", 
      $year+1900, $mon+1, $mday, $hour, $min, $sec);
    # optional name
    print " date=\"$timestamp\"";
    print " summary_xml=\"$fileNameRoot.xml\">\n";
  } elsif ($export_format eq "mzIdentML") {
    print "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    print "<mzIdentML id=\"\" version=\"1.0.0\"\n";
    print "             xsi:schemaLocation=\"http://psidev.info/psi/pi/mzIdentML/1.0 ";
    if ($ENV{'SERVER_NAME'}) {
      $URI = $thisScript->url(-path_info=>1);
      ($URI) = $URI =~ /^(.*\/).+?\/$myName/;
      print $URI;
    } else {
      $URI = "../";
      print "http://www.matrixscience.com/";
    }
    print "xmlns/schema/mzIdentML/mzIdentML1.0.0.xsd\"\n";
    print "             xmlns=\"http://psidev.info/psi/pi/mzIdentML/1.0\"\n";
    print "             xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n";
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    printf "             creationDate=\"%4d-%02d-%02dT%02d:%02d:%02d\">\n", $year+1900,$mon+1,$mday,$hour,$min,$sec;
  } elsif ($export_format eq "DTASelect") {
  } elsif ($ENV{'SERVER_NAME'}) {
    my $HTMLtitle = "\n\n<HTML>\n<HEAD>\n<TITLE>$export_format Report (";
    if ($objParams->getCOM()) {
      $HTMLtitle .= &noXmlTag($objParams->getCOM());
    } else {
      $HTMLtitle .= $fileIn;
    }
    $HTMLtitle .= ")</TITLE>\n";
    print $HTMLtitle;
    print "</HEAD>\n\n";
    print "<BODY>\n";
    print "<PRE>\n";
  }
  
  if ($export_format eq "pepXML") {
  # Branch off for ISB pepXML
    &pepXML();
    print "</msms_pipeline_analysis>\n";
    exit 0;    
  }

  if ($export_format eq "mzIdentML") {
  # Branch off for PSI mzIdentML
    &mzIdentML();
    print "</mzIdentML>\n";
    exit 0;    
  }

  if ($export_format eq "DTASelect") {
  # Branch off for Scripps DTASelect
    &DTASelect();
    exit 0;    
  }

# search information
  if ($thisScript->param($urlParams{'search_master'})) {
    if ($thisScript->param($urlParams{'show_header'})) {
      &outputHeader();
    }
    if ($thisScript->param($urlParams{'show_decoy'})) {
      &outputDecoy();
    }
    if ($thisScript->param($urlParams{'show_mods'})) {
      if ($objParams->getMODS || $objParams->getFixedModsName(1)) {
        &outputFixedMods();
      }
      if ($objParams->getIT_MODS || $objParams->getVarModsName(1)) {
        &outputVarMods();
      }
    }
    if ($thisScript->param($urlParams{'show_params'})) {
      &outputParams();
    }
    if ($thisScript->param($urlParams{'show_format'})) {
      &outputFormat();
    }
    if ($thisScript->param($urlParams{'show_masses'})) {
      &outputMasses();
    }
  }
  
  if ($thisScript->param($urlParams{'protein_master'})) {

    if ($export_format eq "XML") {
      print "<hits>\n";
    } elsif ($export_format eq "CSV") {
      print "\n\"Protein hits\"$delimiter\"--------------------------------------------------------\"\n\n";
    }
  
  # print column headers for CSV format
    if ($export_format eq "CSV") {
      my $string = "";
      foreach my $field (@columns) {
        if ($field =~ /^pep/ && !$thisScript->param($urlParams{'peptide_master'})) {
          next;
        }
        if ($thisScript->param($urlParams{lc($field)})) {
          if ($field eq "pep_seq") {
            $string .= "pep_res_before" . $delimiter . $field . $delimiter . "pep_res_after" . $delimiter;
          } elsif ($field eq "pep_var_mod") {
            $string .= $field . $delimiter . "pep_var_mod_pos" . $delimiter;
          } elsif ($field eq "prot_matches" && $anyPepSumMatch) {
            $string .= $field . $delimiter . "prot_matches_sig" . $delimiter . "prot_sequences" . $delimiter . "prot_sequences_sig" . $delimiter;
          } else {
            $string .= $field . $delimiter;
          }
        }
      }
      if ($string) {
        chop $string;
      }
      print $string . "\n";
    }
  
  # determine correction factors for quantitation normalisation, if required 
    if ($objQuantMethod 
      && ($thisScript->param($urlParams{'pep_quant'}) 
      || $thisScript->param($urlParams{'prot_quant'}))) {
      &quant_subs::quantNormalise($objQuantMethod, $objParams, $objResFile, $objSummary, $sigThreshold, \@quantDataByQuery, \@quantCorrFactor);
    }

  # start of MAIN LOOP to enumerate the protein hits
    my $thisHit = 1;
    my $averageThreshold = $objSummary->getAvePeptideIdentityThreshold(1 / $sigThreshold);
    $objProtein = $objSummary->getHit($thisHit);
    while (defined($objProtein)) {
    # export the hit
      &outputHit($objProtein, $thisHit);
    # and get the next primary hit
      $thisHit++;
      $objProtein = $objSummary->getHit($thisHit);
    }
  # end of MAIN LOOP to enumerate the protein hits
  
    if ($export_format eq "XML") {
      print "</hits>\n";
    } 
    
  }

  if ($thisScript->param($urlParams{'show_unassigned'})) {
    &outputUnassigned();
  }

  if ($thisScript->param($urlParams{'query_master'})) {
    &outputQueries();
  }
  
# print document closing tags
  if ($export_format eq "XML") {
    print "</mascot_search_results>\n";
  } elsif ($export_format eq "CSV") {
  } elsif ($ENV{'SERVER_NAME'}) {
    print "</PRE>\n";
    print "</BODY>\n";
    print "</HTML>\n";
  }

# Good Night
  exit 0;

###############################################################################
# &mustGetProteinDescription()
# tries very hard to get a description string
# $_[0] is an accession
# $_[1] ref to %fastaTitles (cache)
# $_[2] database number
# globals:
# my($objSummary, $objParams, $shipper);
###############################################################################

sub mustGetProteinDescription {

  my ($accession, $fastaTitles_ref, $dbIdx) = @_;
  
# first try the Mascot Parser summary object  
  my $description = $objSummary->getProteinDescription($accession, $dbIdx);
  if ($description) {
    return $description;
  }
# if this is the public web site, give up
  if ($shipper eq 'FALSE') {
    return;
  }
# next try the cache
  $description = ${ $fastaTitles_ref }{$dbIdx . "::" . $accession};
  if ($description == -1) {
  # failed to get a title when we tried the first time, so give up
    return;
  } elsif ($description) {
    return $description;
  }
# finally, try ms-getseq.exe
  my @retVal = &common_subs::getExtInfo($accession, 0, $objParams->getDB($dbIdx), "title");
  if ($retVal[0]) {
  # success, save in cache
    ${ $fastaTitles_ref }{$dbIdx . "::" . $accession} = &common_subs::parseTitle($retVal[1], $objParams->getDB($dbIdx));
    return ${ $fastaTitles_ref }{$dbIdx . "::" . $accession};
  } else {
  # failure, set cache entry to -1
    ${ $fastaTitles_ref }{$dbIdx . "::" . $accession} = -1;
    return;
  }
    
}

###############################################################################
# &mustGetProteinMass()
# tries very hard to get a protein mass
# $_[0] accession string
# $_[1] summary object
# $_[2] parameters object
# $_[3] ref to %fastaMasses (cache)
# $_[4] frame number, 0 for protein, -1 for mixed
# $_[5] database number
###############################################################################

sub mustGetProteinMass {

  my ($accession, $objSummary, $objParams, $fastaMasses_ref, $frame, $dbIdx) = @_;
  
# if protein contains matches in mixed frames, then choose frame 1 to get approximate mass
  if ($frame == -1) {$frame = 1}

# first try the Mascot Parser summary object  
  my $mass = $objSummary->getProteinMass($accession, $dbIdx);
  if ($mass) {
    return $mass;
  }
  
# if this is the public web site, give up
  if ($shipper eq 'FALSE') {
    return;
  }
  
# next try the cache
  $mass = ${ $fastaMasses_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"};
  if ($mass == -1) {
  # failed to get a title when we tried the first time, so give up
    return;
  } elsif ($mass) {
  # mass was in the cache
    return $mass;
  }
  
# OK, have to get the sequence and calculate the mass
  my $seqString = &mustGetProteinSeq($accession, $frame, $dbIdx);
  if ($seqString) {
    $mass = $objSummary->getSequenceMass($seqString);
    ${ $fastaMasses_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"} = $mass;
  } else {
 # Cannot retrieve sequence
    $mass = ""; 
    ${ $fastaMasses_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"} = -1;
  }
  
  return $mass;
  
}

###############################################################################
# &getProteinpI()
# use cache for protein pI
# $_[0] accession string
# $_[1] summary object
# $_[2] parameters object
# $_[3] ref to %fastapI (cache)
# $_[4] frame number, 0 for protein, -1 for mixed
# $_[5] database number
###############################################################################

sub getProteinpI {

  my ($accession, $objSummary, $objParams, $fastapI_ref, $frame, $dbIdx) = @_;

# if protein contains matches in mixed frames, then return empty handed
  if ($frame == -1) {return}

# first try the cache
  my $pI = ${ $fastapI_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"};
  if ($pI == -1) {
  # failed to calculate pI when we tried the first time, so give up
    return;
  } elsif ($pI) {
  # pI was in the cache
    return $pI;
  }
  
# calculate pI from ms-getseq.exe
  my @retVal = &common_subs::getExtInfo($accession, $frame, $objParams->getDB($dbIdx), "pI");
  if ($retVal[0]) {
    if ($retVal[1] =~ /plain\s+([\d\.]+)\s*$/) {
      $pI = $1;
    }
  }
  if ($pI) {
    ${ $fastapI_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"} = $pI;
  } else {
    $pI = ""; 
    ${ $fastapI_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"} = -1;
  }
  
  return $pI;
  
}

###############################################################################
# &getProteinLen()
# use cache for protein length
# $_[0] accession string
# $_[1] summary object
# $_[2] parameters object
# $_[3] ref to %fastaLen (cache)
# $_[4] frame number, 0 for protein, -1 for mixed
# $_[5] database index for access
###############################################################################

sub getProteinLen {

  my ($accession, $objSummary, $objParams, $fastaLen_ref, $frame, $dbIdx) = @_;

# if protein contains matches in mixed frames, then choose frame 1 to get approximate length
  if ($frame == -1) {$frame = 1}

# first try the cache
  my $Len = ${ $fastaLen_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"};
  if ($Len == -1) {
  # failed to calculate length when we tried the first time, so give up
    return;
  } elsif ($Len) {
  # length was in the cache
    return $Len;
  }
  
# calculate length from ms-getseq.exe
  my @retVal = &common_subs::getExtInfo($accession, $frame, $objParams->getDB($dbIdx), "length");
  if ($retVal[0]) {
    if ($retVal[1] =~ /plain\s+([\d\.]+)\s*$/) {
      $Len = $1;
    }
  }
  if ($Len) {
    ${ $fastaLen_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"} = $Len;
  } else {
    $Len = ""; 
    ${ $fastaLen_ref }{$dbIdx . "::" . $accession . "<" . $frame . ">"} = -1;
  }
  
  return $Len;
  
}

###############################################################################
# &mustGetProteinSeq()
# tries very hard to get a description string
# $_[0] is an accession
# $_[2] frame number, 0 for protein, (-1 for mixed is not allowed)
# $_[3] database number
# globals:
# my($objParams, $shipper);
###############################################################################

sub mustGetProteinSeq {

  my ($accession, $frame, $dbIdx) = @_;

# if this is the public web site, give up
  if ($shipper eq 'FALSE') {
    return;
  }
  
# cannot get sequence for mixed frame match
  if ($frame < 0 || $frame > 6) {
    return;
  }
  
# first try the cache
  my $seq = $seqCache{$dbIdx . "::" . $accession . "<" . $frame . ">"};
  if ($seq == -1) {
  # failed to get a seq when we tried the first time, so give up
    return;
  } elsif ($seq) {
  # success, sequence was in cache
    return $seq;
  }

# Get sequence from ms-getseq.exe
  my @retVal = &common_subs::getExtInfo($accession, $frame, $objParams->getDB($dbIdx), "sequence");
  if ($retVal[0]) {
    $seq = &common_subs::parseSequence($retVal[1], $retVal[2]);
    if ($seq) {
      $seqCache{$dbIdx . "::" . $accession . "<" . $frame . ">"} = $seq;
    } else {
    # Empty sequence
      $seqCache{$dbIdx . "::" . $accession . "<" . $frame . ">"} = -1;
    }
  } else {
 # unable to retrieve sequence
    $seqCache{$dbIdx . "::" . $accession . "<" . $frame . ">"} = -1;
  }
  
  return $seq;
    
}

###############################################################################
# &validateParams()
# validate a variety of mascot.dat and URL parameters
# globals:
# my($massDP, $minPepLen, $ignoreIonsScoreBelow, $reportType,
# $objParams, $objResFile, $thisScript, %urlParams, $sigThreshold,
# $numHits, $ShowSubSets, $RequireBoldRed, $mudpitSwitch,
# $ShowAllFromErrorTolerant, $UniGeneFile, $fileIn);
###############################################################################

sub validateParams{

  my $tempString;

# $massDP determines precision on peptide mass values
# default is 2 decimal places for peptides
  $massDP = 0 unless ($massDP = $objMascotOptions->getMassDecimalPlaces);
  $massDP = int($massDP);
  if ($massDP < 1 || $massDP > 6) {
    $massDP = 2;
  }
  
# peptides shorter than $minPepLen are not interesting
# default is to ignore anything shorter than 6 residues
  $minPepLen = 0 unless ($minPepLen = $objMascotOptions->getMinPepLenInPepSummary);
  $minPepLen = int($minPepLen); 
  if ($minPepLen < 1 || $minPepLen > 9) {
    $minPepLen = 6;
  }
  
# ignoreIonsScoreBelow is a threshold on MS/MS ions scores
# a value of 0 specifies that all peptides are included (default)
# a value greater than 1 indicates an absolute score cutoff 
# a value less than 1 is treated as a probability threshold 
  if (defined($thisScript->param($urlParams{'_ignoreionsscorebelow'}))
    && $thisScript->param($urlParams{'_ignoreionsscorebelow'}) >= 0) {
    $ignoreIonsScoreBelow = $thisScript->param($urlParams{'_ignoreionsscorebelow'}) + 0;
  } else {
    $ignoreIonsScoreBelow = 0 unless ($ignoreIonsScoreBelow = $objMascotOptions->getIgnoreIonsScoreBelow);
    if ($ignoreIonsScoreBelow < 0) {
      $ignoreIonsScoreBelow = 0;
    }
  }

# if queries / entries greater than $mudpitSwitch, default 0.001, switch to Mudpit scoring
  if (defined($thisScript->param($urlParams{'_server_mudpit_switch'}))
    && $thisScript->param($urlParams{'_server_mudpit_switch'}) > 0) {
    $mudpitSwitch = $thisScript->param($urlParams{'_server_mudpit_switch'}) + 0;
  } else {
    $mudpitSwitch = 0.001;
    my $tempString;
    $tempString = 0 unless ($tempString = $objMascotOptions->getMudpitSwitch);
    if ($tempString > 0) {
      $mudpitSwitch = $tempString;
    }
  }

# If $ShowDecoyReport is true, a report for the integrated decoy search is shown
  if (defined($thisScript->param($urlParams{'_show_decoy_report'}))) {
    $ShowDecoyReport = $thisScript->param($urlParams{'_show_decoy_report'}) + 0;
  } else {
    $ShowDecoyReport = 0;
  }

# set $section parameters to point to the correct sections
  $sec_peptides = $msparser::ms_mascotresfile::SEC_PEPTIDES;
  $sec_summary = $msparser::ms_mascotresfile::SEC_SUMMARY;
  if (!$objResFile->isErrorTolerant()
    && $objParams->getDECOY() > 0
    && $ShowDecoyReport) {
    $sec_peptides = $msparser::ms_mascotresfile::SEC_DECOYPEPTIDES;
    $sec_summary = $msparser::ms_mascotresfile::SEC_DECOYSUMMARY;
  }
# $objResFile->anyPeptideSummaryMatches($sec_peptides) is used constantly
  $anyPepSumMatch = $objResFile->anyPeptideSummaryMatches($sec_peptides);

# Report type is either peptide or concise
  $reportType = 'concise';
  if ($anyPepSumMatch) {
    $reportType = 'peptide';
  }

# set $sigThreshold to probability significance threshold, default 0.05
  if (defined($thisScript->param($urlParams{'_sigthreshold'}))
    && $thisScript->param($urlParams{'_sigthreshold'}) >= 1E-18
    && $thisScript->param($urlParams{'_sigthreshold'}) < 1) {
    $sigThreshold = $thisScript->param($urlParams{'_sigthreshold'}) + 0;
  } else {
    $sigThreshold = 0 unless ($sigThreshold = $objMascotOptions->getSigThreshold);
    if ($sigThreshold < 1E-18 || $sigThreshold >= 1) {
      $sigThreshold = 0.05;
    }
  }
  
# set number of hits to display & make sure it is reasonable
# if the value of REPORT is 'AUTO', $numHits is set to 0
  if (defined($thisScript->param($urlParams{'report'}))) {
    $numHits = int($thisScript->param($urlParams{'report'}));
  } else {
    $numHits = int($objParams->getREPORT());
  }
  if ($numHits < 0){
    $numHits = 20;
  }
  
# Display a sub-set protein hit if it is missing less than $ShowSubSets fraction of the protein score of the main hit
  if (defined($thisScript->param($urlParams{'_showsubsets'}))) {
    $ShowSubSets = $thisScript->param($urlParams{'_showsubsets'}) + 0;
  } else {
    $ShowSubSets = 0 unless ($ShowSubSets = $objMascotOptions->getShowSubsets);
  }

# If RequireBoldRed is true, only display protein hits that include at least one bold, red peptide match
  if (defined($thisScript->param($urlParams{'_requireboldred'}))) {
    $RequireBoldRed = $thisScript->param($urlParams{'_requireboldred'}) + 0;
  } elsif ($thisScript->param($urlParams{'do_export'})) {
    $RequireBoldRed = 0;
  } else {
    $RequireBoldRed = 0 unless ($RequireBoldRed = $objMascotOptions->isRequireBoldRed);
  }

# If $ShowAllFromErrorTolerant is true, all hits from an error tolerant search are shown
  if (defined($thisScript->param($urlParams{'_showallfromerrortolerant'}))) {
    $ShowAllFromErrorTolerant = $thisScript->param($urlParams{'_showallfromerrortolerant'}) + 0;
  }  
# If $OnlyErrorTolerant is true, display only error tolerant matches from a new style error tolerant search
  if (defined($thisScript->param($urlParams{'_onlyerrortolerant'}))) {
    $OnlyErrorTolerant = $thisScript->param($urlParams{'_onlyerrortolerant'}) + 0;
  }
# If $NoErrorTolerant is true, display only standard matches from a new style error tolerant search
  if (defined($thisScript->param($urlParams{'_noerrortolerant'}))) {
    $NoErrorTolerant = $thisScript->param($urlParams{'_noerrortolerant'}) + 0;
  }
# pick up illegal combinations
  if ($NoErrorTolerant) {
    $ShowAllFromErrorTolerant = 0;
  }
  if ($OnlyErrorTolerant && $NoErrorTolerant) {
    die("Meaningless to specify both _onlyerrortolerant and _noerrortolerant", $fileIn);
  }

# $UniGeneFile is the path to the Unigene index to be used for clustering EST matches
  if (my $species = $thisScript->param($urlParams{'unigene'})) {
    if ($species eq "None") {
      $UniGeneFile = "";
    } else {
      $UniGeneFile = $objUnigeneOptions->getPropValStringByName($species)
        || die("cannot find UniGene $species in mascot.dat ", $fileIn);
      $UniGeneFile =~ s/\s*$//;
    }
  } else {
    $UniGeneFile = "";
  }
  
}

###############################################################################
# &formatControls()
# Print format form
# globals:
# my($myName, $objResFile, $objParams, $numHits, $sigThreshold, $fileIn,
# $ignoreIonsScoreBelow, $ShowSubSets, $thisScript, $RequireBoldRed, 
# %urlParams, $mudpitSwitch);
###############################################################################

sub formatControls {

  print $thisScript->header( -charset => "utf-8", -expires => '-1d' );

  &common_subs::printHeader1("Matrix Science - Mascot - Export search results");

  print <<'end_of_static_HTML_text_block';

<SCRIPT LANGUAGE="JavaScript">
<!-- Begin hiding from older browsers 

  function check_slaves(checkBox, form){
    var checkState = checkBox.checked;
    var checkName = checkBox.name;
end_of_static_HTML_text_block

  if ($shipper eq 'TRUE') {
    print "    var shipper = 1;\n";
  } else {
    print "    var shipper = 0;\n";
  }

  print <<'end_of_static_HTML_text_block';
    if (checkName == "search_master") {
      if (form.show_header) {
        form.show_header.disabled = !checkState;
      }
      if (form.show_decoy) {
        form.show_decoy.disabled = !checkState;
      }
      if (form.show_mods) {
        form.show_mods.disabled = !checkState;
      }
      if (form.show_params) {
        form.show_params.disabled = !checkState;
      }
      if (form.show_format) {
        form.show_format.disabled = !checkState;
      }
      if (form.show_masses) {
        form.show_masses.disabled = !checkState;
      }
    } else if (checkName == "protein_master") {
      if (form.prot_score) {
        form.prot_score.disabled = !checkState;
      }
      if (form.prot_thresh) {
        form.prot_thresh.disabled = !checkState;
      }
      if (form.prot_expect) {
        form.prot_expect.disabled = !checkState;
      }
      if (form.prot_desc) {
        form.prot_desc.disabled = !checkState;
      }
      if (form.prot_mass) {
        form.prot_mass.disabled = !checkState;
      }
      if (form.prot_matches) {
        form.prot_matches.disabled = !checkState;
      }
      if (form.prot_cover) {
        form.prot_cover.disabled = !checkState || !shipper;
      }
      if (form.prot_len) {
        form.prot_len.disabled = !checkState || !shipper;
      }
      if (form.prot_empai) {
        form.prot_empai.disabled = !checkState;
      }
      if (form.prot_pi) {
        form.prot_pi.disabled = !checkState || !shipper;
      }
      if (form.prot_tax_str) {
        form.prot_tax_str.disabled = !checkState || !shipper;
      }
      if (form.prot_tax_id) {
        form.prot_tax_id.disabled = !checkState || !shipper;
      }
      if (form.prot_seq) {
        form.prot_seq.disabled = !checkState || !shipper;
      }
      if (form.prot_quant) {
        form.prot_quant.disabled = !checkState;
      }
      if (form.peptide_master) {
        form.peptide_master.checked = !checkState;
        form.peptide_master.click();
        form.peptide_master.disabled = !checkState;
        form.peptide_master.click();
      }
    } else if (checkName == "peptide_master") {
      if (form.pep_exp_mr) {
        form.pep_exp_mr.disabled = !checkState;
      }
      if (form.pep_exp_z) {
        form.pep_exp_z.disabled = !checkState;
      }
      if (form.pep_calc_mr) {
        form.pep_calc_mr.disabled = !checkState;
      }
      if (form.pep_delta) {
        form.pep_delta.disabled = !checkState;
      }
      if (form.pep_start) {
        form.pep_start.disabled = !checkState;
      }
      if (form.pep_end) {
        form.pep_end.disabled = !checkState;
      }
      if (form.pep_miss) {
        form.pep_miss.disabled = !checkState;
      }
      if (form.pep_score) {
        form.pep_score.disabled = !checkState;
      }
      if (form.pep_homol) {
        form.pep_homol.disabled = !checkState;
      }
      if (form.pep_ident) {
        form.pep_ident.disabled = !checkState;
      }
      if (form.pep_expect) {
        form.pep_expect.disabled = !checkState;
      }
      if (form.pep_seq) {
        form.pep_seq.disabled = !checkState;
      }
      if (form.pep_frame) {
        form.pep_frame.disabled = !checkState;
      }
      if (form.pep_var_mod) {
        form.pep_var_mod.disabled = !checkState;
      }
//      if (form.show_unassigned) {
//        form.show_unassigned.disabled = !checkState;
//      }
      if (form.pep_num_match) {
        form.pep_num_match.disabled = !checkState;
      }
      if (form.pep_scan_title) {
        form.pep_scan_title.disabled = !checkState;
      }
      if (form.pep_quant) {
        form.pep_quant.disabled = !checkState;
      }
      if (form.prot_empai) {
        form.prot_empai.disabled = !checkState;
      }
      if (form.prot_quant) {
        form.prot_quant.disabled = !checkState;
      }
    } else if (checkName == "query_master") {
      if (form.query_title) {
        form.query_title.disabled = !checkState;
      }
      if (form.query_qualifiers) {
        form.query_qualifiers.disabled = !checkState;
      }
      if (form.query_params) {
        form.query_params.disabled = !checkState;
      }
      if (form.query_peaks) {
        form.query_peaks.disabled = !checkState;
      }
      if (form.query_raw) {
        form.query_raw.disabled = !checkState;
      }
    }
  }

// End hiding Javascript from old browsers. -->
</SCRIPT>


end_of_static_HTML_text_block

  &common_subs::printHeader2("", "Export search results", 1);
  
  print <<"end_of_static_HTML_text_block";
  <FORM ACTION="./$myName" NAME="Re-format" METHOD="POST" ENCTYPE="multipart/form-data">
  <INPUT TYPE="hidden" NAME="file" VALUE="$fileIn">
  <INPUT TYPE="hidden" NAME="do_export" VALUE=1>
  <INPUT TYPE="hidden" NAME="prot_hit_num" VALUE=1>
  <INPUT TYPE="hidden" NAME="prot_acc" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_query" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_rank" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_isbold" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_isunique" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_exp_mz" VALUE=1>
  <INPUT TYPE="hidden" NAME="_showallfromerrortolerant" VALUE=$ShowAllFromErrorTolerant>
  <INPUT TYPE="hidden" NAME="_onlyerrortolerant" VALUE=$OnlyErrorTolerant>
  <INPUT TYPE="hidden" NAME="_noerrortolerant" VALUE=$NoErrorTolerant>
  <INPUT TYPE="hidden" NAME="_show_decoy_report" VALUE=$ShowDecoyReport>
  <INPUT TYPE="hidden" NAME="sessionid" VALUE="$sessionID">
end_of_static_HTML_text_block

# pass through any quantitation parameters
  while (my($key, $value) = each %urlParams) {
    if ($key =~ /^_quant/i || lc($key) eq "_min_precursor_charge") {
      print "  <INPUT TYPE=\"hidden\" NAME=\"$key\" VALUE=\"" . $thisScript->param($urlParams{$key}) . "\">\n";
    }
  }

  print <<"end_of_static_HTML_text_block";
  <TABLE BORDER=0 CELLSPACING=1 CELLPADDING=3>
  
    <TR>
      <TD NOWRAP><H2>Export search results</H2></TD>
      <TD ALIGN=RIGHT VALIGN=baseline><A HREF="../help/export_help.html">Help</A></TD>
    </TR>

    <TR>
      <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>
        Export format </TD>
      <TD BGCOLOR=#EEEEFF NOWRAP>
        <SELECT NAME=\"export_format\" onChange=\"this.form.do_export.value=0; this.form.submit(); return true\">
end_of_static_HTML_text_block

  if ($export_format eq "XML" || $export_format eq "") {
    print "         <OPTION SELECTED>XML</OPTION>\n";
  } else {
    print "         <OPTION>XML</OPTION>\n";
  }
  if ($export_format eq "CSV") {
    print "         <OPTION SELECTED>CSV</OPTION>\n";
  } else {
    print "         <OPTION>CSV</OPTION>\n";
  }
  if ($reportType eq 'peptide' && $export_format eq "pepXML") {
    print "         <OPTION SELECTED>pepXML</OPTION>\n";
  } elsif ($reportType eq 'peptide') {
    print "         <OPTION>pepXML</OPTION>\n";
  }
  if ($export_format eq "mzIdentML") {
    print "         <OPTION SELECTED>mzIdentML</OPTION>\n";
  } else {
    print "         <OPTION>mzIdentML</OPTION>\n";
  }
  if ($reportType eq 'peptide' && $export_format eq "DTASelect") {
    print "         <OPTION SELECTED>DTASelect</OPTION>\n";
  } elsif ($reportType eq 'peptide') {
    print "         <OPTION>DTASelect</OPTION>\n";
  }
  if ($export_format eq "MascotDAT") {
    print "         <OPTION value=\"MascotDAT\" SELECTED>Mascot DAT File</OPTION>\n";
  } else {
    print "         <OPTION value=\"MascotDAT\">Mascot DAT File</OPTION>\n";
  }
  if ($export_format eq "MGF") {
    print "         <OPTION value=\"MGF\" SELECTED>MGF Peak List</OPTION>\n";
  } else {
    print "         <OPTION value=\"MGF\">MGF Peak List</OPTION>\n";
  }
  print "        </SELECT>\n";
  print "      </TD>\n";
  print "    </TR>\n";

  unless ($export_format eq "MascotDAT" || $export_format eq "MGF") {
      
    print <<"end_of_static_HTML_text_block";
    <TR>
      <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>
        Significance threshold p&lt; </TD> 
      <TD BGCOLOR=#EEEEFF NOWRAP>
        <INPUT NAME="_sigthreshold" TYPE=text SIZE=8 VALUE=$sigThreshold>
      </TD> 
    </TR>
  
end_of_static_HTML_text_block
  
    unless ($export_format eq "pepXML" || $export_format eq "DTASelect") {
      print "   <TR>\n";
      print "     <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>\n";
      print "       Max. number of hits </TD>\n";
      print "     <TD BGCOLOR=#EEEEFF NOWRAP>\n";
      if ($numHits) {
        print "       <INPUT NAME=\"report\" TYPE=text SIZE=5 VALUE=$numHits>\n";
      } else {
        print "       <INPUT NAME=\"report\" TYPE=text SIZE=5 VALUE=\"AUTO\">\n";
      }
      print "     </TD>\n"; 
      print "   </TR>\n";
    }
    
    unless ($export_format eq "pepXML") {
      if ($anyPepSumMatch) {
  
        print "  <TR>\n";
        print "    <TD BGCOLOR=#EEEEFF ALIGN=RIGHT>\n";
        print "     Protein scoring </TD>\n";
        print "    <TD BGCOLOR=#EEEEFF>\n";
        print "      Standard <INPUT TYPE=\"radio\" VALUE=99999999 NAME=\"_server_mudpit_switch\"";
        unless ($objResFile->getNumQueries() / $objResFile->getNumSeqsAfterTax() > $mudpitSwitch){
          print " CHECKED";
        }
        print ">&nbsp;&nbsp;&nbsp;MudPIT&nbsp;<INPUT TYPE=\"radio\" VALUE=0.000000001 NAME=\"_server_mudpit_switch\"";
        if ($objResFile->getNumQueries() / $objResFile->getNumSeqsAfterTax() > $mudpitSwitch){
          print " CHECKED";
        }
        print ">\n";
        print "     </TD>\n";
        print "   </TR>\n";
  
        print "   <TR>\n";
        print "     <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>\n";
        print "       Ions score cut-off </TD>\n";
        print "     <TD BGCOLOR=#EEEEFF NOWRAP>\n";
        print "       <INPUT NAME=\"_ignoreionsscorebelow\" TYPE=text SIZE=5 VALUE=$ignoreIonsScoreBelow>\n";
        print "     </TD>\n";
        print "   </TR>\n";
  
      }
    }
      
    unless ($export_format eq "pepXML" || $export_format eq "DTASelect") {
      if ($thisScript->param($urlParams{show_same_sets})) {
        $tmpChecked = "CHECKED";
      } else {
        $tmpChecked = "";
      }
      &checkBox("Include same-set protein hits<BR>(additional proteins that span<BR>the same set of peptides)", 
        "show_same_sets", $tmpChecked, "");
      print "   <TR>\n";
      print "     <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>\n";
      print "       Include sub-set protein hits<BR>(additional proteins that span<BR>a sub-set of peptides) </TD>\n";
      print "     <TD BGCOLOR=#EEEEFF NOWRAP>\n";
      print "       <INPUT NAME=\"_showsubsets\" TYPE=text SIZE=5 VALUE=$ShowSubSets>\n";
      print "     </TD>\n"; 
      print "   </TR>\n";
      if ($anyPepSumMatch) {
        if ($RequireBoldRed) {
          &checkBox("Require bold red", "_requireboldred", "CHECKED", "");
        } else {
          &checkBox("Require bold red", "_requireboldred", "", "");
        }      
      }
    # UniGene
      my %tempUniGene; # use hash to eliminate duplicates
      for (my $i=1; $i <= $objParams->getNumberOfDatabases; $i++) {
        if (my $tempString = $objUnigeneOptions->getPropValStringByName($objParams->getDB($i))) {
          my @tempList = split(/\s+/, $tempString);
          foreach (@tempList) {
            $tempUniGene{$_} = 1;
          }
        }
      }
      if (%tempUniGene) {
        print "  <TR>\n";
        print "    <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>\n";
        print "UniGene index </TD>";
        print "    <TD BGCOLOR=#EEEEFF>\n";
        print "      <SELECT NAME=\"UNIGENE\">\n";
        $tempUniGene{"None"} = 1;
        my $species = "None";
        if ($thisScript->param($urlParams{'unigene'})) {
          $species = $thisScript->param($urlParams{'unigene'});
        }
        foreach (keys %tempUniGene) {
          print "  <OPTION";
          if ($species eq $_) {
            print " SELECTED";
          }
          print ">$_</OPTION>\n";
        }
        print "</SELECT>\n";
        print "    </TD>\n";
        print "  </TR>\n";
      }
    }
      
    unless ($export_format eq "pepXML" || $export_format eq "DTASelect" || $export_format eq "mzIdentML") {

      print "   <TR>\n";
      print "     <TD NOWRAP ALIGN=RIGHT COLSPAN=2>&nbsp;</TD>\n";
      print "   </TR>\n";
  
      print "   <TR>\n";
      print "     <TD NOWRAP>\n";
      print "     <H3>Search Information</H3></TD>\n";
      print "     <TD NOWRAP VALIGN=top>\n";
      print "     <INPUT TYPE=\"checkbox\" NAME=\"search_master\" VALUE=1 CHECKED onClick=\"check_slaves(this, this.form)\"></TD>\n";
      print "   </TR>\n";
  
      &checkBox("Header", "show_header", "CHECKED", "");
      if ($objParams->getDECOY() > 0 && !$ShowDecoyReport) {
        &checkBox("Decoy", "show_decoy", "CHECKED", "");
      }
      &checkBox("Modification deltas", "show_mods", "CHECKED", "");
      &checkBox("Search parameters", "show_params", "CHECKED", "");
      &checkBox("Format parameters", "show_format", "CHECKED", "");
      &checkBox("Residue masses", "show_masses", "", "");
    }
  
    print "   <TR>\n";
    print "     <TD NOWRAP ALIGN=RIGHT COLSPAN=2>&nbsp;</TD>\n";
    print "   </TR>\n";
  
    print "   <TR>\n";
    print "     <TD NOWRAP>\n";
    if ($export_format eq "pepXML" || $export_format eq "DTASelect" || $export_format eq "mzIdentML") {
      print "     <H3>Optional Protein Hit Information</H3></TD>\n";
      print "     <TD NOWRAP VALIGN=top>\n";
      print "     &nbsp;</TD>\n";
    } else {
      print "     <H3>Protein Hit Information</H3></TD>\n";
      print "     <TD NOWRAP VALIGN=top>\n";
      print "     <INPUT TYPE=\"checkbox\" NAME=\"protein_master\" VALUE=1 CHECKED onClick=\"check_slaves(this, this.form)\"></TD>\n";
    }
    print "   </TR>\n";
  
    unless ($export_format eq "pepXML" || $export_format eq "DTASelect" || $export_format eq "mzIdentML") {
      &checkBox("Score", "prot_score", "CHECKED", "");
      unless ($anyPepSumMatch) {
        &checkBox("Significance threshold", "prot_thresh", "CHECKED", "");
        &checkBox("Expectation value", "prot_expect", "CHECKED", "");
      }
    }
    &checkBox("Description<SUP>*</SUP>", "prot_desc", "CHECKED", "");
    unless ($export_format eq "mzIdentML") {
      &checkBox("Mass (Da)<SUP>*</SUP>", "prot_mass", "CHECKED", "");
    }
    my $disabled = "";
    if ($shipper eq 'FALSE') {
      $disabled = "disabled";
    }
    unless ($export_format eq "pepXML" || $export_format eq "DTASelect" || $export_format eq "mzIdentML") {
      &checkBox("Number of queries matched", "prot_matches", "CHECKED", "");
      &checkBox("Percent coverage<SUP>**</SUP>", "prot_cover", "", $disabled);
    }
    unless ($export_format eq "pepXML") {
      &checkBox("Length in residues<SUP>**</SUP>", "prot_len", "", $disabled);
    }
    unless ($export_format eq "mzIdentML") {
      &checkBox("pI<SUP>**</SUP>", "prot_pi", "", $disabled);
    }
    unless ($export_format eq "pepXML" || $export_format eq "DTASelect") {
      &checkBox("Taxonomy<SUP>**</SUP>", "prot_tax_str", "", $disabled);
      &checkBox("Taxonomy ID<SUP>**</SUP>", "prot_tax_id", "", $disabled);
      &checkBox("Protein sequence<SUP>**</SUP>", "prot_seq", "", $disabled);
    }
    if ($anyPepSumMatch && ($export_format eq "XML" || $export_format eq "CSV")) {
      &checkBox("emPAI", "prot_empai", "", $disabled);
      if ($objParams->getQUANTITATION() && lc($objParams->getQUANTITATION()) ne "none") {
        &checkBox("Protein quantitation", "prot_quant", "", "");
      }
    }
      
    print <<"end_of_static_HTML_text_block";

    <TR>
      <TD NOWRAP COLSPAN=2><SUP>* Occasionally requires information to be retrieved from external utilities, which can be slow<BR>
      ** Always requires information to be retrieved from external utilities, which can be slow</SUP></TD>
    </TR>

end_of_static_HTML_text_block
  
    unless ($export_format eq "pepXML" || $export_format eq "DTASelect" || $export_format eq "mzIdentML") {
      print "   <TR>\n";
      print "     <TD NOWRAP>\n";
      print "     <H3>Peptide Match Information</H3></TD>\n";
      print "     <TD NOWRAP VALIGN=top>\n";
      print "     <INPUT TYPE=\"checkbox\" NAME=\"peptide_master\" VALUE=1 CHECKED onClick=\"check_slaves(this, this.form)\"></TD>\n";
      print "   </TR>\n";
    
      &checkBox("Experimental Mr (Da)", "pep_exp_mr", "CHECKED", "");
      if ($anyPepSumMatch) {
        &checkBox("Experimental charge", "pep_exp_z", "CHECKED", "");
      } else {
        &checkBox("Experimental charge", "pep_exp_z", "", "");
      }
      &checkBox("Calculated Mr (Da)", "pep_calc_mr", "CHECKED", "");
      &checkBox("Mass error (Da)", "pep_delta", "CHECKED", "");
      if ($anyPepSumMatch) {
        &checkBox("Start", "pep_start", "", "");
        &checkBox("End", "pep_end", "", "");
      } else {
        &checkBox("Start", "pep_start", "CHECKED", "");
        &checkBox("End", "pep_end", "CHECKED", "");
      }
      &checkBox("Number of missed cleavages", "pep_miss", "CHECKED", "");
      if ($anyPepSumMatch) {
        &checkBox("Score", "pep_score", "CHECKED", "");
        &checkBox("Homology threshold", "pep_homol", "", "");
        &checkBox("Identity threshold", "pep_ident", "", "");
        &checkBox("Expectation value", "pep_expect", "CHECKED", "");
      }
      &checkBox("Sequence", "pep_seq", "CHECKED", "");
    # enabling / disabling frame checkbox is too messy 
    # because we don't want to create a summary object at this stage
      &checkBox("Frame number", "pep_frame", "", "");
      &checkBox("Variable Modifications", "pep_var_mod", "CHECKED", "");
      unless ($objResFile->isPMF()){
        &checkBox("Number of fragment<BR>ion matches", "pep_num_match", "", "");
        &checkBox("Query title", "pep_scan_title", "CHECKED", "");
      }
      if ($anyPepSumMatch) {
        if ($objParams->getQUANTITATION() && lc($objParams->getQUANTITATION()) ne "none") {
          &checkBox("Peptide quantitation", "pep_quant", "", "");
        }
        &checkBox("Unassigned queries<BR>(peptide matches not<BR>assigned to protein hits)", "show_unassigned", "", "");
      }
  
      print "   <TR>\n";
      print "     <TD NOWRAP ALIGN=RIGHT COLSPAN=2>&nbsp;</TD>\n";
      print "   </TR>\n";
    }
    
    unless ($export_format eq "pepXML" || $export_format eq "DTASelect" || $objResFile->isPMF()) {
      print "   <TR>\n";
      print "     <TD NOWRAP>\n";
      print "     <H3>Query Level Information</H3></TD>\n";
      print "     <TD NOWRAP VALIGN=top>\n";
      unless ($export_format eq "mzIdentML") {
        print "     <INPUT TYPE=\"checkbox\" NAME=\"query_master\" VALUE=1 onClick=\"check_slaves(this, this.form)\"></TD>\n";
      } else {
        print "     &nbsp;</TD>\n";
      }
      print "   </TR>\n";
  
      my $sDisabelled = "";
      unless ($export_format eq "mzIdentML") {
        $sDisabelled = "disabled";
        &checkBox("Query title", "query_title", "", $sDisabelled);
        &checkBox("seq(), comp(), tag(), etc.", "query_qualifiers", "", $sDisabelled);
        &checkBox("Query level<BR>search parameters", "query_params", "", $sDisabelled);
        &checkBox("MS/MS Peak lists", "query_peaks", "", $sDisabelled);
      }
      unless ($export_format eq "mzIdentML") {
        &checkBox("Raw peptide match data", "query_raw", "", $sDisabelled);
      } else {
        &checkBox("Matched Fragment Ions", "query_raw", "", $sDisabelled);
        &checkBox("Export data for all Queries", "query_all", "", $sDisabelled);
      }
    }

  }  # closure of unless ($export_format eq "MascotDAT" || $export_format eq "MGF") {

  print <<"end_of_static_HTML_text_block";

    <TR>
      <TD NOWRAP ALIGN=RIGHT COLSPAN=2>&nbsp;</TD>
    </TR>
    <TR>
      <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=LEFT>
        <INPUT TYPE="button" VALUE="Show command line arguments" onClick="this.form.do_export.value=-1; this.form.submit(); return true">
      </TD>
      <TD BGCOLOR=#EEEEFF NOWRAP>
        <INPUT TYPE="button" VALUE="Export search results" onClick="this.form.do_export.value=1; this.form.submit(); return true">
      </TD>
    </TR>
    
  </TABLE>
  
</FORM>

end_of_static_HTML_text_block

  &common_subs::printFooter;

  print "</BODY>\n";
  print "</HTML>\n";

}

###############################################################################
# &checkBox()
# Print row of table for a checkbox option
###############################################################################

sub checkBox {
  
  my($description, $name, $checked, $disabled) = @_;
  
  print <<"end_of_static_HTML_text_block";
    <TR>
      <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>
        $description </TD>
      <TD BGCOLOR=#EEEEFF NOWRAP>
        <INPUT $disabled TYPE="checkbox" NAME="$name" VALUE=1 $checked>
      </TD>
    </TR> 
end_of_static_HTML_text_block
  
}

###############################################################################
# &outputHit()
# export a hit block
# $_[0] protein object
# $_[1] hit number
# globals:
# my($objSummary, %urlParams, $thisScript, $export_format);
###############################################################################

sub outputHit {

  my $objProtein = shift;
  my $hitNum = shift;
  
  if ($export_format eq "XML") {
    print "<hit number=\"$hitNum\">\n";
  }

# The primary protein hit
  &outputProtein($objProtein, $hitNum, 1);
  my $score4Main = $objProtein->getScore();

# Other proteins that match the same set of peptides
  if ($thisScript->param($urlParams{'show_same_sets'})) {
    my $i = 1;
    while (($objProtein = $objSummary->getNextSimilarProtein($hitNum, $i)) != 0)  {
      &outputProtein($objProtein, $hitNum, 0);
      $i++;
    }
  }
  
# Other proteins that match a sub-set of peptides
  if ($thisScript->param($urlParams{'_showsubsets'}) > 0) {
    my $i = 1;
    while (($objProtein = $objSummary->getNextSubsetProtein($hitNum, $i)) != 0) {
      unless ($objProtein->getScore() < $score4Main * (1 - $ShowSubSets)) {
        &outputProtein($objProtein, $hitNum, 0);
      }
      $i++;
    }
  }
  
  if ($export_format eq "XML") {
    print "</hit>\n";
  } 

}
  
###############################################################################
# &outputProtein()
# export a protein block
# $_[0] protein object
# $_[1] hit number
# globals:
# my(%urlParams, $export_format, $thisScript);
###############################################################################

sub outputProtein {

  my $objProtein = shift;
  my $hitNum = shift;
  my $primary = shift;

  undef @quantDataByHit;
  undef %PAI;
  
  my $dbNumPrefix = "";
  if ($objParams->getNumberOfDatabases > 1 && !$objProtein->isPMFMixture) {
    $dbNumPrefix = $objProtein->getDB . "::";
  }

  if ($export_format eq "XML") {
    print "<protein accession=\"" . $dbNumPrefix . $objProtein->getAccession() . "\">\n";
  }
  &printProteinRow($objProtein, $hitNum);
  
  if ($export_format eq "CSV") {
    print $delimiter;
  }

  if ($thisScript->param($urlParams{'peptide_master'})) {
    &printPeptideRows($objProtein, $hitNum, $primary);
  } else {
    if ($export_format eq "CSV") {
      print "\n";
    }
  }

# quantitation information is only output for primary protein hit  
  if ($primary) {
  # and only available if we have looped through the peptides
    if ($quant_subs_active && $thisScript->param($urlParams{'peptide_master'})) {
      if ($thisScript->param($urlParams{'prot_empai'})) {
        my $emPAI;
        if (%PAI) {
          $emPAI = &quant_subs::calc_emPAI(\%PAI, $objSummary, $objProtein, $objResFile, $minExpMoverZ, $maxExpMoverZ, $objParams);
        }
        if ($emPAI) {
        # insert emPAI information
          if ($export_format eq "CSV") {
            print $delimiter . "\"emPAI\"" . $delimiter . sprintf("%.2f", $emPAI);
          } elsif ($export_format eq "XML") {
            print "<prot_empai>" . sprintf("%.2f", $emPAI) . "</prot_empai>\n";
          }
        } else {
          if ($export_format eq "CSV") {
            print $delimiter . $delimiter;
          }
        }
      }
    # insert quantitation summary information for the primary hit
      if ($thisScript->param($urlParams{'prot_quant'}) && $objQuantMethod) {
        my @dumpText;
        my $retText = &quant_subs::quant_summary($objQuantMethod, $objParams, $objResFile, 
          \@quantDataByQuery, \@quantDataByHit, \@quantCorrFactor, $hitNum, \@dumpText, 1);
        my @summaryText = split(/\n/, $retText);
      # remove header line
        shift @summaryText;
        if ($export_format eq "CSV") {
          print $delimiter . "\"Quantitation summary for protein\"";
        }
        foreach (@summaryText) {
          my($rName, $rValue, $rN, $rSD, $rSignificant) = split(/\t/, $_);
          if ($export_format eq "CSV") {
            print $delimiter
              . "\"" . &noQuotes($rName) . "\""
              . $delimiter
              . "\"$rValue\""
              . $delimiter
              . "\"$rN\""
              . $delimiter
              . "\"$rSD\""
              . $delimiter
              . "\"$rSignificant\"";
          } elsif ($export_format eq "XML") {
            print "<quant_prot_ratio name=\"" 
              . &noXmlTag($rName) 
              . "\" ratio=\"$rValue\" n=\"$rN\" sd=\"$rSD\" significant=\"$rSignificant\" />\n";
          }
        }
      }
    }
  }
  
  if ($export_format eq "XML") {
    print "</protein>\n";
  } else {
    print "\n"; 
  }

}

###############################################################################
# &printPeptideRows()
# export a peptides block
# $_[0] protein object
# $_[1] hit number
# globals:
# my($objSummary, $export_format);
###############################################################################

sub printPeptideRows {
  
  my $objProtein = shift;
  my $hitNum = shift;
  my $primary = shift;
  
  my $needSpacer = 0;
  my $eol = "";   # need to suppress final EOL for CSV so as to add quant info in-line
  for (my $i = 1; $i <= $objProtein->getNumPeptides(); $i++) {
    if ($objProtein->getPeptideDuplicate($i) != $msparser::ms_protein::DUPE_DuplicateSameQuery) {
      print $eol;
      my $queryNum = $objProtein->getPeptideQuery($i);
      my $objPeptide = $objSummary->getPeptide($queryNum, $objProtein->getPeptideP($i));
      if ($export_format eq "CSV" && $needSpacer) {
        &printProteinRow($objProtein, $hitNum);
        print $delimiter;
      # print $hitNum . $delimiter x $protColumnCount;
      } else {
        $needSpacer = 1;
      }
      if ($export_format eq "XML") {
        print "<peptide query=\"$queryNum\"";
        if ($objPeptide->getAnyMatch() && !$objResFile->isPMF()) {
          print " rank=\"" . $objPeptide->getPrettyRank() . "\"";
          if ($objProtein->getPeptideIsBold($i)) {
            print " isbold=\"1\"";
          } else {
            print " isbold=\"0\"";
          }
          if ($objSummary->isPeptideUnique($queryNum, $objPeptide->getRank)) {
            print " isunique=\"1\"";
          } else {
            print " isunique=\"0\"";
          }
        }
        print ">\n";
      }
      my $string = &printPeptideDetails($objPeptide, $queryNum, $i, $objProtein, 1);
      if ($primary 
        && $objQuantMethod
        && ($thisScript->param($urlParams{'pep_quant'})
        || $thisScript->param($urlParams{'prot_quant'}))) {
        $string .= &printQuantDetails($objPeptide, $queryNum, $i, $objProtein, $hitNum);
      }

      chop $string;
      if ($export_format eq "XML") {
        $string =~ s/>$delimiter</>\n</g;
      }
      if ($string) {
        print $string;
      }
      if ($export_format eq "XML") {
        print "\n</peptide>\n";
      } 
      if ($export_format eq "CSV") {
        $eol = "\n";
      }

      if ($quant_subs_active && $thisScript->param($urlParams{'prot_empai'})) {
        &quant_subs::add2PAI(\%PAI, $objPeptide, $objSummary, $objResFile, $queryNum, $sigThreshold, $OldStyleErrTolReport);
      }

    }
  }
  
}

###############################################################################
# &outputUnassigned()
# export an unassigned block
# $_[0] 
# globals:
# my($objSummary, $fileIn, $export_format);
###############################################################################

sub outputUnassigned {

  
  if ($export_format eq "XML") {
    print "<unassigned>\n";
  } elsif ($export_format eq "CSV") {
    print "\n\"Peptide matches not assigned to protein hits\"$delimiter\"--------------------------------------------------------\"\n\n";
  }

  $objSummary->createUnassignedList($msparser::ms_mascotresults::QUERY);
  if ($objSummary->getNumberOfUnassigned() > 0) {
  # enumerate the peptides in the unassigned list
    for (my $i = 1; $i <= $objSummary->getNumberOfUnassigned(); $i++) {
      my $objPeptide = $objSummary->getUnassigned($i);
      if (defined($objPeptide)) {
        if ($export_format eq "CSV") {
          print $delimiter x $protColumnCount;
        }
        if ($export_format eq "XML") {
          print "<u_peptide query=\"" . $objPeptide->getQuery() . "\"";
          if ($objPeptide->getAnyMatch() && !$objResFile->isPMF()) {
            print " rank=\"" . $objPeptide->getPrettyRank() . "\"";
            if ($objSummary->getUnassignedIsBold($i)) {
              print " isbold=\"1\"";
            } else {
              print " isbold=\"0\"";
            }
            print " isunique=\"0\"";
          }
          print ">\n";
        }
        my $string = &printPeptideDetails($objPeptide, $objPeptide->getQuery(), $i, "", 1);
        chop $string;
        if ($export_format eq "XML") {
          $string =~ s/>$delimiter</>\n</g;
        }
        if ($string) {
          print $string . "\n";
        }
        if ($export_format eq "XML") {
          print "</u_peptide>\n";
        } 
      } else {
        die("Undefined peptide object ", $fileIn);
      }
    }
  }
  
  if ($export_format eq "XML") {
    print "</unassigned>\n";
  } 

}

###############################################################################
# &printProteinRow()
# output fields for a protein match
# $_[0] protein object
# $_[1] hit number
# globals:
# my($objSummary, $fileIn, %urlParams, $objParams, $export_format, 
# %fastaMasses, $thisScript);
###############################################################################

sub printProteinRow {
  
  my $objProtein = shift;
  my $hitNum = shift;
  
  $protColumnCount = 0;

  my $dbNumPrefix = "";
  if ($objParams->getNumberOfDatabases > 1 && !$objProtein->isPMFMixture) {
    $dbNumPrefix = $objProtein->getDB . "::";
  }

  my $string = "";
  if ($export_format eq "CSV") {
    $string .=  $hitNum . $delimiter;
    $string .= "\"" . &noQuotes($dbNumPrefix . $objProtein->getAccession()) . "\"$delimiter";
  }
  $protColumnCount++;
  $protColumnCount++;
  if ($thisScript->param($urlParams{'prot_desc'})) {
    $string .= &formatElement($export_format, "", 1, "prot_desc", 
      &mustGetProteinDescription($objProtein->getAccession(), \%fastaTitles, $objProtein->getDB)) . $delimiter;
    $protColumnCount++;
  }
  if ($thisScript->param($urlParams{'prot_score'})) {
    $string .= &formatElement($export_format, "", 0, "prot_score", 
      sprintf("%.0f", $objProtein->getScore())) . $delimiter;
    $protColumnCount++;
  }
  if ($thisScript->param($urlParams{'prot_thresh'})) {
    $string .= &formatElement($export_format, "", 0, "prot_thresh", 
      $objSummary->getProteinThreshold(1 / $sigThreshold)) . $delimiter;
    $protColumnCount++;
  }
  if ($thisScript->param($urlParams{'prot_expect'})) {
    $string .= &formatElement($export_format, "", 0, "prot_expect", 
      sprintf("%.2g", 1 / $objSummary->getProbOfProteinBeingRandomMatch($objProtein->getScore()))) . $delimiter;
    $protColumnCount++;
  }
  if ($thisScript->param($urlParams{'prot_mass'})) {
    if (&mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame(), $objProtein->getDB)) {
      $string .= &formatElement($export_format, "", 0, "prot_mass", 
        sprintf("%.0f", &mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame(), $objProtein->getDB))) . $delimiter;
    } else {
      if ($export_format eq "CSV") {
        $string .= $delimiter;
      }
    }
    $protColumnCount++;
  }
  if ($thisScript->param($urlParams{'prot_matches'})) {
    $string .= &formatElement($export_format, "", 0, "prot_matches", 
      $objProtein->getNumDisplayPeptides(0)) . $delimiter;
    $protColumnCount++;
    if ($anyPepSumMatch) {
      $string .= &formatElement($export_format, "", 0, "prot_matches_sig", 
        $objProtein->getNumDisplayPeptides(1)) . $delimiter;
      $protColumnCount++;
      $string .= &formatElement($export_format, "", 0, "prot_sequences", 
        $objProtein->getNumDistinctPeptides(0, $msparser::ms_protein::DPF_SEQUENCE)) . $delimiter;
      $protColumnCount++;
      $string .= &formatElement($export_format, "", 0, "prot_sequences_sig", 
        $objProtein->getNumDistinctPeptides(1, $msparser::ms_protein::DPF_SEQUENCE)) . $delimiter;
      $protColumnCount++;
    }
  }
  if ($thisScript->param($urlParams{'prot_cover'}) || $thisScript->param($urlParams{'prot_len'})) {
    my $coverage = "";
    my $length = &getProteinLen($objProtein->getAccession(), $objSummary, $objParams, \%fastaLen, $objProtein->getFrame(), $objProtein->getDB);
    if ($length) {
    # accurate
      $coverage = $objProtein->getCoverage() * 100 / $length;
    } else {
      my $protMass = &mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame(), $objProtein->getDB);
      if ($protMass) {
      # approximate
        $coverage = $objProtein->getCoverage() * 100 * 110 / $protMass;
      }
    }
    if ($thisScript->param($urlParams{'prot_cover'})) {
      if ($coverage) {
        $string .= &formatElement($export_format, "", 0, "prot_cover", 
          sprintf("%.1f", $coverage)) . $delimiter;
      } else {
        if ($export_format eq "CSV") {        
          $string .= $delimiter;
        }
      }
      $protColumnCount++;
    }
    if ($thisScript->param($urlParams{'prot_len'})) {
      if ($length) {
        $string .= &formatElement($export_format, "", 0, "prot_len", $length) . $delimiter;
      } else {
        if ($export_format eq "CSV") {        
          $string .= $delimiter;
        }
      }
      $protColumnCount++;
    }
  }
  if ($thisScript->param($urlParams{'prot_pi'})) {
    my $pI = &getProteinpI($objProtein->getAccession(), $objSummary, $objParams, \%fastapI, $objProtein->getFrame(), $objProtein->getDB);
    if ($pI) {
      $string .= &formatElement($export_format, "", 0, "prot_pi", $pI) . $delimiter;
    } else {
      if ($export_format eq "CSV") {        
        $string .= $delimiter;
      }
    }
    $protColumnCount++;
  }
  if ($thisScript->param($urlParams{'prot_tax_str'}) || $thisScript->param($urlParams{'prot_tax_id'})) {
    my $db = $objParams->getDB($objProtein->getDB);
    my $ac = $objProtein->getAccession();
    my @getTax;
    if (open SOCK, "../x-cgi/ms-gettaxonomy.exe 1 $db \"$ac\" |") { 
      @getTax = <SOCK>;
      close SOCK; 
    }
    my $accNum = "xxxxxxxx";
    my $species = "";
    my $taxID = "";
    if (@getTax && $#getTax > 1) {
      ($accNum, $taxID, $species) = (split(/\s+/, $getTax[2], 3));
      if ($accNum ne $ac) {
        $species = "";
        $taxID = "";
      }
    }
    if ($thisScript->param($urlParams{'prot_tax_str'})) {
      if ($species) {
        chomp $species;
        $string .= &formatElement($export_format, "", 1, "prot_tax_str", $species) . $delimiter;
      } else {
        if ($export_format eq "CSV") {        
          $string .= $delimiter;
        }
      }
      $protColumnCount++;
    }
    if ($thisScript->param($urlParams{'prot_tax_id'})) {
      if ($taxID) {
        $string .= &formatElement($export_format, "", 0, "prot_tax_id", $taxID) . $delimiter;
      } else {
        if ($export_format eq "CSV") {        
          $string .= $delimiter;
        }
      }
      $protColumnCount++;
    }
  }
  if ($thisScript->param($urlParams{'prot_seq'})) {
    my $seq = &mustGetProteinSeq($objProtein->getAccession(), $objProtein->getFrame(), $objProtein->getDB);
    if ($seq) {
      $string .= &formatElement($export_format, "", 0, "prot_seq", $seq) . $delimiter;
    } else {
      if ($export_format eq "CSV") {        
        $string .= $delimiter;
      }
    }
    $protColumnCount++;
  }
  
  chop $string;
  if ($export_format eq "XML") {
    $string =~ s/>$delimiter</>\n</g;
  }
  if ($string) {
    print $string;
    if ($export_format eq "XML") {
      print "\n";
    }
  }

}

###############################################################################
# &printPeptideDetails()
# returns fields for a single peptide match
# $_[0] peptide object
# $_[1] query number
# $_[2] peptide number
# $_[3] protein object (empty for unassigned list)
# $_[4] 1 to begin line with query number
# globals:
# my($objSummary, %urlParams, $objResFile, $massDP, $thisScript, 
# $export_format, $sigThreshold);
###############################################################################

sub printPeptideDetails {
  
  my ($objPeptide, $queryNum, $i, $objProtein, $printQueryNum) = @_;

  my $string = "";
  if ($export_format eq "CSV") {
    if ($printQueryNum) {
      $string .= $queryNum . $delimiter;
    }
    if ($objPeptide->getAnyMatch() && !$objResFile->isPMF()) {
      $string .= $objPeptide->getPrettyRank() . $delimiter;
      if ($printQueryNum) {
        if ($objProtein) {
          if ($objProtein->getPeptideIsBold($i)) {
            $string .= "1" . $delimiter;
          } else {
            $string .= "0" . $delimiter;
          }
          if ($objSummary->isPeptideUnique($queryNum, $objPeptide->getRank)) {
            $string .= "1" . $delimiter;
          } else {
            $string .= "0" . $delimiter;
          }
        } elsif ($objSummary->getUnassignedIsBold($i)) {
          $string .= "1" . $delimiter;
          $string .= "0" . $delimiter;
        } else {
          $string .= "0" . $delimiter;
          $string .= "0" . $delimiter;
        }
      } else {
        $string .= $delimiter . $delimiter;
      }
    } else {
      $string .= $delimiter . $delimiter . $delimiter;
    }
  }
  $string .= &formatElement($export_format, "", 0, "pep_exp_mz",
    sprintf("%." . $massDP . "f", $objPeptide->getObserved())) . $delimiter;
  if ($thisScript->param($urlParams{'pep_exp_mr'})) {
    my $mrExpt = $objResFile->getObservedMrValue($queryNum);
    if ($objPeptide->getAnyMatch) {
      $mrExpt = $objPeptide->getMrExperimental;    # only works if there's a match
    }
    $string .= &formatElement($export_format, "", 0, "pep_exp_mr",
      sprintf("%." . $massDP . "f", $mrExpt)) . $delimiter;
  }
  if ($thisScript->param($urlParams{'pep_exp_z'})) {
    $string .= &formatElement($export_format, "", 0, "pep_exp_z", $objPeptide->getCharge()) . $delimiter;
  }
  if ($thisScript->param($urlParams{'pep_calc_mr'})) {
    if ($objPeptide->getAnyMatch()) {
      $string .= &formatElement($export_format, "", 0, "pep_calc_mr", 
        sprintf("%." . $massDP . "f", $objPeptide->getMrCalc())) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_delta'})) {
    if ($objPeptide->getAnyMatch()) {
      $string .= &formatElement($export_format, "", 0, "pep_delta", 
        sprintf("%." . $massDP . "f", $objPeptide->getDelta())) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_start'})) {
    if ($objProtein) {
      $string .= &formatElement($export_format, "", 0, "pep_start", 
        $objProtein->getPeptideStart($i)) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_end'})) {
    if ($objProtein) {
      $string .= &formatElement($export_format, "", 0, "pep_end", 
        $objProtein->getPeptideEnd($i)) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_miss'})) {
    if ($objPeptide->getAnyMatch()) {
      $string .= &formatElement($export_format, "", 0, "pep_miss", 
        $objPeptide->getMissedCleavages()) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_score'})) {
    if ($objPeptide->getAnyMatch()) {
      $string .= &formatElement($export_format, "", 0, "pep_score", 
        $objPeptide->getIonsScore()) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_homol'})) {
    if ($objPeptide->getAnyMatch() &&
      $objSummary->getHomologyThreshold($queryNum, 1 / $sigThreshold)) {
      if ($objResFile->isErrorTolerant() && $objSummary->getPeptide($queryNum, 1)->getIsFromErrorTolerant()) {
        if ($export_format eq "CSV") {
          $string .= $delimiter;
        }
      } else {
        $string .= &formatElement($export_format, "", 0, "pep_homol", 
          $objSummary->getHomologyThreshold($queryNum, 1 / $sigThreshold)) . $delimiter;
      }
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_ident'})) {
    if ($objPeptide->getAnyMatch() &&
      $objSummary->getPeptideIdentityThreshold($queryNum, 1 / $sigThreshold) &&
      $objSummary->getPeptideIdentityThreshold($queryNum, 1 / $sigThreshold) > -1) {
      if ($objResFile->isErrorTolerant() && $objSummary->getPeptide($queryNum, 1)->getIsFromErrorTolerant()) {
        if ($export_format eq "CSV") {
          $string .= $delimiter;
        }
      } else {
        $string .= &formatElement($export_format, "", 0, "pep_ident", 
          $objSummary->getPeptideIdentityThreshold($queryNum, 1 / $sigThreshold)) . $delimiter;
      }
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_expect'})) {
    if ($objPeptide->getAnyMatch()) {
      if ($objResFile->isErrorTolerant() && $objSummary->getPeptide($queryNum, 1)->getIsFromErrorTolerant()) {
        if ($export_format eq "CSV") {
          $string .= $delimiter;
        }
      } else {
        $string .= &formatElement($export_format, "", 0, "pep_expect", 
          sprintf("%.2g", $objSummary->getPeptideExpectationValue($objPeptide->getIonsScore(), $queryNum))) . $delimiter;
      }
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_seq'})) {
    if ($objPeptide->getAnyMatch()) {
      if ($objProtein) {
        my $res = $objProtein->getPeptideResidueBefore($i);
        $res =~ s/@/-/;
        $res =~ s/\?//;
        if ($res) {
          $string .= &formatElement($export_format, "", 0, "pep_res_before", $res) . $delimiter;
        } elsif ($export_format eq "CSV") {
          $string .= $delimiter;
        }
      } elsif ($export_format eq "CSV") {
        $string .= $delimiter;
      }
      $string .= &formatElement($export_format, "", 0, "pep_seq", 
        $objPeptide->getPeptideStr()) . $delimiter;
      if ($objProtein) {
        my $res = $objProtein->getPeptideResidueAfter($i);
        $res =~ s/@/-/;
        $res =~ s/\?//;
        if ($res) {
          $string .= &formatElement($export_format, "", 0, "pep_res_after", $res) . $delimiter;
        } elsif ($export_format eq "CSV") {
          $string .= $delimiter;
        }
      } elsif ($export_format eq "CSV") {
        $string .= $delimiter;
      }
    } elsif ($export_format eq "CSV") {
      $string .= "$delimiter$delimiter$delimiter";
    }
  }
  if ($thisScript->param($urlParams{'pep_frame'})) {
    if ($objProtein && $objProtein->getPeptideFrame($i) > 0) {
      $string .= &formatElement($export_format, "", 0, "pep_frame", $objProtein->getPeptideFrame($i)) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_var_mod'})) {
    if ($objPeptide->getAnyMatch()) {
      $string .= &formatElement($export_format, "", 1, "pep_var_mod", 
        $objSummary->getReadableVarMods($queryNum, $objPeptide->getRank())) . $delimiter;
    # need to re-format string from 00000012000 to 0.000001200.0
    # to prevent Excel from re-formatting it to 12000
      my $temp = $objPeptide->getVarModsStr();
      if ($temp =~ /[1-9A-Za-z]/) {
        $temp =~ s/(.)(.*)(.)/$1\.$2\.$3/;
      } else {
        $temp = "";
      }
      $string .= &formatElement($export_format, "", 0, "pep_var_mod_pos", $temp) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter . $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_num_match'})) {
    if ($objPeptide->getAnyMatch()) {
      $string .= &formatElement($export_format, "", 0, "pep_num_match", 
        $objPeptide->getNumIonsMatched()) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_scan_title'})) {
  # creating query objects is much too slow
    my $title = $objResFile->getQuerySectionValueStr($queryNum, "Title");
    $title =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex($1))/eg;
    $string .= &formatElement($export_format, "", 1, "pep_scan_title", $title) . $delimiter;
  }
  
  return $string;

}

###############################################################################
# &printQuantDetails()
# returns quant fields for a single peptide match
# $_[0] peptide object
# $_[1] query number
# $_[2] peptide number
# $_[3] protein object
# $_[4] hit number
# globals:
# my($objSummary, %urlParams, $objResFile, $massDP, $thisScript, 
# $export_format, $sigThreshold);
###############################################################################

sub printQuantDetails {
  
  my ($objPeptide, 
    $queryNum,
    $i,
    $objProtein,
    $hitNum,
    ) = @_;

  my(@ratioValues, @intensityValues);
  if (&quant_subs::excludeQuantPeptide($objQuantMethod, $objPeptide, $objSummary, $objResFile, 
    $objProtein, $i, $queryNum, $sigThreshold)) {
    for (my $i = 1; $i <= $objQuantMethod->getNumberOfReportRatios(); $i++) {
      $ratioValues[$i] = "---";
    }
  } else {
    # determine the peptide level ratios & push onto @quantDataByHit
    &quant_subs::calc_ratios($objQuantMethod, $objParams, $objResFile, $objPeptide, 
      $queryNum, $hitNum, \@quantDataByQuery, \@quantDataByHit, \@quantCorrFactor);
    for (my $i = 1; $i <= $objQuantMethod->getNumberOfReportRatios(); $i++) {
      if (defined(${ $quantDataByHit[-1] }[$i])) {
        if (${ $quantDataByHit[-1] }[$i] < 1E99) {
          $ratioValues[$i] = sprintf("%.3f", ${ $quantDataByHit[-1] }[$i]);
        } else {
          $ratioValues[$i] = "###";
        }
      } else {
        $ratioValues[$i] = "---";
      }
    }


    for (my $i = 0; $i < $objQuantMethod->getNumberOfComponents(); $i++) {
      if (defined(${ $quantDataByQuery[$queryNum] }[$i])) {
        $intensityValues[$i] = ${ $quantDataByQuery[$queryNum] }[$i];
      } else {
        $intensityValues[$i] = "---";
      }
    }


  }

  my $string = "";
  if ($thisScript->param($urlParams{'pep_quant'})) {
    for (my $i = 1; $i <= $objQuantMethod->getNumberOfReportRatios(); $i++) {
      if ($export_format eq "CSV") {
        $string .= "\"" . &noQuotes($objQuantMethod->getReportRatioByNumber($i - 1)->getName()) . "\"" . $delimiter;
        if ($ratioValues[$i] eq "---" || $ratioValues[$i] eq "###") {
          $string .= "\"" . $ratioValues[$i] . "\"" . $delimiter;
        } else {
          $string .= $ratioValues[$i] . $delimiter;
        }
      } elsif ($export_format eq "XML") {
        $string .= "<quant_pep_ratio name=\""
          . &noXmlTag($objQuantMethod->getReportRatioByNumber($i - 1)->getName())
          . "\" ratio=\""
          . $ratioValues[$i]
          . "\" />" 
          . $delimiter;
      }
    }
    
    for (my $i = 0; $i < $objQuantMethod->getNumberOfComponents(); $i++) {
      if ($export_format eq "CSV") {
        $string .= "\"" . &noQuotes($objQuantMethod->getComponentByNumber($i)->getName()) . "\"" . $delimiter;
        if ($intensityValues[$i] eq "---") {
          $string .= "\"" . $intensityValues[$i] . "\"" . $delimiter;
        } else {
          $string .= $intensityValues[$i] . $delimiter;
        }
      } elsif ($export_format eq "XML") {
        $string .= "<quant_pep_intensity name=\""
          . &noXmlTag($objQuantMethod->getComponentByNumber($i)->getName())
          . "\" intensity=\""
          . $intensityValues[$i]
          . "\" />" 
          . $delimiter;
      }
    }
    
    
  }
  
  return $string;
  
}

###############################################################################
# &outputHeader()
# output header block
# globals:
# my($objParams, $objResFile, $export_format);
###############################################################################

sub outputHeader {
  
  if ($export_format eq "XML") {
    print "<header>\n";
  } elsif ($export_format eq "CSV") {
    print "\n\"Header\"$delimiter\"--------------------------------------------------------\"\n\n";
  }

  print &formatElement($export_format, "Search title", 1, "COM", $objParams->getCOM()) . "\n";
  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime ($objResFile->getDate);
  my $timestamp = sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ", 
    $year+1900, $mon+1, $mday, $hour, $min, $sec);
  print &formatElement($export_format, "Timestamp", 1, "Date", $timestamp) . "\n";
  print &formatElement($export_format, "User", 1, "USERNAME", $objParams->getUSERNAME()) . "\n";
  print &formatElement($export_format, "Email", 1, "USEREMAIL", $objParams->getUSEREMAIL()) . "\n";
  print &formatElement($export_format, "Report URI", 1, "URI", $URI . "cgi/master_results.pl?file=" . $fileIn) . "\n";
  print &formatElement($export_format, "Peak list data path", 1, "FILENAME", $objParams->getFILENAME()) . "\n";
  print &formatElement($export_format, "Peak list format", 1, "FORMAT", $objParams->getFORMAT()) . "\n";
  print &formatElement($export_format, "Search type", 0, "SEARCH", $objParams->getSEARCH()) . "\n";
  print &formatElement($export_format, "Mascot version", 1, "MascotVer", $objResFile->getMascotVer()) . "\n";
  my($dbString, $fastaVerString);
  if ($objParams->getNumberOfDatabases == 1) {
    $dbString = $objParams->getDB(1);
    $fastaVerString = $objResFile->getFastaVer(1);
  } else {
    my(@tempList1, @tempList2);
    for (my $i=1; $i <= $objParams->getNumberOfDatabases; $i++) {
      push @tempList1, $i . "::" . $objParams->getDB($i);
      push @tempList2, $i . "::" . $objResFile->getFastaVer($i);
    }
    $dbString = join(" ", @tempList1);
    $fastaVerString = join(" ", @tempList2);
  }
  print &formatElement($export_format, "Database", 1, "DB", $dbString) . "\n";
  print &formatElement($export_format, "Fasta file", 1, "FastaVer", $fastaVerString) . "\n";
  # wait for parser function ### debug ###
  print &formatElement($export_format, "Total sequences", 0, "NumSeqs", $objResFile->getNumSeqs()) . "\n";
  print &formatElement($export_format, "Total residues", 0, "NumResidues", $objResFile->getNumResidues()) . "\n";
  print &formatElement($export_format, "Sequences after taxonomy filter", 0, "NumSeqsAfterTax", $objResFile->getNumSeqsAfterTax()) . "\n";
  if ($objResFile->isErrorTolerant()) {
    if (my $temp = $objParams->getACCESSION()) {
      my $i = $temp =~ tr/,//;
      $i++;
      print &formatElement($export_format, "Number of entries searched in error tolerant mode", 
        0, "error_tolerant_num", $i) . "\n";
    } else {
      print &formatElement($export_format, "Number of entries searched in error tolerant mode", 
        0, "error_tolerant_num", $objResFile->getNumSeqsAfterTax()) . "\n";
    }
  }
  print &formatElement($export_format, "Number of queries", 0, "NumQueries", $objResFile->getNumQueries()) . "\n";
# Display any warnings from result file header
  my $j = 0;
  if ($objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_HEADER, 'warn0')){
    while ($objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_HEADER, 'warn' . $j)){
      print &formatElement($export_format, "Warning", 1, "warning", 
        $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_HEADER, 'warn' . $j), "number", $j) . "\n";
      $j++;
    }
  }
# Display a warning if this is an orphan error tolerant search
  if ($objResFile->isErrorTolerant() && !$objParams->getErrTolParentFilename()) {
    print &formatElement($export_format, "Warning", 1, "warning", 
      "Scores from standard search not available. Better matches may exist in other proteins.", "number", $j) . "\n";
    $j++;
  }
# Display any warnings from Parser
  for (my $k = 1; $k <= $objResFile->getNumberOfErrors(); $k++) {
    print &formatElement($export_format, "Warning", 1, "warning", 
      $objResFile->getErrorString($k), "number", $j) . "\n";
    $j++;
  }
# Display any warnings from quantitation
  if (@quantWarnings) {
    foreach (@quantWarnings) {
      print &formatElement($export_format, "Warning", 1, "warning", 
        $_, "number", $j) . "\n";
      $j++;
    }
  }

  if ($export_format eq "XML") {
    print "</header>\n";
  } 

}

###############################################################################
# &outputDecoy()
# output decoy database search statistics
# globals:
# my($objParams, $objResFile, $export_format);
###############################################################################

sub outputDecoy {
  
  if ($export_format eq "XML") {
    print "<decoy>\n";
  } elsif ($export_format eq "CSV") {
    print "\n\"Decoy\"$delimiter\"--------------------------------------------------------\"\n\n";
  }

  print &formatElement($export_format, "Number of matches above identity threshold in search of real database", 
    0, "NumHitsAboveIdentity", $objSummary->getNumHitsAboveIdentity(1 / $sigThreshold)) . "\n";
  print &formatElement($export_format, "Number of matches above identity threshold in search of decoy database", 
    0, "NumDecoyHitsAboveIdentity", $objSummary->getNumDecoyHitsAboveIdentity(1 / $sigThreshold)) . "\n";
  if ($objResFile->isPMF()){
    my $TF = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_SUMMARY, "h1");
    $TF = (split(/,/, $TF))[1];
    $TF = sprintf("%.0f", $TF);
    my $TD = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_DECOYSUMMARY, "h1");
    $TD = (split(/,/, $TD))[1];
    $TD = sprintf("%.0f", $TD);
    print &formatElement($export_format, "Highest score in search of real database", 
      0, "HighestScoreProtein", $TF) . "\n";
    print &formatElement($export_format, "Highest score in search of decoy database", 
      0, "HighestScoreDecoyProtein", $TD) . "\n";
  } else {
    print &formatElement($export_format, "Number of matches above homology threshold in search of real database", 
      0, "NumHitsAboveHomology", $objSummary->getNumHitsAboveHomology(1 / $sigThreshold)) . "\n";
    print &formatElement($export_format, "Number of matches above homology threshold in search of decoy database", 
      0, "NumDecoyHitsAboveHomology", $objSummary->getNumDecoyHitsAboveHomology(1 / $sigThreshold)) . "\n";
  }
  
  if ($export_format eq "XML") {
    print "</decoy>\n";
  } 

}

###############################################################################
# &outputFixedMods()
# output fixed modifications block
# globals:
# my($objParams, $objResFile, $export_format);
###############################################################################

sub outputFixedMods {
  
    if ($export_format eq "XML") {
      print "<fixed_mods>\n";
    } elsif ($export_format eq "CSV") {
      print "\n\"Fixed modifications\"$delimiter\"--------------------------------------------------------\"\n\n";
      print "\"Identifier\"$delimiter";
      print "\"Name\"$delimiter";
      print "\"Delta\"$delimiter";
      print "\"Neutral loss\"\n";
    } 

  my $string = "";
  my $i = 1;
  my $letter;

# $objParams->getFixedModsName() will only work with files from 2.1 and later
  if ($objParams->getFixedModsName(1)) {
    while ($objParams->getFixedModsName($i)) {
      $letter = $i;
      if ($i > 9) {
        $letter = chr($i + 55);
      }
      if ($export_format eq "CSV") {
        $string .= $letter . $delimiter;
      } elsif ($export_format eq "XML") {
        $string .= "<modification identifier=\"$letter\">$delimiter";
      }
      $string .= &formatElement($export_format, "", 1, "name", $objParams->getFixedModsName($i)) . $delimiter;
      $string .= &formatElement($export_format, "", 0, "delta", $objParams->getFixedModsDelta($i)) . $delimiter;
      my $loss = $objParams->getFixedModsNeutralLoss($i);
      if ($loss) {
        $string .= &formatElement($export_format, "", 0, "neutral_loss", $loss) . $delimiter;
      }
      chop $string;
      $i++;
      if ($export_format eq "XML") {
        $string .= "$delimiter</modification>";
      }
      $string .= "\n";
    }
  } else {
    my @modList = split(/,/, $objParams->getMODS);
    foreach my $mod (@modList) {
      $letter = $i;
      if ($i > 9) {
        $letter = chr($i + 55);
      }
      if ($export_format eq "CSV") {
        $string .= $letter . $delimiter;
      } elsif ($export_format eq "XML") {
        $string .= "<modification identifier=\"$letter\">$delimiter";
      }
      my @modParams = &getResidueMods($mod, "N");
      unless (@modParams) {
        @modParams = &getTerminalMods($mod, "N");
      }
      $string .= &formatElement($export_format, "", 1, "name", $mod) . $delimiter;
      $string .= &formatElement($export_format, "", 0, "delta", $modParams[1]) . $delimiter;
      chop $string;
      $i++;
      if ($export_format eq "XML") {
        $string .= "$delimiter</modification>";
      }
      $string .= "\n";
    }
  }
  
  chop $string;
  if ($export_format eq "XML") {
    $string =~ s/>$delimiter</>\n</g;
  }
  if ($string) {
    print $string . "\n";
  }

  if ($export_format eq "XML") {
    print "</fixed_mods>\n";
  } 

}

###############################################################################
# &outputVarMods()
# output variable modifications block
# globals:
# my($objParams, $objResFile, $export_format);
###############################################################################

sub outputVarMods {
  
    if ($export_format eq "XML") {
      print "<variable_mods>\n";
    } elsif ($export_format eq "CSV") {
      print "\n\"Variable modifications\"$delimiter\"--------------------------------------------------------\"\n\n";
      print "\"Identifier\"$delimiter";
      print "\"Name\"$delimiter";
      print "\"Delta\"$delimiter";
      print "\"Neutral loss(es)\"\n";
    } 

  my $string = "";
  my $i = 1;
  while ($objParams->getVarModsName($i)) {
    my $letter = $i;
    if ($i > 9) {
      $letter = chr($i + 55);
    }
    if ($export_format eq "CSV") {
      $string .= $letter . $delimiter;
    } elsif ($export_format eq "XML") {
      $string .= "<modification identifier=\"$letter\">$delimiter";
    }
    $string .= &formatElement($export_format, "", 1, "name", $objParams->getVarModsName($i)) . $delimiter;
    $string .= &formatElement($export_format, "", 0, "delta", $objParams->getVarModsDelta($i)) . $delimiter;
    my $losses = $objParams->getVarModsNeutralLosses($i);
    if ($losses
      && !(scalar(@{ $losses }) == 1 && ${ $losses }[0] == 0)) {
      my $j = 1;
      foreach(@{ $losses }) {
        my $letter = $j;
        if ($j > 9) {
          $letter = chr($j + 55);
        }
        $string .= &formatElement($export_format, "", 0, "neutral_loss", $_, "identifier", $letter) . $delimiter;
        $j++;
      }
    }
    chop $string;
    $i++;
    if ($export_format eq "XML") {
      $string .= "$delimiter</modification>";
    }
    $string .= "\n";
  }
  
  chop $string;
  if ($export_format eq "XML") {
    $string =~ s/>$delimiter</>\n</g;
  }
  if ($string) {
    print $string . "\n";
  }

  if ($export_format eq "XML") {
    print "</variable_mods>\n";
  } 

}

###############################################################################
# &outputParams()
# output search parameters block
# globals:
# my($objParams, $objResFile, $export_format);
###############################################################################

sub outputParams {
  
  if ($export_format eq "XML") {
    print "<search_parameters>\n";
  } elsif ($export_format eq "CSV") {
    print "\n\"Search Parameters\"$delimiter\"--------------------------------------------------------\"\n\n";
  }
  
  print &formatElement($export_format, "Taxonomy filter", 1, "TAXONOMY", $objParams->getTAXONOMY()) . "\n";
  print &formatElement($export_format, "Enzyme", 1, "CLE", $objParams->getCLE()) . "\n";
  print &formatElement($export_format, "Maximum Missed Cleavages", 0, "PFA", $objParams->getPFA()) . "\n";
  my $local_mods = $objParams->getMODS();
  if ($objQuantMethod) {
  # add in any fixed mods specified in the quant method
    my $qMods = &quant_subs::getQuantFixedModsAsString($objQuantMethod);
    if ($qMods && $local_mods) {
      $local_mods .= "," . $qMods;
    } elsif ($qMods) {
      $local_mods = $qMods;
    }
  }
  print &formatElement($export_format, "Fixed modifications", 1, "MODS", $local_mods) . "\n";
  if ($objParams->getQUANTITATION()) {
    print &formatElement($export_format, "Quantitation method", 1, "QUANTITATION", $objParams->getQUANTITATION()) . "\n";
  } elsif ($objParams->getICAT()) {
    print &formatElement($export_format, "ICAT experiment", 0, "ICAT", $objParams->getICAT()) . "\n";
  }
  my $local_it_mods = $objParams->getIT_MODS();
  if ($objParams->getICAT()){
    my $ICATLight = $objMascotOptions->getICATLight;
    $ICATLight = "ICAT_light" unless $ICATLight;
    my $ICATHeavy = $objMascotOptions->getICATHeavy;
    $ICATHeavy = "ICAT_heavy" unless $ICATHeavy;
    my @tempMods = split(/,/, $local_it_mods);
    for (my $i = $#tempMods; $i >= 0; $i--) {
      if (($tempMods[$i] eq $ICATLight) || ($tempMods[$i] eq $ICATHeavy)) {
        splice @tempMods, $i, 1;
      }
    }
    if (@tempMods) {
      $local_it_mods = join(',', @tempMods);
    } else {
      $local_it_mods = "";
    }
  }
  print &formatElement($export_format, "Variable modifications", 1, "IT_MODS", $local_it_mods) . "\n";
  print &formatElement($export_format, "Peptide Mass Tolerance", 0, "TOL", $objParams->getTOL()) . "\n";
  print &formatElement($export_format, "Peptide Mass Tolerance Units", 0, "TOLU", $objParams->getTOLU()) . "\n";
  if ($objResFile->isPMF()){
    print &formatElement($export_format, "Peptide Charge State", 0, "CHARGE", $objParams->getCHARGE()) . "\n";
  } else {
    print &formatElement($export_format, "Fragment Mass Tolerance", 0, "ITOL", $objParams->getITOL()) . "\n";
    print &formatElement($export_format, "Fragment Mass Tolerance Units", 0, "ITOLU", $objParams->getITOLU()) . "\n";
  }
  print &formatElement($export_format, "Mass values", 0, "MASS", $objParams->getMASS()) . "\n";
  if ($objParams->getSEG() > 0){
    print &formatElement($export_format, "Protein Mass", 0, "SEG", $objParams->getSEG()) . "\n";
  }
  if (!$objResFile->isPMF() && $objParams->getINSTRUMENT()) {
    print &formatElement($export_format, "Instrument type", 1, "INSTRUMENT", $objParams->getINSTRUMENT()) . "\n";
  }
  if ($objParams->getPEP_ISOTOPE_ERROR() > -1) {
    print &formatElement($export_format, "Isotope error mode", 0, "PEP_ISOTOPE_ERROR", $objParams->getPEP_ISOTOPE_ERROR()) . "\n";
  }
  if ($objParams->getDECOY() > -1) {
    print &formatElement($export_format, "Decoy database also searched", 0, "DECOY", $objParams->getDECOY()) . "\n";
  }

# Print out any user parameters with defined values (USER00 to USER12 and anything beginning with underscore) 
  my $i = 1;
  while (my $nextKey = $objResFile->enumerateSectionKeys($msparser::ms_mascotresfile::SEC_PARAMETERS, $i)) {
    if ($nextKey =~ /^(_.*)/i || $nextKey =~ /^(user\d\d)$/i) {
      my $parameter_name = $1;
      my $nextValue = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_PARAMETERS, $nextKey);
      $nextKey =~ s/\s*$//;
      if ($nextValue) {
        print &formatElement($export_format, $nextKey, 1, "user_parameter", $nextValue, "name", $parameter_name) . "\n";
      }
    }
    $i++;
  }

  if ($export_format eq "XML") {
    print "</search_parameters>\n";
  } 

}

###############################################################################
# &outputFormat()
# output format block
# globals:
# my($objResFile, $export_format, %urlParams, $thisScript, $sigThreshold,
# $numHits, $ignoreIonsScoreBelow, $RequireBoldRed, $mudpitSwitch, $ShowSubSets);
###############################################################################

sub outputFormat {
  
  if ($export_format eq "XML") {
    print "<format_parameters>\n";
  } elsif ($export_format eq "CSV") {
    print "\n\"Format parameters\"$delimiter\"--------------------------------------------------------\"\n\n";
  }
  
  print &formatElement($export_format, "Significance threshold", 0, "sigthreshold", $sigThreshold) . "\n";
  print &formatElement($export_format, "Max. number of hits", 0, "REPORT", $numHits) . "\n";
  if ($anyPepSumMatch) {
    if ($objResFile->getNumQueries() / $objResFile->getNumSeqsAfterTax() > $mudpitSwitch){
      print &formatElement($export_format, "Use MudPIT protein scoring", 0, "mudpit", 1) . "\n";
    } else {
      print &formatElement($export_format, "Use MudPIT protein scoring", 0, "mudpit", 0) . "\n";
    }
    print &formatElement($export_format, "Ions score cut-off", 0, "ignoreionsscorebelow", $ignoreIonsScoreBelow) . "\n";
  }
  print &formatElement($export_format, "Include same-set proteins", 
    0, "show_same_sets", $thisScript->param($urlParams{'show_same_sets'}) + 0) . "\n";
  print &formatElement($export_format, "Include sub-set proteins", 
    0, "showsubsets", $ShowSubSets) . "\n";
  if ($anyPepSumMatch) {
    print &formatElement($export_format, "Include unassigned", 
      0, "show_unassigned", $thisScript->param($urlParams{'show_unassigned'}) + 0) . "\n";
    print &formatElement($export_format, "Require bold red", 0, "requireboldred", $RequireBoldRed) . "\n";
    if ($thisScript->param($urlParams{'unigene'})) {
      print &formatElement($export_format, "UniGene index", 1, "UNIGENE", $thisScript->param($urlParams{'unigene'}) + 0) . "\n";
    }
  }

  if ($export_format eq "XML") {
    print "</format_parameters>\n";
  } 

}

###############################################################################
# &outputMasses()
# output masses block
# globals:
# my($objResFile, $export_format);
###############################################################################

sub outputMasses {
  
  if ($export_format eq "XML") {
    print "<masses>\n";
  } elsif ($export_format eq "CSV") {
    print "\n\"Mass values\"$delimiter\"--------------------------------------------------------\"\n\n";
  }
  
  my $i = 1;
  while (my $nextKey = $objResFile->enumerateSectionKeys($msparser::ms_mascotresfile::SEC_MASSES, $i)) {
    if ($nextKey =~ /^delta/i
      || $nextKey =~ /^ignore/i
      || $nextKey =~ /^neutralloss/i
      || $nextKey =~ /^fixedmod/i
      || $nextKey =~ /^reqpep/i
      || $nextKey =~ /^pepneutral/i) {
      $i++;
      next;
    }
    print &formatElement($export_format, $nextKey, 0, "mass", 
      $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_MASSES, $nextKey), "name", $nextKey) . "\n";
    $i++;
  }

  if ($export_format eq "XML") {
    print "</masses>\n";
  } 

}

###############################################################################
# &outputQueries()
# output queries block
# globals:
# my($objResFile, $export_format, %urlParams, $thisScript, $sigThreshold,
# $numHits, $ignoreIonsScoreBelow, $RequireBoldRed, $mudpitSwitch, $ShowSubSets);
###############################################################################

sub outputQueries {
  
  if ($export_format eq "XML") {
    print "<queries>\n";
  } elsif ($export_format eq "CSV") {
    print "\n\"Queries\"$delimiter\"--------------------------------------------------------\"\n\n";
    print "\"query_number\"";
    print "$delimiter\"moverz\"";
    print "$delimiter\"charge\"";
    print "$delimiter\"intensity\"";
    if ($thisScript->param($urlParams{'query_title'})) {
      print "$delimiter\"StringTitle\"";
      print "$delimiter\"Scan number range\"";
      print "$delimiter\"Retention time range\"";
    }
    if ($thisScript->param($urlParams{'query_qualifiers'})) {
      print "$delimiter\"qualifiers\"";
    }
    if ($thisScript->param($urlParams{'query_params'})) {
      print "$delimiter\"Peptide Mass Tolerance\"";
      print "$delimiter\"Peptide Mass Tolerance Units\"";
      print "$delimiter\"Variable modifications\"";
      print "$delimiter\"Instrument type\"";
    }
    if ($thisScript->param($urlParams{'query_peaks'})) {
      print "$delimiter\"TotalIonsIntensity\"";
      print "$delimiter\"NumVals\"";
      print "$delimiter\"StringIons1\"";
      print "$delimiter\"StringIons2\"";
      print "$delimiter\"StringIons3\"";
    }
    if ($thisScript->param($urlParams{'query_raw'})) {
      foreach my $field (@columns) {
        if ($field !~ /^pep/) {
          next;
        }
        if ($thisScript->param($urlParams{lc($field)})) {
          if ($field eq "pep_seq") {
            print $delimiter . "pep_res_before" . $delimiter . $field . $delimiter . "pep_res_after";
          } elsif ($field eq "pep_var_mod") {
            print $delimiter . $field . $delimiter . "pep_var_mod_pos";
          } elsif ($field eq "pep_query") {
            next;
          } else {
            print $delimiter . $field;
          }
        }
      }
    }
    print "\n";
  }
  
  for (my $queryNum = 1; $queryNum <= $objResFile->getNumQueries; $queryNum++) {
    my $string = "";
    $queryColumnCount = 0;
    my $objQuery = new msparser::ms_inputquery($objResFile, $queryNum);
    if ($export_format eq "CSV") {
      $string .= $queryNum . $delimiter;
    } elsif ($export_format eq "XML") {
      $string .= "<query number=\"$queryNum\">$delimiter";
    }
    $queryColumnCount++;
    
    $string .= &formatElement($export_format, "", 0, "query_moverz", $objResFile->getObservedMass($queryNum) + 0) . $delimiter;
    $string .= &formatElement($export_format, "", 1, "query_charge", $objQuery->getCharge()) . $delimiter;
    my $intensity = $objResFile->getObservedIntensity($queryNum) + 0;
    if ($intensity != 0) {
      $string .= &formatElement($export_format, "", 0, "query_intensity", $intensity) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
    $queryColumnCount += 3;

  # query_title
    if ($thisScript->param($urlParams{'query_title'})) {
      if ($objQuery->getStringTitle(1)) {
        $string .= &formatElement($export_format, "", 1, "StringTitle", 
          $objQuery->getStringTitle(1)) . $delimiter;
      } elsif ($export_format eq "CSV") {
        $string .= $delimiter;
      }
      $queryColumnCount++;
      if ($objResFile->getQuerySectionValueStr($queryNum, "SCANS")) {
        $string .= &formatElement($export_format, "", 1, "SCANS", $objResFile->getQuerySectionValueStr($queryNum, "SCANS")) . $delimiter;
      } elsif ($export_format eq "CSV") {
        $string .= $delimiter;
      }
      $queryColumnCount++;
      if ($objResFile->getQuerySectionValueStr($queryNum, "RTINSECONDS")) {
        $string .= &formatElement($export_format, "", 1, "RTINSECONDS", $objResFile->getQuerySectionValueStr($queryNum, "RTINSECONDS")) . $delimiter;
      } elsif ($export_format eq "CSV") {
        $string .= $delimiter;
      }
      $queryColumnCount++;
    }
    
  # query_qualifiers
    if ($thisScript->param($urlParams{'query_qualifiers'})) {
      my @qualifiers;
      if ($objQuery->getPepTolString()) {                                  
        if ($export_format eq "XML") {
          push @qualifiers, &formatElement($export_format, "", 1, "qual_tol", $objQuery->getPepTolString());
        } else {
          push @qualifiers, $objQuery->getPepTolString();
        }
      }
      for (my $j = 1; $j <= 20; $j++) {
        if ($objQuery->getSeq($j)) {
          if ($export_format eq "XML") {
            push @qualifiers, &formatElement($export_format, "", 1, "qual_seq", "seq(" . $objQuery->getSeq($j) . ")", "number", $j);
          } else {
            push @qualifiers, "seq(" . $objQuery->getSeq($j) . ")";
          }
        } else {
          last;
        }
      }
      for (my $j = 1; $j <= 20; $j++) {
        if ($objQuery->getComp($j)) {
          if ($export_format eq "XML") {
            push @qualifiers, &formatElement($export_format, "", 1, "qual_comp", "comp(" . $objQuery->getComp($j) . ")", "number", $j);
          } else {
            push @qualifiers, "comp(" . $objQuery->getComp($j) . ")";
          }
        } else {
          last;
        }
      }
      for (my $j = 1; $j <= 20; $j++) {
        if (my $local_tag_string = $objQuery->getTag($j)) {
          $local_tag_string =~ /([et]),(.*)/i;
          if ($1 eq "e") {
            $local_tag_string = "etag($2)";
          } else {
            $local_tag_string = "tag($2)";
          }
          if ($export_format eq "XML") {
            push @qualifiers, &formatElement($export_format, "", 1, "qual_tag", $local_tag_string, "number", $j);
          } else {
            push @qualifiers, $local_tag_string;
          }
        } else {
          last;
        }
      }
      if ($export_format eq "XML") {
        if (@qualifiers) {
          $string .= join($delimiter, @qualifiers) . $delimiter;
        }
      } else {
        $string .= &formatElement($export_format, "", 1, "pep_qual", join(" ", @qualifiers)) . $delimiter;
      }
      $queryColumnCount++;
    }

  # query_params
    if ($thisScript->param($urlParams{'query_params'})) {
      if ($objQuery->getPepTol() > 0) {
        $string .= &formatElement($export_format, "", 0, "query_TOL", $objQuery->getPepTol()) . $delimiter;
        $string .= &formatElement($export_format, "", 0, "query_TOLU", $objQuery->getPepTolUnits()) . $delimiter;
      } elsif ($export_format eq "CSV") {
        $string .= $delimiter . $delimiter;
      }
      $queryColumnCount++;
      $queryColumnCount++;
      if ($objQuery->getIT_MODS(1)) {
        $string .= &formatElement($export_format, "", 1, "query_IT_MODS", $objQuery->getIT_MODS(1)) . $delimiter;
      } elsif ($export_format eq "CSV") {
        $string .= $delimiter;
      }
      $queryColumnCount++;
      if ($objQuery->getINSTRUMENT(1)) {
        $string .= &formatElement($export_format, "", 1, "query_INSTRUMENT", $objQuery->getINSTRUMENT(1)) . $delimiter;
      } elsif ($export_format eq "CSV") {
        $string .= $delimiter;
      }
      $queryColumnCount++;
    }

  # query_peaks
    if ($thisScript->param($urlParams{'query_peaks'})) {
      $string .= &formatElement($export_format, "", 0, "TotalIonsIntensity", $objQuery->getTotalIonsIntensity() + 0) . $delimiter;
      $string .= &formatElement($export_format, "", 0, "NumVals", $objQuery->getNumVals() + 0) . $delimiter;
      $string .= &formatElement($export_format, "", 1, "StringIons1", $objQuery->getStringIons1()) . $delimiter;
      $string .= &formatElement($export_format, "", 1, "StringIons2", $objQuery->getStringIons2()) . $delimiter;
      $string .= &formatElement($export_format, "", 1, "StringIons3", $objQuery->getStringIons3()) . $delimiter;
      $queryColumnCount += 5;
    }
    
  # query_raw
    if ($thisScript->param($urlParams{'query_raw'})) {
      my $needSpacer = 0;
      for (my $rank = 1; $rank <= $objSummary->getMaxRankValue; $rank++) {
        my $objPeptide = $objSummary->getPeptide($queryNum, $rank);
        if (defined($objPeptide)) {
          if ($objPeptide->getAnyMatch()) {
            if ($export_format eq "CSV" && $needSpacer) {
              $string .= $queryNum . $delimiter x $queryColumnCount;
            } else {
              $needSpacer = 1;
            }
            if ($export_format eq "XML") {
              $string .= "<q_peptide query=\"$queryNum\"";
              if ($objPeptide->getAnyMatch() && !$objResFile->isPMF()) {
                $string .= " rank=\"" . $objPeptide->getPrettyRank() . "\"";
              }
              $string .= ">\n";
            }
            $string .= &printPeptideDetails($objPeptide, $queryNum, $rank, "", 0) . "\n";
            if ($export_format eq "XML") {
              chop $string;
              $string .= "</q_peptide>\n";
            } 
          }
        }
      }
    }

    chop $string;
    if ($export_format eq "XML") {
      $string .= "$delimiter</query>";
      $string =~ s/>$delimiter</>\n</g;
    }
    if ($string) {
      print $string . "\n";
    }

  }
  
  if ($export_format eq "XML") {
    print "</queries>\n";
  } 

}

###############################################################################
# &formatElement()
# returns formatted element
#
# $_[0] "XML" or "CSV" or ...
# $_[1] CSV label, empty if none required
# $_[2] 1 if text element could contain delimiter or illegal character
# $_[3] xml element name
# $_[4] element value
# $_[5] attribute name for XML, empty if none
# $_[6] attribute value for XML, empty if none
###############################################################################

sub formatElement {
  
  my($format, $label, $need_quotes, $name, $value, $attrib_name, $attrib_value) = @_;
  
  my $return = "";
  
  if ($format eq "XML") {
    $return .= "<$name";
    if ($attrib_name) {
      $return .= " $attrib_name=\"" . &noXmlTag($attrib_value) . "\"";
    }
    if ($value eq "") {
      $return .= "/>";
    } else {
      if ($need_quotes) {
        $return .= ">" . &noXmlTag($value) . "</$name>";
      } else {
        $return .= ">$value</$name>";
      }
    }
  } elsif ($format eq "CSV") {
    if ($label) {
      $return .= "$label$delimiter";
    }
    if ($need_quotes) {
      $return .= "\"" . &noQuotes($value) . "\"";
    } else {
      $return .= $value;
    }
  }
  
  return $return;

}

###############################################################################
# &noXmlTag()
# returns de-tagged string
# $_[0] string which may contain XML illegal characters
###############################################################################

sub noXmlTag {

  my $temp = shift;

  $temp =~ s/&/&amp;/g;
  $temp =~ s/</&lt;/g;
  $temp =~ s/>/&gt;/g;
  $temp =~ s/\"/&quot;/g;
  $temp =~ s/\'/&apos;/g;

  return $temp;

}

###############################################################################
# &noQuotes()
# returns string with quotes removed
# $_[0] string which may contain quotes
###############################################################################

sub noQuotes {

  my $temp = shift;

  $temp =~ s/[\"\']/~/g;

  return $temp;

}

###############################################################################
# &getResidueMods()
# returns aminoacid_modification elements
# $_[0] Mascot modification name
# $_[1] "N" or "Y" for variable mods
###############################################################################

sub getResidueMods {
  
  my ($modName, $variable) = @_;

  my @retVal;
  my $treatasvariable = $variable;
  my $terminalMod = "";
  my $objMod = $objModFile->getModificationByName($modName);
  if ($objMod) {
    if ($objMod->getModificationType() == $msparser::MOD_TYPE_RESIDUE
      || $objMod->getModificationType() == $msparser::MOD_TYPE_N_TERM_RESIDUE
      || $objMod->getModificationType() == $msparser::MOD_TYPE_C_TERM_RESIDUE) {
      if ($objMod->getModificationType() == $msparser::MOD_TYPE_N_TERM_RESIDUE) {
        $terminalMod = "n";
        $treatasvariable = "Y";
      }
      if ($objMod->getModificationType() == $msparser::MOD_TYPE_C_TERM_RESIDUE) {
        $terminalMod = "c";
        $treatasvariable = "Y";
      }
      for (my $i = 0; $i < $objMod->getNumberOfModifiedResidues(); $i++) {
        push @retVal, $objMod->getModifiedResidue($i);
        push @retVal, sprintf("%+." . $massDP . "f", $objMod->getDelta($mass_type));
        if ($terminalMod) {
          push @retVal, ($objMassesFile->getResidueMass($mass_type, $objMod->getModifiedResidue($i))
            + $objMod->getDelta($mass_type));
        } else {
          push @retVal, $objMod->getResidueMass($mass_type, $objMod->getModifiedResidue($i));
        }
        push @retVal, $treatasvariable;
        push @retVal, $terminalMod;
        push @retVal, $modName;
      # print "<!--\n";
      # print $objMod->getResidueMass($mass_type, $objMod->getModifiedResidue($i)) . "\n";
      # print $objMod->getDelta($mass_type) . "\n";
      # print $objMod->isResidueModified($objMod->getModifiedResidue($i)) . "\n";
      # print $objMod->getCTerminusMass($mass_type) . "\n";
      # print $objMassesFile->getResidueMass($mass_type, $objMod->getModifiedResidue($i)) . "\n";
      # print $objMassesFile->isResidueModified($objMod->getModifiedResidue($i)) . "\n";
      # print $objMassesFile->getCtermDelta($mass_type) . "\n";
      # print $objMassesFile->getCterminalMass($mass_type) . "\n";
      # print "-->\n";
      }
    }
  } else {
  # mod not found in file, extract values from result file
    unless ($modName =~ /\(c-term\)/i
      || $modName =~ /\(n-term\)/i
      || $modName =~ /\(protein\)/i) {
      (my $specificity) = $modName =~ /\((.*)\)/;
    # special cases
      if ($specificity =~ /([cn])-term (.+)/i) {
        $terminalMod = lc($1);
        $specificity = $2;
        $treatasvariable = "Y";
      }
      if ($specificity eq "") {
      # must be ICAT_light or ICAT_heavy
        $specificity = "C";
      } elsif ($specificity eq "camC") {
      # Pyro-cmC
        $specificity = "C";
      }
      my @spec_list = split(//, $specificity);
      foreach my $this_spec (@spec_list) {
        my ($mass_diff, $mass_total);
        if ($treatasvariable eq "Y") {
          while (my($key, $value) = each %vmString) {
            if ($value eq $modName) {
              $mass_diff = $vmMass{$key};
              $mass_total = $mass_diff + $masses{lc($this_spec)};
            }
          }
        } else {
          $mass_total = $masses{lc($this_spec)};
          $mass_diff = $mass_total - $objMassesFile->getResidueMass($mass_type, $this_spec);
        }
        push @retVal, $this_spec;
        push @retVal, sprintf("%+." . $massDP . "f", $mass_diff);
        push @retVal, $mass_total;
        push @retVal, $treatasvariable;
        push @retVal, $terminalMod;
        push @retVal, $modName;
      }
    }
  }
  return @retVal;

}

###############################################################################
# &getTerminalMods()
# returns terminal_modification elements
# $_[0] Mascot modification name
# $_[1] "N" or "Y" for variable mods
###############################################################################

sub getTerminalMods {
  
  my ($modName, $variable) = @_;

  my @retVal;
  my $treatasvariable = $variable;
  my $protein_terminus = "";
  my $objMod = $objModFile->getModificationByName($modName);
  if ($objMod) {
    if ($objMod->getModificationType() == $msparser::MOD_TYPE_N_TERM
      || $objMod->getModificationType() == $msparser::MOD_TYPE_C_TERM
      || $objMod->getModificationType() == $msparser::MOD_TYPE_N_PROTEIN
      || $objMod->getModificationType() == $msparser::MOD_TYPE_C_PROTEIN) {
      if ($objMod->getModificationType() == $msparser::MOD_TYPE_N_PROTEIN) {
        $treatasvariable = "Y";
        $protein_terminus = "n";
      }
      if ($objMod->getModificationType() == $msparser::MOD_TYPE_C_PROTEIN) {
        $treatasvariable = "Y";
        $protein_terminus = "c";
      }
      my $term_end = "n";
      my $term_mass = $objMassesFile->getNterminalMass($msparser::MASS_TYPE_MONO);
      if ($objMod->getModificationType() == $msparser::MOD_TYPE_C_TERM 
        || $objMod->getModificationType() == $msparser::MOD_TYPE_C_PROTEIN) {
        $term_end = "c";
        $term_mass = $objMassesFile->getCterminalMass($mass_type);
      }
      push @retVal, $term_end;
      push @retVal, sprintf("%+." . $massDP . "f", $objMod->getDelta($mass_type));
      push @retVal, ($term_mass + $objMod->getDelta($mass_type));
      push @retVal, $treatasvariable;
      push @retVal, $protein_terminus;
      push @retVal, $modName;
    }
  } else {
  # mod not found in file, try to guess values
    if ($modName =~ /\(c-term\)/i
      || $modName =~ /\(n-term\)/i
      || $modName =~ /\(protein\)/i) {
      (my $specificity) = $modName =~ /\((.*)\)/;
      my ($this_spec, $term_end);
    # special cases
      if ($specificity =~ /protein/i) {
        $treatasvariable = "Y";
        $this_spec = "N_term";   # assumption
        $term_end = "n";         # assumption
        $protein_terminus = "n"; # assumption
      } elsif ($specificity =~ /c-term/i) {
        $this_spec = "C_term";
        $term_end = "c";
      } elsif ($specificity =~ /n-term/i) {
        $this_spec = "N_term";
        $term_end = "n";
      }
      my ($mass_diff, $mass_total);
      if ($treatasvariable eq "Y") {
        while (my($key, $value) = each %vmString) {
          if ($value eq $modName) {
            $mass_diff = $vmMass{$key};
            $mass_total = $mass_diff + $masses{lc($this_spec)};
          }
        }
      } else {
        $mass_total = $masses{lc($this_spec)};
        if ($this_spec eq "C_term") {
          $mass_diff = $mass_total - $objMassesFile->getCterminalMass($mass_type);
        } else {
          $mass_diff = $mass_total - $objMassesFile->getNterminalMass($mass_type);
        }
      }
      push @retVal, $term_end;
      push @retVal, sprintf("%+." . $massDP . "f", $mass_diff);
      push @retVal, $mass_total;
      push @retVal, $treatasvariable;
      push @retVal, $protein_terminus;
      push @retVal, $modName;
    }
  }
  return @retVal;

}

###############################################################################
# &pepXML()
# output ISB pepXML elements
# my($objParams);
###############################################################################

sub pepXML {  

# msms_run_summary
  print "<msms_run_summary";
  print " base_name=\"\"";
  print " raw_data_type=\"\"";
  print " raw_data=\"\"";
  # optional msManufacturer
  # optional msModel
  # optional msIonization
  # optional msMassAnalyzer
  # optional msDetector
  print ">\n";

# sample_enzyme
  print "<sample_enzyme";
  print " name=\"" . &noXmlTag($objParams->getCLE()) . "\"";
  print " description=\"\"";
  my @enzymeDetails = &getEnzymeDef($objParams->getCLE());
  if ($enzymeDetails[2]) {
    print " fidelity=\"semispecific\"";
  } elsif ($objParams->getCLE() eq "None") {
    print " fidelity=\"nonspecific\"";
  } else {
    print " fidelity=\"specific\"";
  }
  print " independent=\"" . $enzymeDetails[1] . "\"";
  if ($objParams->getCLE() eq "None") {
    print "/>\n";
  } else {
  # specificities
    print ">\n";
    for (my $specificity = 0; $specificity < $enzymeDetails[0]; $specificity++) {
      print "<specificity";
      print " sense=\"" . $enzymeDetails[$specificity * 3 + 5] . "\"";
      print " min_spacing=\"1\"";
      print " cut=\"" . $enzymeDetails[$specificity * 3 + 3] . "\"";
      print " no_cut=\"" . $enzymeDetails[$specificity * 3 + 4] . "\"";
      print "/>\n";
    }
    print "</sample_enzyme>\n";
  }

# search_summary
  print "<search_summary";
  print " base_name=\"" . $URI . "cgi/master_results.pl?file=" . $fileIn . "\"";
  print " search_engine=\"MASCOT\"";
  print " precursor_mass_type=\"" . lc($objParams->getMASS()) . "\"";
  print " fragment_mass_type=\"" . lc($objParams->getMASS()) . "\"";
  print " out_data_type=\"\"";
  print " out_data=\"\"";
  print " search_id=\"1\">\n";
 
# search_database
# NB pepXML does not support multiple databases, so just provide details for first
# and list any others in search_summary/parameter elements
  print "<search_database";
  my $databasePath = &noXmlTag($objResFile->getFastaPath(1));
  print " local_path=\"$databasePath\"";
  # optional URL
  print " database_name=\"" . &noXmlTag($objParams->getDB(1)) . "\"";
  # optional orig_database_url
  # optional database_release_date
  print " database_release_identifier=\"" . &noXmlTag($objResFile->getFastaVer(1)) . "\"";
  # wait for parser function ### debug ###
  print " size_in_db_entries=\"" . $objResFile->getNumSeqs . "\"";
  print " size_of_residues=\"" . $objResFile->getNumResidues . "\"";
  if ($objSummary->isNA) {
    print " type=\"NA\"";
  } else {
    print " type=\"AA\"";
  }
  print "/>\n";

# enzymatic_search_constraint
  print "<enzymatic_search_constraint";
  print " enzyme=\"" . &noXmlTag($objParams->getCLE()) . "\"";
  print " max_num_internal_cleavages=\"" . $objParams->getPFA() . "\"";
  my $min_number_termini = 2;
  if ($enzymeDetails[2]) {
    $min_number_termini = 1;
  } elsif ($objParams->getCLE() eq "None") {
    $min_number_termini = 0;
  }
  print " min_number_termini=\"$min_number_termini\"/>\n";

# sequence_search_constraint
# output at query level

# aminoacid_modifications
# fixed
  my(@res_mods, @term_mods, $iCount);
  if ($objParams->getFixedModsName(1)) {
    $iCount = 1;  
    while ($objParams->getFixedModsName($iCount)) {
      push @res_mods, &getResidueMods($objParams->getFixedModsName($iCount), "N");
      $iCount++;
    }
  } else {
    my $mod_string = $objParams->getMODS();
    if ($mod_string) {
      my @mod_list = split(/,/, $mod_string);
      foreach my $modName (@mod_list) {
        push @res_mods, &getResidueMods($modName, "N");
      }
    }
  }
# variable
  $iCount = 1;  
  while ($objParams->getVarModsName($iCount)) {
    push @res_mods, &getResidueMods($objParams->getVarModsName($iCount), "Y");
    $iCount++;
  }

  while (@res_mods) {
    print "<aminoacid_modification";
    print " aminoacid=\"" . shift(@res_mods) . "\"";
    print " massdiff=\"" . shift(@res_mods) . "\"";
    print " mass=\"" . shift(@res_mods) . "\"";
    print " variable=\"" . shift(@res_mods) . "\"";
    my $terminalMod = shift(@res_mods);
    if ($terminalMod) {
      print " peptide_terminus=\"$terminalMod\"";
    }
    # optional symbol
    print " binary=\"N\"";
    print " description=\"" . &noXmlTag(shift(@res_mods)) . "\"/>\n";
  }
  
# terminal_modifications
# fixed
  if ($objParams->getFixedModsName(1)) {
    $iCount = 1;  
    while ($objParams->getFixedModsName($iCount)) {
      push @term_mods, &getTerminalMods($objParams->getFixedModsName($iCount), "N");
      $iCount++;
    }
  } else {
    my $mod_string = $objParams->getMODS();
    if ($mod_string) {
      my @mod_list = split(/,/, $mod_string);
      foreach my $modName (@mod_list) {
        push @term_mods, &getTerminalMods($modName, "N");
      }
    }
  }
# variable
  $iCount = 1;  
  while ($objParams->getVarModsName($iCount)) {
    push @term_mods, &getTerminalMods($objParams->getVarModsName($iCount), "Y");
    $iCount++;
  }

  while (@term_mods) { 
    print "<terminal_modification";
    print " terminus=\"" . shift(@term_mods) . "\"";
    print " massdiff=\"" . shift(@term_mods) . "\"";
    print " mass=\"" . shift(@term_mods) . "\"";
    print " variable=\"" . shift(@term_mods) . "\"";
    # optional symbol
    print " protein_terminus=\"" . shift(@term_mods) . "\"";
    print " description=\"" . &noXmlTag(shift(@term_mods)) . "\"/>\n";
  }   

# parameter
  if($objParams->getNumberOfDatabases > 1) {
    for (my $i=2; $i <= $objParams->getNumberOfDatabases; $i++) {
      print "<parameter name=\"local_path_$i\" value=\"" . &noXmlTag($objResFile->getFastaPath($i)) . "\"/>\n";
      print "<parameter name=\"database_name_$i\" value=\"" . &noXmlTag($objParams->getDB($i)) . "\"/>\n";
      print "<parameter name=\"database_release_identifier_$i\" value=\"" . &noXmlTag($objResFile->getFastaVer($i)) . "\"/>\n";
      # wait for parser function ### debug ###
      print "<parameter name=\"size_in_db_entries_$i\" value=\"" . $objResFile->getNumSeqs . "\"/>\n";
      print "<parameter name=\"size_of_residues_$i\" value=\"" . $objResFile->getNumResidues . "\"/>\n";
    }
  }
  my $index = 1;
  while (my $nextKey = $objResFile->enumerateSectionKeys($msparser::ms_mascotresfile::SEC_PARAMETERS, $index)) {
    my $nextValue = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_PARAMETERS, $nextKey);
    $nextKey =~ s/\s*$//;
    if ($nextValue) {
      print "<parameter name=\"" . &noXmlTag($nextKey) . "\" value=\"" . &noXmlTag($nextValue) . "\"/>\n";
    }
    $index++;
  }

# end of search_summary
  print "</search_summary>\n";
  
# loop through all matched queries
  my $string = "";
  my $needClosingTag;
  for (my $queryNum = 1; $queryNum <= $objResFile->getNumQueries; $queryNum++) {
    $needClosingTag = 0;
    for (my $rank = 1; $rank <= $objSummary->getMaxRankValue; $rank++) {
      my $objPeptide = $objSummary->getPeptide($queryNum, $rank);
      if (defined($objPeptide)) {
        my $objQuery = new msparser::ms_inputquery($objResFile, $queryNum);
        if ($objPeptide->getAnyMatch()) {
          my $srcRank = $objSummary->getSrcRank($queryNum, $rank);
          my $tempString = $objResFile->getSectionValueStr($objSummary->getSrcSection($queryNum, $rank), "q$queryNum\_p$srcRank");
          my($left, $right) = split(/;/, $tempString, 2);
          my @protein_list = $right =~ /"(.+?)"/g;
          $tempString = $objResFile->getSectionValueStr($objSummary->getSrcSection($queryNum, $rank), "q$queryNum\_p$srcRank\_db");
          my @db_list;
          if ($tempString) {
            @db_list = $tempString =~ /(\d\d)/g;
          } else {
            for (my $i = 0; $i <= $#protein_list; $i++) {
              $db_list[$i] = "01";
            }
          }
          $tempString = $objResFile->getSectionValueStr($objSummary->getSrcSection($queryNum, $rank), "q$queryNum\_p$srcRank\_terms");
          my($peptide_prev_aa, $peptide_next_aa) = $tempString =~ /^(.),(.)/;
          if ($rank == 1) {
          # spectrum_query
            $needClosingTag = 1;
            print "<spectrum_query";
            print " spectrum=\"" . &noXmlTag($objQuery->getStringTitle(1)) . "\"";
            print " start_scan=\"0\"";
            print " end_scan=\"0\"";
            print " precursor_neutral_mass=\"" . $objPeptide->getMrExperimental . "\"";
            print " assumed_charge=\"" . $objResFile->getObservedCharge($queryNum) . "\"";
            my $repeatSearchString = $objResFile->getRepeatSearchString($queryNum);
            $repeatSearchString =~ s/^[0-9.]+\s*//;
            $repeatSearchString =~ s/from\(.+?\)\s*//;
            $repeatSearchString =~ s/title\(.+?\)\s*//;
            $repeatSearchString =~ s/query\(.+?\)\s*//;
            $repeatSearchString =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex($1))/eg;
            $repeatSearchString =~ s/^\s*//;
            $repeatSearchString =~ s/\s*$//;
            if ($repeatSearchString) {
              print " search_specification=\"" . &noXmlTag($repeatSearchString) . "\"";
            }
            print " index=\"$queryNum\">\n";
          # search_result
            print "<search_result";
            print " search_id=\"1\">\n";
          }
          
        # search_hit
          print "<search_hit";
          print " hit_rank=\"$rank\"";
          print " peptide=\"" . $objPeptide->getPeptideStr() . "\"";
          if ($peptide_prev_aa) {
          # only available for 2.1 and later
            print " peptide_prev_aa=\"$peptide_prev_aa\"";
            print " peptide_next_aa=\"$peptide_next_aa\"";
          }
          if ($db_list[0] > 1) {
            print " protein=\"" . &noXmlTag(($db_list[0] + 0) . "::" . $protein_list[0]) . "\"";
          } else {
            print " protein=\"" . &noXmlTag($protein_list[0]) . "\"";
          }
          print " num_tot_proteins=\"" . scalar(@protein_list) . "\"";
          print " num_matched_ions=\"" . $objPeptide->getNumIonsMatched() . "\"";
          # optional tot_num_ions
          print " calc_neutral_pep_mass=\"" . $objPeptide->getMrCalc . "\"";
          print " massdiff=\"" 
            . sprintf("%+." . $massDP . "f", $objPeptide->getDelta) 
            . "\"";
          # optional num_tol_term
          print " num_missed_cleavages=\"" . $objPeptide->getMissedCleavages . "\"";
          print " is_rejected=\"0\"";
          my $prot_desc = "";
          if ($thisScript->param($urlParams{'prot_desc'})) {
            $prot_desc = &noXmlTag(&mustGetProteinDescription($protein_list[0], \%fastaTitles, $db_list[0]));
          }
          if ($prot_desc) {
            print " protein_descr=\"$prot_desc\"";
          }
          my $frame = 0;
          if (($thisScript->param($urlParams{'prot_pi'}) 
            || $thisScript->param($urlParams{'prot_mass'}))
            && $objSummary->isNA) {
            my $objProtein = $objSummary->getProtein($protein_list[0], $db_list[0]);
            if ($objProtein) {
              $frame = $objProtein->getFrame();
            }
          }
          if ($thisScript->param($urlParams{'prot_pi'})) {
            my $pI = &getProteinpI($protein_list[0], $objSummary, $objParams, \%fastapI, $frame, $db_list[0]);
            if ($pI) {
              print " calc_pI=\"$pI\"";
            }
          }
          my $protein_mw = 0;
          if ($thisScript->param($urlParams{'prot_mass'})) {
            $protein_mw = &mustGetProteinMass($protein_list[0], $objSummary, $objParams, \%fastaMasses, $frame, $db_list[0]);
          }
          if ($protein_mw) {
            print " protein_mw=\""
              . sprintf("%.0f", $protein_mw)
              . "\"";
          }
          print ">\n";
          
          if (scalar(@protein_list) > 1) {
          # alternative_protein
            for (my $prot_num = 1; $prot_num <= $#protein_list; $prot_num++) {
              print "<alternative_protein";
              if ($db_list[$prot_num] > 1) {
                print " protein=\"" . &noXmlTag(($db_list[$prot_num] + 0) . "::" . $protein_list[$prot_num]) . "\"";
              } else {
                print " protein=\"" . &noXmlTag($protein_list[$prot_num]) . "\"";
              }
              if ($thisScript->param($urlParams{'prot_desc'})) {
              # only look for description in result file for alternative proteins
                if ($tempString = &noXmlTag($objSummary->getProteinDescription($protein_list[$prot_num], $db_list[$prot_num]))) {
                  print " protein_descr=\"$tempString\"";
                }
              }
              # optional num_tol_term
              if ($thisScript->param($urlParams{'prot_mass'})) {
              # only look for mass in result file for alternative proteins
                if ($tempString = $objSummary->getProteinMass($protein_list[$prot_num], $db_list[$prot_num])) {
                  print " protein_mw=\""
                    . sprintf("%.0f", $tempString)
                    . "\"";
                }
              }
              print "/>\n";
            }
          }
          
          my $varModsStr = $objPeptide->getVarModsStr();
          if ($varModsStr =~ /[1-9A-X]/) {
          # modification_info
          # grab any mod found in error tolerant search
            $tempString = 
                $objResFile->getSectionValueStr($objSummary->getSrcSection($queryNum, $rank), "q$queryNum\_p$srcRank\_et_mods");
            if ($tempString) {
              ($vmMass{'X'}, my $dummy, $vmString{'X'}) = split(/,/, $tempString, 3);
            }
            print "<modification_info";
          # N term
            my $position = substr($varModsStr, 0, 1);
            if ($position =~ /[1-9A-X]/){
              print " mod_nterm_mass=\"" . ($masses{'n_term'} + $vmMass{$position}) . "\"";
            }
          # C term
            $position = substr($varModsStr, -1);
            if ($position =~ /[1-9A-X]/){
              print " mod_cterm_mass=\"" . ($masses{'c_term'} + $vmMass{$position}) . "\"";
            }
            # optional modified_peptide
            print ">";
            
          # residues
            for (my $i = 1; $i < (length($varModsStr) - 1); $i++){
              $position = substr($varModsStr, $i, 1);
              if ($position =~ /[1-9A-X]/){
                print "\n<mod_aminoacid_mass";
                print " position=\"$i\"";
                print " mass=\"" . ($masses{lc(substr($objPeptide->getPeptideStr(), $i - 1, 1))} + $vmMass{$position}) . "\"/>\n";
              }
            }
            
            print "</modification_info>\n";
          }
        
        # search_score
          print "<search_score name=\"ionscore\" value=\"" 
            . $objPeptide->getIonsScore() . "\"/>\n";
          print "<search_score name=\"identityscore\" value=\"" 
            . $objSummary->getPeptideIdentityThreshold($queryNum, 1 / $sigThreshold) . "\"/>\n";
          if ($objSummary->getHomologyThreshold($queryNum, 1 / $sigThreshold)) {
            print "<search_score name=\"homologyscore\" value=\"" 
              . $objSummary->getHomologyThreshold($queryNum, 1 / $sigThreshold) . "\"/>\n";
          }
          print "<search_score name=\"expect\" value=\"" 
            . sprintf("%.2g", $objSummary->getPeptideExpectationValue($objPeptide->getIonsScore(), $queryNum)) . "\"/>\n";
          # optional type
          print "</search_hit>\n";
          
        } else {
          if ($rank == 1) {
            print "<spectrum_query";
            print " spectrum=\"" . &noXmlTag($objQuery->getStringTitle(1)) . "\"";
            print " start_scan=\"0\"";
            print " end_scan=\"0\"";
            print " precursor_neutral_mass=\"" . $objResFile->getObservedMrValue($queryNum) . "\"";
            print " assumed_charge=\"" . $objResFile->getObservedCharge($queryNum) . "\"";
            my $repeatSearchString = $objResFile->getRepeatSearchString($queryNum);
            $repeatSearchString =~ s/^[0-9.]+\s*//;
            $repeatSearchString =~ s/from\(.+?\)\s*//;
            $repeatSearchString =~ s/title\(.+?\)\s*//;
            $repeatSearchString =~ s/query\(.+?\)\s*//;
            $repeatSearchString =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex($1))/eg;
            $repeatSearchString =~ s/^\s*//;
            $repeatSearchString =~ s/\s*$//;
            if ($repeatSearchString) {
              print " search_specification=\"" . &noXmlTag($repeatSearchString) . "\"";
            }
            print " index=\"$queryNum\"/>\n";
          }
          last;
        }
      } else {
        last;
      }
    }
    if ($needClosingTag) {
      print "</search_result>\n";
      print "</spectrum_query>\n";
    }
  }

  print "</msms_run_summary>\n";
  
}

###############################################################################
# &getEnzymeDef()
# $_[0] enzyme title
# returns list:
# number of specificities
# independent (1 or 0)
# semispecific (1 or 0)
# cleavage string for specificity i
# restriction string for specificity i
# C or N for specificity i
# The last three elements are repeated as required
###############################################################################

sub getEnzymeDef {

  my(
  @enzymes,
  $thisCleavage,
  $thisCleaveEnd,
  $thisRestrict,
  @seqIn,
  $start,
  $end,
  $independent,
  $semispecific,
  @cleavage,
  @restrict,
  @cleaveEnd,
  );

# get enzyme cleavage rules
  open(TEMPFILE, "../config/enzymes") || die("cannot open enzymes file");
  @enzymes=<TEMPFILE>;
  close(TEMPFILE) || die("cannot close enzymes file");
  my $tempString = $_[0];
# Quote meta characters
  $tempString =~ s/(\W)/\\$1/g;
  my $i = 0;
  while ($enzymes[$i] && !($enzymes[$i]=~ /^Title:$tempString\s*$/i)){
    $i++;
  }
  $i++;
  $independent = 0;
  $semispecific = 0;
  while ($enzymes[$i] && !($enzymes[$i]=~ /^\*/)){
    chomp($enzymes[$i]);
    $enzymes[$i]=~ s/\s*$//;  # delete trailing white space
    if ($enzymes[$i]=~ /^Cleavage:(\w+)/i){
      $cleavage[0] = $1;
    } elsif ($enzymes[$i]=~ /^Restrict:(\w+)/i){
      $restrict[0] = $1;
    } elsif ($enzymes[$i]=~ /^Restrict:/i){
      # ignore
    } elsif ($enzymes[$i]=~ /^(\w)term$/i){
      $cleaveEnd[0] = $1;
    } elsif ($enzymes[$i]=~ /^Cleavage\[(\d+)\]:(\w+)/i){
      $cleavage[$1] = $2;
    } elsif ($enzymes[$i]=~ /^Restrict\[(\d+)\]:(\w+)/i){
      $restrict[$1] = $2;
    } elsif ($enzymes[$i]=~ /^Restrict\[(\d+)\]:/i){
      # ignore
    } elsif ($enzymes[$i]=~ /^(\w)term\[(\d+)\]/i){
      $cleaveEnd[$2] = $1;
    } elsif ($enzymes[$i]=~ /^Independent:(\d)/i){
      $independent = $1;
    } elsif ($enzymes[$i]=~ /^SemiSpecific:(\d)/i){
      $semispecific = $1;
    } else {
      die("Don't understand the enzyme file format");
    }
    $i++;
  }

# Sanity checks
  unless (defined($cleavage[0]) && $cleavage[0]) {
    die("invalid enzyme definition for $_[0]");
  }
  if (@cleaveEnd != @cleavage || @restrict > @cleavage) {
    die("invalid enzyme definition for $_[0]");
  }
  foreach (@cleavage) {
    unless ($_) {
      die("invalid enzyme definition for $_[0]");
    }
  }
  foreach (@cleaveEnd) {
    unless ($_ eq "N" || $_ eq "C") {
      die("invalid enzyme definition for $_[0]");
    }
  }
  
  my @retVals;
  push @retVals, scalar(@cleavage);
  push @retVals, $independent;
  push @retVals, $semispecific;
  for ($i = 0; $i < scalar(@cleavage); $i++) {
    push @retVals, $cleavage[$i];
    push @retVals, $restrict[$i];
    push @retVals, $cleaveEnd[$i];
  }
  
  return @retVals;

}

###############################################################################
# &DTASelect()
# output Scripps DTASelect file
# my($objParams, $objResFile, $objSummary, $msresFlags);
###############################################################################

sub DTASelect {

# pre-calculate total intensity values
  my @totalIntensity;
  for (my $queryNum = 1; $queryNum <= $objResFile->getNumQueries(); $queryNum++){
    my $objQuery = new msparser::ms_inputquery($objResFile, $queryNum);
    $totalIntensity[$queryNum] = $objQuery->getTotalIonsIntensity();
  }

# terminal_modifications
# fixed
  my(@term_mods, $iCount);
  if ($objParams->getFixedModsName(1)) {
    $iCount = 1;  
    while ($objParams->getFixedModsName($iCount)) {
      push @term_mods, &getTerminalMods($objParams->getFixedModsName($iCount), "N");
      $iCount++;
    }
  } else {
    my $mod_string = $objParams->getMODS();
    if ($mod_string) {
      my @mod_list = split(/,/, $mod_string);
      foreach my $modName (@mod_list) {
        push @term_mods, &getTerminalMods($modName, "N");
      }
    }
  }
# variable
  $iCount = 1;  
  while ($objParams->getVarModsName($iCount)) {
    push @term_mods, &getTerminalMods($objParams->getVarModsName($iCount), "Y");
    $iCount++;
  }
  
  my $fixProtC = 0;
  my $fixProtN = 0;
  my $fixPepC = 0;
  my $fixPepN = 0;
  while (@term_mods) { 
    my $terminus = shift(@term_mods);
    my $massdiff = shift(@term_mods);
    my $mass = shift(@term_mods);
    my $variable = shift(@term_mods);
    my $protein_terminus = shift(@term_mods);
    my $description = shift(@term_mods);
    if ($variable eq "N") {
      if ($protein_terminus eq "c") {
        $fixProtC = $massdiff;
      } elsif ($protein_terminus eq "n") {
        $fixProtN = $massdiff;
      } elsif ($terminus eq "c") {
        $fixPepC = $massdiff;
      } elsif ($terminus eq "n") {
        $fixPepN = $massdiff 
      }
    }
  }   

# output header lines
  print  "DTASelect v1.9\n";
  print  "\n";
  print  "\n";
  print  "S\t" . $objResFile->getFastaVer(1) . "\t$fixProtC\t$fixProtN\t$fixPepC\t$fixPepN\tfalse\ttrue\n";
    
# aminoacid_modifications
# fixed
  my @res_mods;
  if ($objParams->getFixedModsName(1)) {
    $iCount = 1;  
    while ($objParams->getFixedModsName($iCount)) {
      push @res_mods, &getResidueMods($objParams->getFixedModsName($iCount), "N");
      $iCount++;
    }
  } else {
    my $mod_string = $objParams->getMODS();
    if ($mod_string) {
      my @mod_list = split(/,/, $mod_string);
      foreach my $modName (@mod_list) {
        push @res_mods, &getResidueMods($modName, "N");
      }
    }
  }
# variable
  $iCount = 1;  
  while ($objParams->getVarModsName($iCount)) {
    push @res_mods, &getResidueMods($objParams->getVarModsName($iCount), "Y");
    $iCount++;
  }

  my @symbols = qw(* # @ $ % & ~ ? / + = 1 2 3 4 5 6 7 8 9);
  my %symLink;
  while (@res_mods) {
    my $aminoacid = shift(@res_mods);
    my $massdiff = shift(@res_mods);
    my $mass = shift(@res_mods);
    my $variable = shift(@res_mods);
    my $terminalMod = shift(@res_mods);
    my $description = shift(@res_mods);
    if ($variable eq "N") {
      print "SM\t$massdiff\t$aminoacid\n";
    } else {
      my $symbol = shift(@symbols);
      ${ $symLink{$description} }{$aminoacid} = $symbol;
      print "DM\t$massdiff\t$symbol\t$aminoacid\t0.0\t0.0\n";
    }
  }

  print  "Source\tMascot\t" . $objResFile->getMascotVer() . "\n";
  print  "Format\tMascot\n";

# start of MAIN LOOP to enumerate the protein hits
  my $numL = 0;
  my $numD = 0;
  my $thisHit = 1;  
  my $objProtein = $objSummary->getHit($thisHit);
  while (defined($objProtein)) {
    
    &outputL($objProtein);
    $numL++;
    &outputD($objProtein, \@totalIntensity, \%symLink);
    $numD++;
    if ($msresFlags & $msparser::ms_mascotresults::MSRES_GROUP_PROTEINS) {
      my $i = 1;
      while (($objProtein = $objSummary->getNextSimilarProtein($thisHit, $i)) != 0)  {
        &outputL($objProtein);
        $numL++;
        &outputD($objProtein, \@totalIntensity, \%symLink);
        $numD++;
        $i++;
      }
      if ($msresFlags & $msparser::ms_mascotresults::MSRES_SHOW_SUBSETS) {
      # $ShowSubSets hard coded to 1 for DTASelect
        my $i = 1;
        while (($objProtein = $objSummary->getNextSubsetProtein($thisHit, $i)) != 0) {
          if ($objProtein->getScore() > 0) {
            &outputL($objProtein);
            $numL++;
            &outputD($objProtein, \@totalIntensity, \%symLink);
            $numD++;
          }
          $i++;
        }
      }
    }

    $thisHit++;
    $objProtein = $objSummary->getHit($thisHit);
    
  }
# end of MAIN LOOP to enumerate the protein hits
  
  print  "C\t$numL\t" . $objResFile->getNumQueries() . "\t$numD\n";

}

###############################################################################
# &outputL()
# output DTASelect L line
# $_[0] $objProtein
# my($objParams, $objSummary, %fastaLen, %fastaMasses, %fastapI, %fastaTitles);
###############################################################################

sub outputL {
  
  my $objProtein = shift;

  my ($Length, $Description, $MW, $pI);
  if ($thisScript->param($urlParams{'prot_desc'})) {
    $Description = &mustGetProteinDescription($objProtein->getAccession(), \%fastaTitles, $objProtein->getDB);
  }
  $Description = "no description" unless ($Description);
  if ($thisScript->param($urlParams{'prot_mass'})) {
    $MW = &mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame(), $objProtein->getDB);
  }
  $MW = 0 unless ($MW);
  if ($thisScript->param($urlParams{'prot_len'})) {
    $Length = &getProteinLen($objProtein->getAccession(), $objSummary, $objParams, \%fastaLen, $objProtein->getFrame(), $objProtein->getDB);
  } elsif ($MW) {
    $Length = int($MW / 110);
  }
  $Length = 0 unless ($Length);
  if ($thisScript->param($urlParams{'prot_pi'})) {
    $pI = &getProteinpI($objProtein->getAccession(), $objSummary, $objParams, \%fastapI, $objProtein->getFrame(), $objProtein->getDB);
  }
  $pI = 0 unless ($pI);

  my $dbNumPrefix = "";
  if ($objParams->getNumberOfDatabases > 1 && $objProtein->getDB > 1) {
    $dbNumPrefix = $objProtein->getDB . "::";
  }
  
  print  join("\t", 
    "L", 
    $dbNumPrefix . $objProtein->getAccession(), 
    $Length, 
    $MW, 
    $pI, 
    $Description, 
    "U\n");
  
}

###############################################################################
# &outputD()
# output DTASelect D line
# $_[0] $objProtein
# $_[1] reference to @totalIntensity
# $_[2] reference to %symLink
# my($objResFile, $objSummary, $fileIn);
###############################################################################

sub outputD {
  
  my ($objProtein, $totalIntensity_ref, $symLink_ref) = @_;
  
# Enumerate the peptides that matched this protein
  for (my $i = 1; $i <= $objProtein->getNumPeptides(); $i++) {
    my $queryNum = $objProtein->getPeptideQuery($i);
    my $objPeptide = $objSummary->getPeptide($queryNum, $objProtein->getPeptideP($i));
    my $ionSeriesString = $objPeptide->getSeriesUsedStr();
    my $numScoreSeries = $ionSeriesString =~ tr/2//;
    my $unique2locus = "true";
    if ($objPeptide->getNumProteins() > 0) {
      $unique2locus = "false";
    }
    
    my $local_pep = $objPeptide->getPeptideStr();

  # use the variable mods string to interpolate variable mod symbols into peptide string
    my $varModsString = $objPeptide->getVarModsStr();
    unless ($varModsString eq "0" x length($varModsString)) {
      for (my $i = length($varModsString) - 2; $i > 0; $i--) {
        if (substr($varModsString, $i, 1) =~ /[1-9A-X]/) {
          my $symbol = ${ ${ $symLink_ref }{$vmString{substr($varModsString, $i, 1)}} }{substr($local_pep, $i - 1, 1)};
          substr($local_pep, $i - 1, 1) = substr($local_pep, $i - 1, 1) . $symbol;
        }
      }
    }

    my $aa_before = $objProtein->getPeptideResidueBefore($i);
    my $aa_after = $objProtein->getPeptideResidueAfter($i);
 #  unless ($aa_before eq "?" || $aa_after eq "?") {
      $aa_before =~ s/@/-/;
      $aa_after =~ s/@/-/;
      $local_pep = "$aa_before.$local_pep.$aa_after";
 #  }

    print  join("\t", 
      "D",
      "$fileIn.$queryNum." . $objPeptide->getCharge(),
      $fileIn =~ /^(.*).dat/,
      $objPeptide->getIonsScore(),
      sprintf("%.1f", $objSummary->getProbOfPepBeingRandomMatch($objPeptide->getIonsScore(), $queryNum)),
      ($objPeptide->getMrExperimental + $masses{'hydrogen'} - $masses{'electron'}),
      ($objPeptide->getMrCalc() + $masses{'hydrogen'} - $masses{'electron'}),
      sprintf("%.1f", ${ $totalIntensity_ref }[$queryNum]),
      $objPeptide->getPrettyRank(),
      $objSummary->getPeptideIdentityThreshold($queryNum, 1 / $sigThreshold),
      sprintf("%.3f", $objPeptide->getNumIonsMatched() / $numScoreSeries / (length($objPeptide->getPeptideStr()) - 1)),
      $local_pep,
      ($objProtein->getPeptideStart($i) - 1),
      "0",
      $unique2locus,
      "1",
      "U\n");
        
  }

}

###############################################################################
# &mascotDAT()
# download raw Mascot result file
# my($fileIn);
###############################################################################

sub mascotDAT {

# parse out result file name root
  my($dir, $file) = $fileIn =~ /data[\/\\](\d\d\d\d\d\d\d\d)[\/\\](F.*dat)$/;
  
  unless ($dir && $file) {
    print $thisScript->header( -charset => "utf-8" );
    print "Can only download result files from daily folders under the Mascot data directory\n";
    exit 1;
  }
  
  unless (open(INFILE, &common_subs::decompress($fileIn))) {
    print $thisScript->header( -charset => "utf-8" );
    print "Unable to open result file for reading\n";
    exit 1;
  }

  if ($ENV{'SERVER_NAME'}) {
    print $thisScript->header( -type => "text/plain",
                               -charset => "utf-8",
                               -attachment => "$file");
  }

  while (<INFILE>) {
    print $_;
  }
  
}

###############################################################################
# &exportMGF()
# download MGF Peak List
# my($objResFile, $fileIn)
###############################################################################

sub exportMGF {
  
# parse out result file name root
  $fileIn =~ /[\/\\](F.*)\.dat$/;

  if ($ENV{'SERVER_NAME'}) {
    print $thisScript->header( -type => "text/plain",
                               -charset => "utf-8",
                               -attachment => "$1.mgf");
  }

  if ($objResFile->anyMSMS() || $objResFile->anySQ() || $objResFile->anyTag()) {
    for (my $queryNum = 1; $queryNum <= $objResFile->getNumQueries; $queryNum++) {
      my $objQuery = new msparser::ms_inputquery($objResFile, $queryNum);
      print "BEGIN IONS\n";
      my $intensity = $objResFile->getObservedIntensity($queryNum) + 0;
      print "PEPMASS=" . $objResFile->getObservedMass($queryNum);
      if ($intensity != 0) {
        print " $intensity\n";
      } else {
        print "\n";
      }
      if ($objQuery->getCharge()) {
        print "CHARGE=" . $objQuery->getCharge() . "\n";
      }
      if ($objQuery->getStringTitle(1)) {
        print "TITLE=" . $objQuery->getStringTitle(1) . "\n";
      }
      if ($objQuery->getScanNumbers()) {
        print "SCANS=" . $objQuery->getScanNumbers() . "\n";
      }
      if ($objQuery->getRetentionTimes()) {
        print "RTINSECONDS=" . $objQuery->getRetentionTimes() . "\n";
      }
      if ($objQuery->getPepTol()) {
        print "TOL=" . $objQuery->getPepTol() . "\n";
      }
      if ($objQuery->getPepTolUnits()) {
        print "TOLU=" . $objQuery->getPepTolUnits() . "\n";
      }
      for (my $j = 1; $j <= 20; $j++) {
        if ($objQuery->getSeq($j)) {
          print "SEQ=" . $objQuery->getSeq($j) . "\n";
        } else {
          last;
        }
      }
      for (my $j = 1; $j <= 20; $j++) {
        if ($objQuery->getComp($j)) {
          print "COMP=" . $objQuery->getComp($j) . "\n";
        } else {
          last;
        }
      }
      for (my $j = 1; $j <= 20; $j++) {
        if ($objQuery->getTag($j)) {
          $objQuery->getTag($j) =~ /([et]),(.*)/i;
          if (lc($1) eq "e") {
            print "ETAG=$2\n";
          } else {
            print "TAG=$2\n";
          }
        } else {
          last;
        }
      }
      if ($objQuery->getIT_MODS(1)) {
        print "IT_MODS=" . $objQuery->getIT_MODS(1) . "\n";
      }
      if ($objQuery->getINSTRUMENT(1)) {
        print "INSTRUMENT=" . $objQuery->getINSTRUMENT(1) . "\n";
      }
      if ($objQuery->getRULES()) {
        print "RULES=" . $objQuery->getRULES() . "\n";
      }
      my $peakStr = $objQuery->getStringIons1();
    # no way to represent ions(b- or ions(y- in MGF format, so just output values as unassigned
      if ($objQuery->getStringIons2()) {
        $peakStr .= "," . $objQuery->getStringIons2();
      }
      if ($objQuery->getStringIons3()) {
        $peakStr .= "," . $objQuery->getStringIons3();
      }
      if ($peakStr) {
        $peakStr =~ s/:/ /g;
        $peakStr =~ s/,/\n/g;
        print "$peakStr\n";
      }
      print "END IONS\n\n";
    }
  } else {
  # PMF
    for (my $queryNum = 1; $queryNum <= $objResFile->getNumQueries; $queryNum++) {
      my $intensity = $objResFile->getObservedIntensity($queryNum) + 0;
      print $objResFile->getObservedMass($queryNum);
      if ($intensity != 0) {
        print " $intensity\n";
      } else {
        print "\n";
      }
    }
  }
  
}

###############################################################################
# &display_args()
# display command line arguments for copy and paste
# my($fileIn);
###############################################################################

sub display_args {

  print $thisScript->header( -charset => "utf-8", -expires => '-1d' );
  &common_subs::printHeader1("Matrix Science - Mascot - Export search results");
  &common_subs::printHeader2("", "Export search results", 1);

  print <<'end_of_static_HTML_text_block';
  <TABLE BORDER=0 CELLSPACING=1 CELLPADDING=3>
    <TR>
      <TD NOWRAP ALIGN=LEFT><h2>Command line arguments equivalent to current form settings</h2></TD>
    </TR>
     <TR> 
       <TD>&nbsp;</TD> 
     </TR> 
    <TR>
      <TD ALIGN=LEFT><tt>
end_of_static_HTML_text_block
      
  foreach ($thisScript->param) {
    if (lc($_) eq "do_export") {
      print "do_export=1 ";
    } elsif (!$thisScript->param($urlParams{$_})) {
    # skip
    } elsif ($thisScript->param($urlParams{$_}) =~ /\s/) {
      print lc($_) . "=\"" . $thisScript->param($urlParams{$_}) . "\" ";
    } else {
      print lc($_) . "=" . $thisScript->param($urlParams{$_}) . " ";
    }
  }
      
  print <<'end_of_static_HTML_text_block';
      </tt></TD>
    </TR>
  </TABLE>
end_of_static_HTML_text_block

  &common_subs::printFooter;

  print "</BODY>\n";
  print "</HTML>\n";
    
}

###############################################################################
# &mzIdentML()
# output PSI mzIdentML elements
# my($objParams);
###############################################################################

sub mzIdentML {
  my (@ontol);
  my ($dpid) = 1;
  
# get available variable mods
  my $vecVariable = new msparser::ms_modvector();
  my $i = 1;
  while (my $modText = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_MASSES, "delta" . $i)) {
    my ($mass, $name) = split(/,/, $modText, 2);
    my $objMod = $objModFile->getModificationByName($name);
    if ($objMod) {
      $vecVariable->appendModification($objMod);
    } else {
      return (0, "Modification " . $name . " cannot be found");
    }
    $i++;
  }
# get available fixed mods
  my $vecFixed = new msparser::ms_modvector();
  $i = 1;
  while (my $modText = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_MASSES, "FixedMod" . $i)) {
    my ($mass, $name) = split(/,/, $modText, 2);
    my $objMod = $objModFile->getModificationByName($name);
    if ($objMod) {
      $vecFixed->appendModification($objMod);
    } else {
      return (0, "Modification " . $name . " cannot be found");
    }
    $i++;
  }

# make hash for fast retrieval of fixed mods
  my %fixedMods;
  for (my $i = 0; $i < $vecFixed->getNumberOfModifications; $i++) {
    my $objMod = $vecFixed->getModificationByNumber($i);
    if ($objMod->getModificationType == $msparser::MOD_TYPE_N_TERM) {
      $fixedMods{'n-term'} = $objMod->getTitle;
    } elsif ($objMod->getModificationType == $msparser::MOD_TYPE_C_TERM) {
      $fixedMods{'c-term'} = $objMod->getTitle;
    } else {
      for (my $j = 0; $j < $objMod->getNumberOfModifiedResidues; $j++) {
        $fixedMods{lc($objMod->getModifiedResidue($j))} = $objMod->getTitle;
      } 
    }
  }

  print "  <cvList>\n";
  print "    <cv id=\"PSI-MS\" fullName=\"Proteomics Standards Initiative Mass Spectrometry Vocabularies\"   URI=\"http://psidev.cvs.sourceforge.net/viewvc/*checkout*/psidev/psi/psi-ms/mzML/controlledVocabulary/psi-ms.obo\" version=\"2.32.0\"></cv>\n";
  print "    <cv id=\"UNIMOD\" fullName=\"UNIMOD\"        URI=\"http://www.unimod.org/obo/unimod.obo\"></cv>\n";
  print "    <cv id=\"UO\"     fullName=\"UNIT-ONTOLOGY\" URI=\"http://obo.cvs.sourceforge.net/*checkout*/obo/obo/ontology/phenotype/unit.obo\"></cv>\n";
  print "  </cvList>\n";
  
  # We need record_id values for the UNIMOD entries. If we don't have them, try unimod.xml
  if ($objUmodConfigFile->getNumberOfModifications() > 0
    && $objUmodConfigFile->getModificationByNumber(0)->haveRecordID()) {
      $objUmodConfigFile2 = $objUmodConfigFile;
  } else {
    $objUmodConfigFile2 = new msparser::ms_umod_configfile("../config/unimod.xml",
      "../html/xmlns/schema/unimod_2/unimod_2.xsd");
  }
  
  print "  <AnalysisSoftwareList>\n";
  print "    <AnalysisSoftware id=\"AS_mascot_server\" name=\"Mascot Server\" version=\""
              . $objResFile->getMascotVer()  
              . "\" URI=\"http://www.matrixscience.com/search_form_select.html\" >\n";
  print "      <ContactRole Contact_ref=\"ORG_MSL\">\n";
  print "        <role>\n";
  print "          <cvParam accession=\"MS:1001267\" name=\"software vendor\" cvRef=\"PSI-MS\"/>\n";
  print "        </role>\n";
  print "      </ContactRole>\n";
  print "      <SoftwareName>\n";
  print "        <cvParam accession=\"MS:1001207\" name=\"Mascot\" cvRef=\"PSI-MS\"/>\n";
  print "      </SoftwareName>\n";

  print "      <Customizations>\n";
  print "        No customisations\n";
  print "      </Customizations>\n";
  print "    </AnalysisSoftware>\n";
  print "    <AnalysisSoftware id=\"AS_mascot_parser\" name=\"Mascot Parser\" version=\""
              .  $objResFile->getMSParserVersion()
              . "\" URI=\"http://www.matrixscience.com/msparser.html\" >\n";
  print "      <ContactRole Contact_ref=\"ORG_MSL\">\n";
  print "        <role>\n";
  print "          <cvParam accession=\"MS:1001267\" name=\"software vendor\" cvRef=\"PSI-MS\"/>\n";
  print "        </role>\n";
  print "      </ContactRole>\n";
  print "      <SoftwareName>\n";
  print "        <cvParam accession=\"MS:1001478\" name=\"Mascot Parser\" cvRef=\"PSI-MS\"/>\n";
  print "      </SoftwareName>\n";
  print "      <Customizations>\n";
  print "        No customisations\n";
  print "      </Customizations>\n";
  print "    </AnalysisSoftware>\n";
  print "  </AnalysisSoftwareList>\n";
  
  print "  <Provider id=\"PROVIDER\">\n";
  print "    <ContactRole Contact_ref=\"PERSON_DOC_OWNER\">\n";
  print "      <role>\n";
  print "        <cvParam accession=\"MS:1001271\" name=\"researcher\" cvRef=\"PSI-MS\" />\n";
  print "      </role>\n";
  print "    </ContactRole>\n";
  print "  </Provider>\n";
  
  print "  <AuditCollection>\n";
  print "    <Person id=\"\">\n";
  print "      <affiliations Organization_ref=\"ORG_MSL\"/>\n";
  print "    </Person>\n";
  print "    <Person id=\"PERSON_DOC_OWNER\" firstName=\"\" lastName=\"" . &noXmlTag($objParams->getUSERNAME) . "\" email=\"" . &noXmlTag($objParams->getUSEREMAIL) . "\">\n";
  print "      <affiliations Organization_ref=\"ORG_DOC_OWNER\"/>\n";
  print "    </Person>\n";
  print "    <Organization id=\"ORG_MSL\" name=\"Matrix Science Limited\" address=\"64 Baker Street, London W1U 7GB, UK\" email=\"support\@matrixscience.com\"  fax=\"+44 (0)20 7224 1344\" phone=\"+44 (0)20 7486 1050\" />\n";
  print "    <Organization id=\"ORG_DOC_OWNER\" />\n";
  print "  </AuditCollection>\n";
  
  my (@componentNames, $numcomponents, $c, %aaHelpers);
  if ($objQuantMethod) {
    $numcomponents = $objQuantMethod->getNumberOfComponents; 
    for ($c=0; $c < $numcomponents; $c++) {
      my $component = $objQuantMethod->getComponentByNumber($c);
      $componentNames[$c] = $component->getName;
      my $objLocalMassesFile = new msparser::ms_masses($objMassesFile); 
      if ($component->getNumberOfIsotopes > 0) {
        $objLocalMassesFile->applyIsotopes($objUmodConfigFile, $component);
      }
      $aaHelpers{$component->getName} = new msparser::ms_aahelper($objResFile, "../config/enzymes");
      $aaHelpers{$component->getName}->setMasses($objLocalMassesFile);
      $aaHelpers{$component->getName}->setAvailableModifications($vecFixed, $vecVariable);
    # success?
      if (!$aaHelpers{$component->getName}->isValid()) {
        die "Unable to create aahelper object: " . $aaHelpers{$component->getName}->getLastErrorString();
      }
    }
  } else {
    $numcomponents = 1;
    $componentNames[0] = "1";
    my $objLocalMassesFile = new msparser::ms_masses($objMassesFile); 
    $aaHelpers{"1"} = new msparser::ms_aahelper($objResFile, "../config/enzymes");
    $aaHelpers{"1"}->setMasses($objLocalMassesFile);
    $aaHelpers{"1"}->setAvailableModifications($vecFixed, $vecVariable);
  # success?
    if (!$aaHelpers{"1"}->isValid()) {
      die "Unable to create aahelper object: " . $aaHelpers{"1"}->getLastErrorString();
    }
  }

  if ($numcomponents > 1) {
    print "  <AnalysisSampleCollection>\n";
    my $protocol = $objQuantMethod->getProtocol;
    if ($protocol) {
      my $quantType = $protocol->getType;
    }

    for ($c=0; $c < $numcomponents; $c++) { 
      my $component = $objQuantMethod->getComponentByNumber($c);
      print "    <Sample id=\"Sample_" . &noXmlTag($component->getName) . "\">\n";
      print "      <userParam name=\"" . &noXmlTag($component->getName) . "\"/>\n";
      if ($component->getNumberOfIsotopes > 0) {
        my $i;
        for ($i = 0; $i < $component->getNumberOfIsotopes; ++$i) {
          my $isotope = $component->getIsotope($i);
          if ($isotope->haveOld && $isotope->haveNew) {
            print "      <userParam name=\"Isotope: " . $isotope->getOld . " -> " .  $isotope->getNew . "\"/>\n";
          } else {
            print "      <userParam name=\"Isotope: None\"/>\n";
          } 
        }
      }
      print "    </Sample>\n";
    }
    print "    <Sample id=\"Sample_Combined\">\n";
    for ($c=0; $c < $numcomponents; $c++) {
      my $component = $objQuantMethod->getComponentByNumber($c);
      print "      <subSample Sample_ref=\"Sample_" . &noXmlTag($component->getName) . "\"/>\n";
    }
    print "    </Sample>\n";
    print "  </AnalysisSampleCollection>\n";
  }

  ## Mascot Ontology reference
  my ($mascot_score_id) = "DP:" . $dpid . ":mascot_ions_score";
  push(@ontol, "        <DataProperty term=\"mascot:matched ions\" termAccession=\"MS:1001173\" id=\"" . $mascot_score_id . "\" name=\"mascot ions score\" dataType=\"xsd:double\" OntologySource_ref=\"MASCOT:PSI:PI\"/>\n");
  $dpid++;

  my ($mascot_expect_value_id) = "DP:" . $dpid . ":mascot:expectation value";
  push(@ontol, "        <DataProperty term=\"mascot expect value\" termAccession=\"MS:1001172\" id=\"" . $mascot_expect_value_id . "\" name=\"mascot expect value\" dataType=\"xsd:double\" OntologySource_ref=\"MASCOT:PSI:PI\"/>\n");
  $dpid++;

  my ($mascot_rank_id) = "DP:" . $dpid . ":mascot_rank";
  push(@ontol, "        <DataProperty term=\"mascot rank\" termAccession=\"PI:99999\" id=\"" . $mascot_rank_id . "\" name=\"mascot rank\" dataType=\"xsd:int\" OntologySource_ref=\"MASCOT:PSI:PI\"/>\n");
  $dpid++;

  my %sequences;
    
  print "  <SequenceCollection>\n";
  
  $objSummary->setSubsetsThreshold($ShowSubSets);
  for (my $i = 1; $i <= $objSummary->getNumberOfHits; $i++) {
    my $objProtein = $objSummary->getHit($i);
    unless ($sequences{ $objProtein->getDB . "::" . $objProtein->getAccession }) {
      &mzIdentMLOutputProtein($objProtein->getDB, $objProtein->getAccession);
      $sequences{ $objProtein->getDB . "::" . $objProtein->getAccession } = 1;
      unless ($thisScript->param($urlParams{'query_all'}) || $objResFile->isPMF()) {
        for (my $i=1; $i <= $objProtein->getNumPeptides(); $i++) {
          $queryList[$objProtein->getPeptideQuery($i)] = 1;
        }
      }
    }
    
    my $j;
    if ($thisScript->param($urlParams{'show_same_sets'})) {
      $j = 1;
      while ($objProtein = $objSummary->getNextSimilarProtein($i, $j)) {
        unless ($sequences{ $objProtein->getDB . "::" . $objProtein->getAccession }) {
          &mzIdentMLOutputProtein($objProtein->getDB, $objProtein->getAccession);
          $sequences{ $objProtein->getDB . "::" . $objProtein->getAccession } = 1;
        }
        $j++;
      }
    }
    $j = 1;
    while ($objProtein = $objSummary->getNextSubsetProtein($i, $j)) {
      unless ($sequences{ $objProtein->getDB . "::" . $objProtein->getAccession }) {
        &mzIdentMLOutputProtein($objProtein->getDB, $objProtein->getAccession);
        $sequences{ $objProtein->getDB . "::" . $objProtein->getAccession } = 1;
      }
      $j++;
    }
  }    

  # if query_all, then want to output all possible DBSequence values so that we can
  # output <PeptideEvidence> for everything.
  if ($thisScript->param($urlParams{'query_all'})) {
    my ($query, $rank);
    for ($query = 1; $query <= $objResFile->getNumQueries(); $query++) {
      for ($rank = 1; $rank <= $objSummary->getMaxRankValue(); $rank++) {
        my $db    = new msparser::vectori;
        my $accessions = $objSummary->getAllProteinsWithThisPepMatch($query, $rank, 
                                                                     msparser::vectori->new,      # discard (start)
                                                                     msparser::vectori->new,      # discard (end)
                                                                     msparser::VectorString->new, # discard (pre)
                                                                     msparser::VectorString->new, # discard (post)
                                                                     msparser::vectori->new,      # discard (frame)
                                                                     msparser::vectori->new,      # discard (multiplicity)
                                                                     $db);
        my @arr = @ { $accessions };
        for (my $i=0; $i < @arr; $i++) {
          my $accession = $arr[$i];
          unless ($sequences{ $db->get($i) . "::" . $accession }) {
            &mzIdentMLOutputProtein($db->get($i), $accession);
            $sequences{ $db->get($i) . "::" . $accession } = 1;
          }
        }
      }
    }
  }



  # Now output all peptide matches
  my ($query, $rank);
  for ($query = 1; $query <= $objResFile->getNumQueries(); $query++) {
    if ($thisScript->param($urlParams{'query_all'}) || $queryList[$query] || $objResFile->isPMF()) {
      for ($rank = 1; $rank <= $objSummary->getMaxRankValue(); $rank++) {
        my $objpeptide = $objSummary->getPeptide($query, $rank);
        my $pepstr = $objpeptide->getPeptideStr(0);
        
        if ($pepstr ne "") {
          print "    <Peptide id=\"peptide_" . $query . "_" . $rank . "\">\n";
          print "      <peptideSequence>" . $pepstr . "</peptideSequence>\n";
          
          # Any modifications?
          my $varModsStr = $objpeptide->getVarModsStr();
          my $nlStr = $objpeptide->getPrimaryNlStr();
          my @pepRes = split(//, lc($objpeptide->getPeptideStr(1)));
          
          for (my $p = 0; $p <= (length($varModsStr) - 1); $p++){
            my $position = substr($varModsStr, $p, 1);
            my $mod_name;
            if ($position =~ /[1-9A-X]/){
            # variable mod
              print "      <Modification location=\"" . $p . "\" ";
              if ($p > 0 && $p < (length($varModsStr) - 1)) {
                print "residues=\"" . substr($pepstr, $p-1, 1) . "\" ";
              }
              my $srcRank = $rank;
              if ($position eq "X") {
                $srcRank = $objSummary->getSrcRank($query, $rank);
                my $tempString = 
                    $objResFile->getSectionValueStr($objSummary->getSrcSection($query, $rank), "q$query\_p$srcRank\_et_mods");
                if ($tempString) {
                  ($vmMass{'X'}, my $dummy, $vmString{'X'}) = split(/,/, $tempString, 3);
                }
              } 
              if ($position eq "X" && $vmMass{'X'} == 0 && $vmString{'X'} =~ /^NA_/) { 
              # NA_SUBSTITUTION, NA_INSERTION, NA_DELETION
                print ">\n";
                print "        <userParam name=\"" . $vmString{'X'}. "\" />\n";
                my $tempString = 
                    $objResFile->getSectionValueStr($objSummary->getSrcSection($query, $rank), "q$query\_p$srcRank\_na_diff");
                if ($tempString) {
                  (my $old, my $new) = split(/,/, $tempString, 2);
                  print "        <userParam name=\"original_na_seq\" value=\"" . &noXmlTag($old) . "\"/>\n";
                  print "        <userParam name=\"modified_na_seq\" value=\"" . &noXmlTag($new) . "\"/>\n";
                }
              } else {
                if ($objParams->getMassType == $msparser::MASS_TYPE_MONO) {
                  print "monoisotopicMassDelta=\"" . $vmMass{$position} . "\"";
                } else {
                  print "avgMassDelta=\"" . $vmMass{$position} . "\"";
                }
                print ">\n";
                $mod_name = $vmString{$position};
                $mod_name =~ /(.*)\s+\((.*)\)/;
                $mod_name = $1;
                my $acc;
                my $mod2 = $objUmodConfigFile2->getModificationByName($mod_name);
                if ($mod2) {
                  $acc = "UNIMOD:" . $mod2->getRecordID;
                } else {
                  $acc = "UNIMOD:unknown";
                }
                print "        <cvParam accession=\"" . &noXmlTag($acc) . "\" name=\"" . &noXmlTag($mod_name) . "\" cvRef=\"UNIMOD\" />\n";
                
                my $nl_id = substr($nlStr, $p, 1);
                if ($nl_id > 0){
                  my @arr = @ { $objParams->getVarModsNeutralLosses($position) };
                  if ($nl_id-1 < @arr) {
                    print "        <cvParam accession=\"MS:1001524\" name=\"fragment neutral loss\" cvRef=\"PSI-MS\" value=\"" . $arr[$nl_id-1] . "\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\"/>\n";
                  }
                }
              }
              print "      </Modification>\n";
            } else {
            # check for fixed mod
              if ($p == 0) {
              # n-term
                $mod_name = $fixedMods{'n-term'};
              } elsif ($p == (length($varModsStr) - 1)) {
              # c-term
                $mod_name = $fixedMods{'c-term'};
              } else {
              # residue $pepRes[$p-1];
                $mod_name = $fixedMods{$pepRes[$p-1]};
              }
              if ($mod_name) {
                my $objMod = $objModFile->getModificationByName($mod_name);
                print "      <Modification location=\"" . $p . "\" ";
                if ($p > 0 && $p < (length($varModsStr) - 1)) {
                  print "residues=\"" . substr($pepstr, $p-1, 1) . "\" ";
                }
                if ($objParams->getMassType == $msparser::MASS_TYPE_MONO) {
                  print "monoisotopicMassDelta=\"" . $objMod->getDelta($objParams->getMassType) . "\"";
                } else {
                  print "avgMassDelta=\"" . $objMod->getDelta($objParams->getMassType) . "\"";
                }
                print ">\n";
                $mod_name =~ /(.*)\s+\((.*)\)/;
                $mod_name = $1;
                my $acc;
                my $mod2 = $objUmodConfigFile2->getModificationByName($mod_name);
                if ($mod2) {
                  $acc = "UNIMOD:" . $mod2->getRecordID;
                } else {
                  $acc = "UNIMOD:unknown";
                }
                print "        <cvParam accession=\"" . &noXmlTag($acc) . "\" name=\"" . &noXmlTag($mod_name) . "\" cvRef=\"UNIMOD\" />\n";
                if ($objMod->getNeutralLoss($objParams->getMassType) && ${ $objMod->getNeutralLoss($objParams->getMassType) }[0] > 0) {
                  print "        <cvParam accession=\"MS:1001524\" name=\"fragment neutral loss\" cvRef=\"PSI-MS\" value=\"" . ${ $objMod->getNeutralLoss($objParams->getMassType) }[0] . "\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\"/>\n";
                }
                print "      </Modification>\n";
              }
            }
          }
          # Any substitutions?
          my $ambiguity = $objpeptide->getAmbiguityString();
          if ($ambiguity) {
            # Format: 4,X,A
            my ($location, $before, $after) = split(/,/, $ambiguity);
            print "      <SubstitutionModification location=\"". $location . "\" originalResidue=\"" . $before . "\" replacementResidue=\"" . $after . "\"/>\n";
          }
          
          print "    </Peptide>\n";
        }
      }
    }
  }
  print "  </SequenceCollection>\n";

  print "  <AnalysisCollection>\n";
  print "    <SpectrumIdentification id=\"SI\" SpectrumIdentificationProtocol_ref=\"SIP\"  SpectrumIdentificationList_ref=\"SIL_1\" ";
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime($objResFile->getDate);
  printf "activityDate=\"%4d-%02d-%02dT%02d:%02d:%02d\">\n", $year+1900,$mon+1,$mday,$hour,$min,$sec;
  print "      <InputSpectra SpectraData_ref=\"SD_1\"/>\n";
  for (my $i=1; $i <= $objParams->getNumberOfDatabases; $i++) {
    print "      <SearchDatabase SearchDatabase_ref=\"SDB_" . &noXmlTag($objParams->getDB($i)) . "\"/>\n";
  }
  print "    </SpectrumIdentification>\n";
  
  # Protein determination is performed 'now'
  print "    <ProteinDetection id=\"PD_1\" ProteinDetectionProtocol_ref=\"PDP_MascotParser_1\" ProteinDetectionList_ref=\"PDL_1\" ";
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
  printf "activityDate=\"%4d-%02d-%02dT%02d:%02d:%02d\">\n", $year+1900,$mon+1,$mday,$hour,$min,$sec;
  print "      <InputSpectrumIdentifications SpectrumIdentificationList_ref=\"SIL_1\"/>\n";
  print "    </ProteinDetection>\n";
  print "  </AnalysisCollection>\n";

  print "  <AnalysisProtocolCollection>\n";
  

  print "    <SpectrumIdentificationProtocol id=\"SIP\" AnalysisSoftware_ref=\"AS_mascot_server\">\n";

  print "      <SearchType>\n";
  if ($objResFile->anyMSMS) {
    print "        <cvParam accession=\"MS:1001083\" name=\"ms-ms search\" cvRef=\"PSI-MS\" value=\"\"/>\n";
  } elsif ($objResFile->anySQ || $objResFile->anyTag) {
    print "        <cvParam accession=\"MS:1001082\" name=\"tag search\" cvRef=\"PSI-MS\" value=\"\"/>\n";
  } else {
    print "        <cvParam accession=\"MS:1001081\" name=\"pmf search\" cvRef=\"PSI-MS\" value=\"\"/>\n";
  }
  print "      </SearchType>\n";

  print "      <AdditionalSearchParams>\n";
  if ($objParams->getCOM) {
    print "        <userParam name=\"Mascot User Comment\" value=\"" . &noXmlTag($objParams->getCOM) . "\"/>\n";
  }
  if ($objParams->getINSTRUMENT) {
    print "        <userParam name=\"Mascot Instrument Name\" value=\"" . &noXmlTag($objParams->getINSTRUMENT)  . "\"/>\n";
  }
  
  if ($objParams->getACCESSION) {
    print "        <cvParam accession=\"MS:1001021\" name=\"DB filter on accession numbers\" cvRef=\"PSI-MS\" value=\"" . &noXmlTag($objParams->getACCESSION) . "\"/>\n";
  }
  if (lc($objParams->getMASS) eq "monoisotopic") {
    print "        <cvParam accession=\"MS:1001211\" name=\"parent mass type mono\"    cvRef=\"PSI-MS\"/>\n";
  } else {
    print "        <cvParam accession=\"MS:1001212\" name=\"parent mass type average\" cvRef=\"PSI-MS\"/>\n";
  }
  if ($objResFile->anyMSMS || $objResFile->anySQ || $objResFile->anyTag) {
    my @rules_list = split(/,/, $objParams->getRULES);
    foreach my $ruleNum (@rules_list) {
      my ($cvName, $cvID);
      if ($ruleNum == 1) {
        # $cvName="singly charged";
      } elsif ($ruleNum ==  2) {
        # $cvName="doubly charged if precursor 2+ or higher (not internal or immonium)";
      } elsif ($ruleNum ==  3) {
        # $cvName="doubly charged if precursor 3+ or higher (not internal or immonium)";
      } elsif ($ruleNum ==  4) {
        #$ruleStr="immonium";
        $cvName = "param: immonium ion";
        $cvID   = "MS:1001259";
      } elsif ($ruleNum ==  5) {
        # $ruleStr="a series";
        $cvName = "param: a ion";
        $cvID   = "MS:1001108";
      } elsif ($ruleNum ==  6) {
        $cvName = "param: a ion-NH3";
        $cvID   = "MS:1001146";
      } elsif ($ruleNum ==  7) {
        $cvName = "param: a ion-H2O";
        $cvID   = "MS:1001148";
      } elsif ($ruleNum ==  8) {
        # $ruleStr="b series";
        $cvName = "param: b ion";
        $cvID   = "MS:1001118";
      } elsif ($ruleNum ==  9) {
        # $ruleStr="
        $cvName = "param: b ion-NH3";
        $cvID   = "MS:1001149";
      } elsif ($ruleNum == 10) {
        $cvName = "param: b ion-H2O";
        $cvID   = "MS:1001150";
      } elsif ($ruleNum == 11) {
        # $ruleStr="c series";
        $cvName = "param: c ion";
        $cvID   = "MS:1001119";
      } elsif ($ruleNum == 12) {
        # $ruleStr="x series";
        $cvName = "param: x ion";
        $cvID   = "MS:1001261";
      } elsif ($ruleNum == 13) {
        # $ruleStr="y series";
        $cvName = "param: y ion";
        $cvID   = "MS:1001262";
      } elsif ($ruleNum == 14) {
        $cvName = "param: y ion-NH3";
        $cvID   = "MS:1001151";
      } elsif ($ruleNum == 15) {
        $cvName = "param: y ion-H2O";
        $cvID   = "MS:1001152";
      } elsif ($ruleNum == 16) {
        $cvName = "param: z ion";
        $cvID   = "MS:1001263";
      } elsif ($ruleNum == 17) {
        $cvName = "param: internal yb ion";
        $cvID   = "MS:1001406";
      } elsif ($ruleNum == 18) {
        $cvName = "param: internal ya ion";
        $cvID   = "MS:1001407";
      } elsif ($ruleNum == 19) {
        # $ruleStr="y or y++ must be significant";
        $cvName = "";
        $cvID   = "";
      } elsif ($ruleNum == 20) {
        # $ruleStr="y or y++ must be highest scoring series";
        $cvName = "";
        $cvID   = "";
      } elsif ($ruleNum == 21) {
        $cvName = "param: z+1 ion";
        $cvID   = "MS:1001408";
      } elsif ($ruleNum == 22) {
        # $ruleStr="d and d' series";
        $cvName = "param: d ion";
        $cvID   = "MS:1001258";
      } elsif ($ruleNum == 23) {
        # $ruleStr="v series";
        $cvName = "param: v ion";
        $cvID   = "MS:1001257";
      } elsif ($ruleNum == 24) {
        # $ruleStr="w and w' series";
        $cvName = "param: w ion";
        $cvID   = "MS:1001260";
      } elsif ($ruleNum == 25) {
        # $ruleStr="z+2 series";
        $cvName = "param: z+2 ion";
        $cvID   = "MS:1001409";
      }
      if ($cvID && $cvName) {
        print "        <cvParam accession=\"" . $cvID . "\" name=\"" . &noXmlTag($cvName) . "\" cvRef=\"PSI-MS\"/>\n";
      }
    }
  }
  print "      </AdditionalSearchParams>\n";
  
  my $fixed_mods = $objParams->getMODS();
  if ($objQuantMethod) {
    # add in any fixed mods specified in the quant method
    my $qMods = &quant_subs::getQuantFixedModsAsString($objQuantMethod);
    if ($qMods && $fixed_mods) {
      $fixed_mods .= "," . $qMods;
    } elsif ($qMods) {
      $fixed_mods = $qMods;
    }
  }

  my $variable_mods = $objParams->getIT_MODS();
  if ($objQuantMethod) {
    # add in any variable or exclusive mods specified in the quant method
    my $qMods = &quant_subs::getQuantVariableModsAsString($objQuantMethod);
    if ($qMods && $variable_mods) {
      $variable_mods .= "," . $qMods;
    } elsif ($qMods) {
      $variable_mods = $qMods;
    }
  }

  if ($fixed_mods || $variable_mods) {
    print "      <ModificationParams>\n";
    if ($fixed_mods) {
      my @mod_list = split(/,/, $fixed_mods);
      foreach (@mod_list) {
        mzIdentMLoutputMod($_, "true");
      }
    }
    if ($variable_mods) {
      my @mod_list = split(/,/, $variable_mods);
      foreach (@mod_list) {
        mzIdentMLoutputMod($_, "false");
      }
    }
    print "      </ModificationParams>\n";
  }
  
  
# create an enzymes file object
  my $objEnzymesFile = new msparser::ms_enzymefile;
  if ($objResFile->getEnzyme($objEnzymesFile, "../config/enzymes")) {
    my $enzyme = $objEnzymesFile->getEnzymeByNumber(0);
    if ($enzyme->isValid) {
      print "      <Enzymes";
      if ($enzyme->getNumberOfCutters > 1) {
        print " independent=\"";
        if ($enzyme->isIndependent) {
          print "1\"";
        } else {
          print "0\"";
        }
      }
      print ">\n";
      for (my $i=0; $i < $enzyme->getNumberOfCutters; $i++) {
        my $cTermGain = $objParams->getOxygenMass + $objParams->getHydrogenMass;
        my $nTermGain = $objParams->getHydrogenMass;          
        print "        <Enzyme id=\"ENZ_" . $i 
            . "\" CTermGain=\"" . "OH" . "\" NTermGain=\"" . "H"
            . "\" missedCleavages=\"" . $objParams->getPFA . "\" semiSpecific=\"";
        if ($enzyme->isSemiSpecific) {
          print "1";
        } else {
          print "0";
        }
        print "\">\n";
        print "          <SiteRegexp>";
        print "<![CDATA[";
        if (length($enzyme->getCleave($i)) == 1) {
          print "(?<=" . $enzyme->getCleave($i) . ")";
        } elsif (length($enzyme->getCleave($i)) > 1) {
          print "(?<=[" . $enzyme->getCleave($i) . "])";
        }
        if (length($enzyme->getRestrict($i)) == 1) {
          print "(?!" . $enzyme->getRestrict($i) . ")";
        } elsif (length($enzyme->getRestrict($i)) > 1) {
          print "(?![" . $enzyme->getRestrict($i) . "])";
        }
        print "]]>";
        
      # sort multi-residue strings to simplify comparison
        my($cleaver, $restrictor, @tmpRes);
        if (length($enzyme->getCleave($i)) > 1) {
          @tmpRes = split(//, lc($enzyme->getCleave($i)));
          @tmpRes = sort { $a cmp $b } @tmpRes;
          $cleaver = join("", @tmpRes)
        } else {
          $cleaver = lc($enzyme->getCleave($i));
        }
        if (length($enzyme->getRestrict($i)) > 1) {
          @tmpRes = split(//, lc($enzyme->getRestrict($i)));
          @tmpRes = sort { $a cmp $b } @tmpRes;
          $restrictor = join("", @tmpRes)
        } else {
          $restrictor = lc($enzyme->getRestrict($i));
        }
        
        print "</SiteRegexp>\n";
        print "          <EnzymeName>\n";
        if (lc($enzyme->getTitle) eq "none") {
          print "            <cvParam accession=\"MS:1001091\" name=\"NoEnzyme\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "kr" && $restrictor eq "p" && lc($enzyme->getTitle) eq "trypsin") {
          print "            <cvParam accession=\"MS:1001251\" name=\"Trypsin\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "r" && $restrictor eq "p" && lc($enzyme->getTitle) eq "arg-c") {
          print "            <cvParam accession=\"MS:1001303\" name=\"Arg-C\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "bd" && !$restrictor && lc($enzyme->getTitle) eq "asp-n") {
          print "            <cvParam accession=\"MS:1001304\" name=\"Asp-N\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "de" && !$restrictor && lc($enzyme->getTitle) eq "asp-n_ambic") {
          print "            <cvParam accession=\"MS:1001305\" name=\"Asp-N_ambic\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "flwy" && $restrictor eq "p" && lc($enzyme->getTitle) eq "chymotrypsin") {
          print "            <cvParam accession=\"MS:1001306\" name=\"Chymotrypsin\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "m" && !$restrictor && lc($enzyme->getTitle) eq "cnbr") {
          print "            <cvParam accession=\"MS:1001307\" name=\"CNBr\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "d" && !$restrictor && lc($enzyme->getTitle) eq "formic_acid") {
          print "            <cvParam accession=\"MS:1001308\" name=\"Formic_acid\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "k" && $restrictor eq "p" && lc($enzyme->getTitle) eq "lys-c") {
          print "            <cvParam accession=\"MS:1001309\" name=\"Lys-C\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "k" && !$restrictor && lc($enzyme->getTitle) eq "lys-c/p") {
          print "            <cvParam accession=\"MS:1001310\" name=\"Lys-C/P\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "fl" && !$restrictor && lc($enzyme->getTitle) eq "pepsina") {
          print "            <cvParam accession=\"MS:1001311\" name=\"PepsinA\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "fklrwy" && $restrictor eq "p" && lc($enzyme->getTitle) eq "trypchymo") {
          print "            <cvParam accession=\"MS:1001312\" name=\"TrypChymo\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "kr" && !$restrictor && lc($enzyme->getTitle) eq "trypsin/p") {
          print "            <cvParam accession=\"MS:1001313\" name=\"Trypsin/P\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "bdez" && $restrictor eq "p" && lc($enzyme->getTitle) eq "v8-de") {
          print "            <cvParam accession=\"MS:1001314\" name=\"V8-DE\" cvRef=\"PSI-MS\" />\n";
        } elsif ($cleaver eq "ez" && $restrictor eq "p" && lc($enzyme->getTitle) eq "v8-e") {
          print "            <cvParam accession=\"MS:1001315\" name=\"V8-E\" cvRef=\"PSI-MS\" />\n";
        } else {
          print "            <userParam name=\"Enzyme\" value=\"" . &noXmlTag($enzyme->getTitle) . "\"/>\n";
        }
        print "          </EnzymeName>\n";
        print "        </Enzyme>\n";
      }
      print "      </Enzymes>\n";
    }
  }

  my $multiMassTables = 1;
  if ($numcomponents > 1) {
    for ($c=0; $c < $numcomponents; $c++) { 
      my $component = $objQuantMethod->getComponentByNumber($c);
      if ($component->getNumberOfIsotopes > 0) {
        $multiMassTables = $numcomponents;
        last;
      }
    }
  }
  
  for ($c=0; $c < $multiMassTables; $c++) {
    my $objLocalMassesFile = new msparser::ms_masses($objMassesFile); 
    if ($multiMassTables > 1) {
      $objLocalMassesFile->applyIsotopes($objUmodConfigFile, $objQuantMethod->getComponentByNumber($c));
      print "      <MassTable id=\"MT_" . &noXmlTag($objQuantMethod->getComponentByNumber($c)->getName) . "\"";
    } else {
      print "      <MassTable id=\"MT\"";
    }
    my $err = new msparser::ms_errs;
  #  my $dummy = $objLocalMassesFile->applyFixedMods($vecFixed, $err);  # decided MassTable should be completely unmodified
    unless ($err->isValid) {
      my $errorList = "Mascot Parser error(s):<BR>\n";
      for (my $i = 1; $i <= $err->getNumberOfErrors(); $i++) {
        $errorList .= $err->getErrorNumber($i) 
          . ": " . $err->getErrorString($i) . "<BR>\n";
      }
      die($errorList, " ", $fileIn);
    }
    print " msLevel=\"1 2\">\n";
    for (my $residue = 'A'; $residue ne 'Z'; $residue++) {
      my $mass = $objLocalMassesFile->getResidueMass($mass_type, $residue);
      if ($residue ne 'B' && $residue ne 'X' && $residue ne 'Z' && $mass != 0) {
        print "        <Residue Code=\"" . $residue . "\" Mass=\"" . $mass . "\"/>\n";
      }
    }
    print "        <AmbiguousResidue Code=\"B\">\n";
    print "          <cvParam accession=\"MS:1001360\" name=\"alternate single letter codes\" cvRef=\"PSI-MS\" value=\"D N\"/>\n";
    print "        </AmbiguousResidue>\n";
    print "        <AmbiguousResidue Code=\"Z\">\n";
    print "          <cvParam accession=\"MS:1001360\" name=\"alternate single letter codes\" cvRef=\"PSI-MS\" value=\"E Q\"/>\n";
    print "        </AmbiguousResidue>\n";
    print "        <AmbiguousResidue Code=\"X\">\n";
    print "          <cvParam accession=\"MS:1001360\" name=\"alternate single letter codes\" cvRef=\"PSI-MS\" value=\"A C D E F G H I K L M N O P Q R S T U V W Y\"/>\n";
    print "        </AmbiguousResidue>\n";
    print "      </MassTable>\n";
  }
  
  
  if (!$objResFile->isPMF) {
    print "      <FragmentTolerance>\n";
    if ($objParams->getITOLU eq "Da") {
      print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objParams->getITOL . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
      print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objParams->getITOL . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
    } elsif ($objParams->getITOLU eq "mmu") {
      print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objParams->getITOL / 1000 . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
      print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objParams->getITOL / 1000 . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
    }
    print "      </FragmentTolerance>\n";
  }
  print "      <ParentTolerance>\n";
  if ($objParams->getTOLU eq "Da") {
    print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objParams->getTOL . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
    print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objParams->getTOL . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
  } elsif ($objParams->getTOLU eq "mmu") {
    print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objParams->getTOL / 1000 . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
    print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objParams->getTOL / 1000 . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
  } elsif ($objParams->getTOLU eq "%") {
    print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objParams->getTOL . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000187\" unitName=\"percent\" unitCvRef=\"UO\" />\n";
    print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objParams->getTOL . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000187\" unitName=\"percent\" unitCvRef=\"UO\" />\n";
  } elsif ($objParams->getTOLU eq "ppm") {
    print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objParams->getTOL . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000169\" unitName=\"parts per million\" unitCvRef=\"UO\" />\n";
    print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objParams->getTOL . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000169\" unitName=\"parts per million\" unitCvRef=\"UO\" />\n";
  }
  print "      </ParentTolerance>\n";
  
  print "      <Threshold>\n";
  if ($objResFile->isPMF) {
    print "        <cvParam accession=\"MS:1001494\" name=\"no threshold\" cvRef=\"PSI-MS\" />\n";
  } else {
    print "        <cvParam accession=\"MS:1001316\" name=\"mascot:SigThreshold\" cvRef=\"PSI-MS\" value=\"" . $sigThreshold . "\"/>\n";
  }
  print "      </Threshold>\n";

  print "      <DatabaseFilters>\n";
  print "        <Filter>\n";
  print "          <FilterType>\n";
  print "            <cvParam accession=\"MS:1001020\" name=\"DB filter taxonomy\" cvRef=\"PSI-MS\" />\n";
  print "          </FilterType>\n";

  my $taxonomy = new msparser::ms_taxonomyfile;
  if ($objResFile->getTaxonomy($taxonomy)) {
    if ($taxonomy->getNumberOfEntries == 0 ) {
      print "          <Include>\n";
      print "            <cvParam accession=\"MS:1001467\" name=\"taxonomy: NCBI TaxID\" cvRef=\"PSI-MS\" value=\"1\"/>\n";

      print "          </Include>\n";
    } else {
      my $choice = $taxonomy->getEntryByNumber(0);
      if ($choice->getNumberOfIncludeTaxonomies > 0) {
        print "          <Include>\n";
        for (my $i=0; $i < $choice->getNumberOfIncludeTaxonomies; $i++) {
          print "            <cvParam accession=\"MS:1001467\" name=\"taxonomy: NCBI TaxID\" cvRef=\"PSI-MS\" value=\"" . $choice->getIncludeTaxonomy($i) . "\"/>\n";
          if ($thisScript->param($urlParams{'prot_tax_str'})) {
            my $tax_title = &getTaxonomyNameFromId($choice->getIncludeTaxonomy($i), \%taxNames);
            if ($tax_title) {
              print "            <cvParam accession=\"MS:1001469\" name=\"taxonomy: scientific name\" cvRef=\"PSI-MS\" value=\"" . &noXmlTag($tax_title) . "\"/>\n";
            }
          }
        }
        print "          </Include>\n";
      }
    
      $choice = $taxonomy->getEntryByNumber(0);
      if ($choice->getNumberOfExcludeTaxonomies > 0) {
        print "          <Exclude>\n";
        for (my $i=0; $i < $choice->getNumberOfExcludeTaxonomies; $i++) {
          print "            <cvParam accession=\"MS:1001467\" name=\"taxonomy: NCBI TaxID\" cvRef=\"PSI-MS\" value=\"". $choice->getExcludeTaxonomy($i) . "\"/>\n";
          if ($thisScript->param($urlParams{'prot_tax_str'})) {
            my $tax_title = &getTaxonomyNameFromId($choice->getExcludeTaxonomy($i), \%taxNames);
            if ($tax_title) {
              print "            <cvParam accession=\"MS:1001469\" name=\"taxonomy: scientific name\" cvRef=\"PSI-MS\" value=\"" . &noXmlTag($tax_title) . "\"/>\n";
            }
          }
        }
        print "          </Exclude>\n";
      }
    }
  }
  print "        </Filter>\n";
  print "      </DatabaseFilters>\n";

  if ($objSummary->isNA) {
    print "      <DatabaseTranslation frames=\"1 2 3 -1 -2 -3\">\n";
    open(TEMPFILE, "../taxonomy/gencode.dmp") 
    || &fatal("Cannot open gencode.dmp", __LINE__, __FILE__, "");
    my @gencode = <TEMPFILE>;
    close(TEMPFILE)  || &fatal("Cannot close gencode.dmp", __LINE__, __FILE__, "");
    foreach my $gencode(@gencode) {
      my ($id, $dummy, $name, $table, $startcodons) = split(/\s*\|\s*/, $gencode);
      if ($table && $startcodons) {
        print "        <TranslationTable id=\"TT_" . $id . "\" name=\"" . $name . "\">\n";
        print "          <cvParam accession=\"MS:1001025\" name=\"translation table\" cvRef=\"PSI-MS\" value=\"" . $table . "\" />\n";
        print "          <cvParam accession=\"MS:1001410\" name=\"translation start codons\" cvRef=\"PSI-MS\" value=\"" . $startcodons . "\" />\n";
        print "          <cvParam accession=\"MS:1001423\" name=\"translation table description\" cvRef=\"PSI-MS\" value=\"http://www.ncbi.nlm.nih.gov/Taxonomy/taxonomyhome.html/index.cgi?chapter=cgencodes#SG" . $id . "\" />\n";
        print "        </TranslationTable>\n";
      }
    }
    print "      </DatabaseTranslation>\n";
  }
 print "    </SpectrumIdentificationProtocol>\n";

  my $scoringType;
  if ($objResFile->getNumQueries() / $objResFile->getNumSeqsAfterTax() > $mudpitSwitch){
    $scoringType = "MudPIT";
  } else {
    $scoringType = "Standard";
  }
  my $showSameSets = $thisScript->param($urlParams{'show_same_sets'}) + 0;
  my $maxProteinHits = $numHits;
  if ($maxProteinHits == 0) {
    $maxProteinHits = "Auto";
  }
  my $useUnigene = "true";
  if ($UniGeneFile eq "") {
    $useUnigene = "false";
  }
  print "    <ProteinDetectionProtocol id=\"PDP_MascotParser_1\"  AnalysisSoftware_ref=\"AS_mascot_parser\">\n";
  print "      <AnalysisParams>\n";
  print "        <cvParam accession=\"MS:1001316\" name=\"mascot:SigThreshold\"                               cvRef=\"PSI-MS\" value=\"" . $sigThreshold         . "\"/>\n";
  print "        <cvParam accession=\"MS:1001317\" name=\"mascot:MaxProteinHits\"                             cvRef=\"PSI-MS\" value=\"" . $maxProteinHits       . "\"/>\n";
  unless ($objResFile->isPMF) {  
    print "        <cvParam accession=\"MS:1001318\" name=\"mascot:ProteinScoringMethod\"                       cvRef=\"PSI-MS\" value=\"" . $scoringType          . "\"/>\n";
    print "        <cvParam accession=\"MS:1001319\" name=\"mascot:MinMSMSThreshold\"                           cvRef=\"PSI-MS\" value=\"" . $ignoreIonsScoreBelow . "\"/>\n";
  }
  print "        <cvParam accession=\"MS:1001320\" name=\"mascot:ShowHomologousProteinsWithSamePeptides\"     cvRef=\"PSI-MS\" value=\"" . $showSameSets         . "\"/>\n";
  print "        <cvParam accession=\"MS:1001321\" name=\"mascot:ShowHomologousProteinsWithSubsetOfPeptides\" cvRef=\"PSI-MS\" value=\"" . $ShowSubSets          . "\"/>\n";
  unless ($objResFile->isPMF) {  
    print "        <cvParam accession=\"MS:1001322\" name=\"mascot:RequireBoldRed\"                             cvRef=\"PSI-MS\" value=\"" . $RequireBoldRed       . "\"/>\n";
    print "        <cvParam accession=\"MS:1001323\" name=\"mascot:UseUnigeneClustering\"                       cvRef=\"PSI-MS\" value=\"" . $useUnigene           . "\"/>\n";
    print "        <cvParam accession=\"MS:1001324\" name=\"mascot:IncludeErrorTolerantMatches\"                cvRef=\"PSI-MS\" value=\"" . !$NoErrorTolerant     . "\"/>\n";
  }
  print "        <cvParam accession=\"MS:1001325\" name=\"mascot:ShowDecoyMatches\"                           cvRef=\"PSI-MS\" value=\"" . $ShowDecoyReport      . "\"/>\n";
  print "      </AnalysisParams>\n";
  
  print "      <Threshold>\n";
  if ($objResFile->isPMF) {
    print "        <cvParam accession=\"MS:1001316\" name=\"mascot:SigThreshold\" cvRef=\"PSI-MS\" value=\"" . $sigThreshold . "\"/>\n";
  } else {
    print "        <cvParam accession=\"MS:1001494\" name=\"no threshold\" cvRef=\"PSI-MS\" />\n";
  }
  print "      </Threshold>\n";
  
  print "    </ProteinDetectionProtocol>\n";
  print "  </AnalysisProtocolCollection>\n";
  
  print "  <DataCollection>\n";
  print "    <Inputs>\n";

  print "      <SourceFile location=\"file:///" . &noXmlTag($fileIn) . "\" id=\"SF_1\" >\n";
  print "        <fileFormat>\n";
  print "          <cvParam accession=\"MS:1001199\" name=\"Mascot DAT file\" cvRef=\"PSI-MS\" />\n";
  print "        </fileFormat>\n";
  print "      </SourceFile>\n";

  for (my $i=1; $i <= $objParams->getNumberOfDatabases; $i++) {

    print "      <SearchDatabase location=\"file:///" . &noXmlTag($objResFile->getFastaPath($i))
                 . "\" id=\"SDB_" . &noXmlTag($objParams->getDB($i)) 
                 . "\" name=\"" . &noXmlTag($objParams->getDB($i)) 
                 . "\" numDatabaseSequences=\"" . $objResFile->getNumSeqs    # wait for parser function ### debug ###
                 . "\" numResidues=\""          . $objResFile->getNumResidues
                 . "\" releaseDate=\""          . $objResFile->getFastaVer($i)
                 . "\" version=\""              . $objResFile->getFastaVer($i)
                 . "\">\n";
    print "        <fileFormat>\n";
    print "          <cvParam accession=\"MS:1001348\" name=\"FASTA format\" cvRef=\"PSI-MS\" />\n";
    print "        </fileFormat>\n";
    print "        <DatabaseName>\n";
    print "          <userParam name=\"" . $objResFile->getFastaVer($i) . "\" />\n";
    print "        </DatabaseName>\n";
    
    if ($objSummary->isNA) {
      print "        <cvParam accession=\"MS:1001079\" name=\"database type nucleotide\" cvRef=\"PSI-MS\" />\n";
    } else {
      print "        <cvParam accession=\"MS:1001073\" name=\"database type amino acid\" cvRef=\"PSI-MS\" />\n";
    }
    
  #  if ($objResFile->getFastaPath($i)) {
  #   print "        <cvParam accession=\"MS:1001014\" name=\"database local file path\" cvRef=\"PSI-MS\" value=\"" . &noXmlTag($objResFile->getFastaPath($i)) . "\"/>\n";
  #  }
    
    print "      </SearchDatabase>\n";
  }

  my $filename = $objParams->getFILENAME();
  $filename =~ s/\\/\//g; 
  
  my $indexIsQueryNumber = 1;
  my $objQueryTmp = new msparser::ms_inputquery($objResFile, 1);
  if ($objQueryTmp->getIndex > -1) {
    $indexIsQueryNumber = 0;
  }

  print "      <SpectraData location=\"file:///" . &noXmlTag($filename) . "\" id=\"SD_1\">\n";
  print "        <fileFormat>\n";
  if ($objParams->getFORMAT eq "Mascot generic") {
    print "          <cvParam accession=\"MS:1001062\" name=\"Mascot MGF file\" cvRef=\"PSI-MS\" />\n";
  } elsif ($objParams->getFORMAT eq "Sequest (.DTA)") {
    print "          <cvParam accession=\"MS:1000613\" name=\"DTA file\" cvRef=\"PSI-MS\" />\n";
  } elsif ($objParams->getFORMAT eq "Finnigan (.ASC)") {
    print "          <cvParam accession=\"PI:99999\" name=\"TODO: Finnigan List file\" cvRef=\"MASCOT:PSI:PI\" />\n";   # not worth worrying about
  } elsif ($objParams->getFORMAT eq "Micromass (.PKL)") {
    print "          <cvParam accession=\"MS:1000565\" name=\"Micromass PKL file\" cvRef=\"PSI-MS\" />\n";
  } elsif ($objParams->getFORMAT eq "PerSeptive (.PKS)") {
    print "          <cvParam accession=\"MS:1001245\" name=\"PerSeptive PKS file\" cvRef=\"PSI-MS\" />\n";
  } elsif ($objParams->getFORMAT eq "Sciex API III") {
    print "          <cvParam accession=\"MS:1001246\" name=\"Sciex API III file\" cvRef=\"PSI-MS\" />\n";
  } elsif ($objParams->getFORMAT eq "Bruker (.XML)") {
    print "          <cvParam accession=\"MS:1001247\" name=\"Bruker XML file\" cvRef=\"PSI-MS\" />\n";
  } elsif ($objParams->getFORMAT eq "mzData (.XML)") {
    print "          <cvParam accession=\"MS:1000564\" name=\"PSI mzData file\" cvRef=\"PSI-MS\" />\n";
    $indexIsQueryNumber = 0;
  } elsif ($objParams->getFORMAT eq "mzML (.mzML)") {
    print "          <cvParam accession=\"MS:1000584\" name=\"mzML file\" cvRef=\"PSI-MS\" />\n";
    $indexIsQueryNumber = 0;
  } elsif ($objResFile->isPMF || $objResFile->isSQ) {
    print "          <cvParam accession=\"MS:1001369\" name=\"text file\" cvRef=\"PSI-MS\" />\n";
  }
  print "        </fileFormat>\n";
  print "        <spectrumIDFormat>\n";
  if ($objResFile->isPMF || $objResFile->isSQ) {
    print "          <cvParam accession=\"MS:1000775\" name=\"single peak list nativeID format\" cvRef=\"PSI-MS\" />\n";
  } elsif ($indexIsQueryNumber) {
    print "          <cvParam accession=\"MS:1001528\" name=\"Mascot query number\" cvRef=\"PSI-MS\" />\n";
  } elsif ($objParams->getFORMAT eq "mzML (.mzML)") {
    print "          <cvParam accession=\"MS:1001530\" name=\"mzML unique identifier\" cvRef=\"PSI-MS\" />\n";
  } elsif ($objParams->getFORMAT eq "mzData (.XML)") {
    print "          <cvParam accession=\"MS:1000777\" name=\"spectrum identifier nativeID format\" cvRef=\"PSI-MS\" />\n";
  } else {
    print "          <cvParam accession=\"MS:1000774\" name=\"multiple peak list nativeID format\" cvRef=\"PSI-MS\" />\n";
  }
  print "        </spectrumIDFormat>\n";  
  print "      </SpectraData>\n";
  print "    </Inputs>\n";

  print "    <AnalysisData>\n";

  print "      <SpectrumIdentificationList id=\"SIL_1\""
               . " numSequencesSearched=\"" . $objResFile->getNumSeqsAfterTax
               . "\">\n"; # . $componentNames[$c] . "\">\n";


  # Now output all peptide scores matches
  # For PMF, there's just one spectrum, so just one SpectrumIdentificationResult
  if ($objResFile->isPMF) {
    print "        <SpectrumIdentificationResult id=\"SIR_1\" spectrumID=\"file=" . $filename . "\" SpectraData_ref=\"SD_1\">\n";
  } 
  
  if (!$objResFile->isPMF) {
    print "        <FragmentationTable>\n";
    print "          <Measure id=\"m_mz\">\n";
    print "            <cvParam cvRef=\"PSI-MS\" accession=\"MS:1001225\" name=\"product ion m/z\"/>\n";
    print "          </Measure>\n";
    print "          <Measure id=\"m_intensity\">\n";
    print "            <cvParam cvRef=\"PSI-MS\" accession=\"MS:1001226\" name=\"product ion intensity\"/>\n";
    print "          </Measure>\n";
    print "          <Measure id=\"m_error\">\n";
    print "            <cvParam cvRef=\"PSI-MS\" accession=\"MS:1001227\" name=\"product ion m/z error\" unitAccession=\"MS:1000040\" unitName=\"m/z\" unitCvRef=\"PSI-MS\"/>\n";
    print "          </Measure>\n";
    print "        </FragmentationTable>\n";
  }

  for ($query = 1; $query <= $objResFile->getNumQueries(); $query++) {
    if ($thisScript->param($urlParams{'query_all'}) || $queryList[$query] || $objResFile->isPMF()) {

      my $objQuery   = new msparser::ms_inputquery($objResFile, $query);
      
      # Try scanID first - for an mzML file, this will be the unique id of the spectrum.
      my $scanID;
      if ($indexIsQueryNumber) {
          $scanID = "query=" . $query;
      } elsif ($objParams->getFORMAT eq "mzML (.mzML)") {
        $scanID = $objQuery->getStringTitle(1);
        $scanID =~ s/^nativeID=//;
        $scanID = "mzMLid=" . $scanID;
      } elsif ($objParams->getFORMAT eq "mzData (.XML)") {
        $scanID = "spectrum=" . $objQuery->getScanNumbers;
      } else {
        $scanID = "index=" . $objQuery->getIndex;
      }
      
      my $haveOutputSIRelement = 0;
      my ($identityThreshold,  $homologyThreshold, $thisThreshold);
      if (!$objResFile->isPMF) {
        $identityThreshold = $objSummary->getPeptideIdentityThreshold($query, 1 / $sigThreshold);
        $homologyThreshold = $objSummary->getHomologyThreshold($query, 1 / $sigThreshold, $rank);
        if ($homologyThreshold > 0) {
          $thisThreshold = $homologyThreshold;
        } else {
          $thisThreshold = $identityThreshold;
        }
      }
      
      for ($rank = 1; $rank <= $objSummary->getMaxRankValue(); $rank++) {
        my $objpeptide = $objSummary->getPeptide($query, $rank);
        my $pepstr     = $objpeptide->getPeptideStr;
        if ($pepstr ne "") { # && ($numcomponents == 1 || $objpeptide->getComponentStr eq $componentNames[$c])) 
          if (!$objResFile->isPMF && !$haveOutputSIRelement) {
            print "        <SpectrumIdentificationResult id=\"SIR_" . $query
                . "\" spectrumID=\"" . $scanID . "\" SpectraData_ref=\"SD_1\">\n";
            $haveOutputSIRelement = 1;
          }
          
          if ($objpeptide->getCharge > 0) {
            $masses{'charge'} = $masses{'hydrogen'} - $masses{'electron'};
          } else {
            $masses{'charge'} = - $masses{'hydrogen'} + $masses{'electron'};
          }
          my $calcMz = ($objpeptide->getMrCalc / abs($objpeptide->getCharge)) + $masses{'charge'};
        
          print "          <SpectrumIdentificationItem id=\"SII_" . $query . "_" . $rank 
              . "\"  calculatedMassToCharge=\"" . $calcMz 
              . "\" chargeState=\"" . $objpeptide->getCharge 
              . "\" experimentalMassToCharge=\"" . $objResFile->getObservedMass($query) 
              . "\" Peptide_ref=\"peptide_" . $query . "_" . $rank;
          if (!$objResFile->isPMF) {
            print "\" rank=\"" . $rank;
            if ($objpeptide->getIonsScore > $identityThreshold) {
              print "\" passThreshold=\"true";
            } else {
              print "\" passThreshold=\"false";
            }
          } else {
            print "\" rank=\"0";
            print "\" passThreshold=\"true";     # according to spec, if no threshold then set true(!)
          }
          if ($objpeptide->getComponentStr) {
            print "\" MassTable_ref=\"MT_" . &noXmlTag($objpeptide->getComponentStr);
            print "\" Sample_ref=\"Sample_" . &noXmlTag($objpeptide->getComponentStr);
          }
  
          print "\">\n";
  
  
          my $start = new msparser::vectori;
          my $end   = new msparser::vectori;
          my $pre   = new msparser::VectorString;
          my $post  = new msparser::VectorString;
          my $frame = new msparser::vectori;
          my $multiplicity = new msparser::vectori;
          my $db    = new msparser::vectori;
          my $accessions = $objSummary->getAllProteinsWithThisPepMatch($query, $rank, $start, $end, $pre, $post, $frame, $multiplicity, $db);
          my @arr = @ { $accessions };
          # print "Errors: " . $resfile->getLastErrorString() . "\n"; 
          my $gotEvidence = 0;   
          my $i = 0;
          while ($i < @arr) {
            if ($sequences{ $db->get($i) . "::" . $arr[$i] } == 1) {
              $gotEvidence = 1;
              my $preStr  = $pre->get($i);
              my $postStr = $post->get($i);
              if ($preStr eq '@') {
                $preStr = '-';
              }
              if ($postStr eq '@') {
                $postStr = '-';
              }
              print "            <PeptideEvidence id=\"PE_" . $query . "_" . $rank . "_" . $arr[$i] . "_" . $frame->get($i) . "_" . $start->get($i) . "_" . $end->get($i)
                . "\" start=\""              . $start->get($i)
                . "\" end=\""                . $end->get($i)
                . "\" pre=\""                . $preStr
                . "\" post=\""               . $postStr
                . "\" missedCleavages=\""    . $objpeptide->getMissedCleavages();
              
              if ($objSummary->isNA) {
                my $ttNum = 1;  # if unspecified, Mascot uses standard genetic code
                if ($thisScript->param($urlParams{'prot_tax_str'}) || $thisScript->param($urlParams{'prot_tax_id'})) {
                  my @getTax;
                  if (open SOCK, "../x-cgi/ms-gettaxonomy.exe 9 " . $objParams->getDB($db->get($i)) . " \"" . $arr[$i] . "\" |") { 
                    @getTax = <SOCK>;
                    close SOCK; 
                  }
                  if (@getTax && $#getTax > 1) {
                    $getTax[2] =~ /(\d+)/;
                    if ($1) {
                      $ttNum = $1;
                    }
                  }
                }
                print "\" TranslationTable_ref=\"TT_$ttNum";
                my $framenum = $frame->get($i);
                if ($framenum >= 1 && $framenum <=3) {
                  print "\" frame=\""   . $framenum;
                } else {
                  print "\" frame=\""   . ($framenum -7);  # 6 -> -1, 5 -> -2, 4 -> -3
                }
              }
              print "\" isDecoy=\"" . "false"
                . "\" DBSequence_Ref=\"DBSeq_" . $db->get($i) . "_" . &noXmlTag($arr[$i]) . "\" />\n";
            }
            $i++;
          }
          if (!$objResFile->isPMF()) {
            print "            <cvParam accession=\"MS:1001171\" name=\"mascot:score\" cvRef=\"PSI-MS\" value=\"" . $objpeptide->getIonsScore() . "\" />\n";
            unless ($objResFile->isErrorTolerant() && $objSummary->getPeptide($query, 1)->getIsFromErrorTolerant()) {
              print "            <cvParam accession=\"MS:1001172\" name=\"mascot:expectation value\" cvRef=\"PSI-MS\" value=\"" . $objSummary->getPeptideExpectationValue($objpeptide->getIonsScore(), $query) . "\" />\n";
            }
            if ($gotEvidence) {
              if ($objSummary->isPeptideUnique($query, $rank)) {
                print "            <cvParam accession=\"MS:1001363\" name=\"peptide unique to one protein\" cvRef=\"PSI-MS\" />\n";
              } else {
                print "            <cvParam accession=\"MS:1001175\" name=\"peptide shared in multiple proteins\" cvRef=\"PSI-MS\" />\n";
              }
            }
            if ($thisScript->param($urlParams{'query_raw'})) {
              if ($numcomponents > 1 && $objpeptide->getComponentStr) {
                &mzIdentMLfragmentation($query, $rank, $objpeptide, $aaHelpers{$objpeptide->getComponentStr});
              } else {
                &mzIdentMLfragmentation($query, $rank, $objpeptide, $aaHelpers{"1"});
              }
            }
          } else {
            # Nothing required or desired
          }
          print "          </SpectrumIdentificationItem>\n";
        }
      }
      if (!$objResFile->isPMF && $haveOutputSIRelement) {
        my $qmatch            = $objSummary->getQmatch($query);
        unless ($objResFile->isErrorTolerant() && $objSummary->getPeptide($query, 1)->getIsFromErrorTolerant()) {
          print "          <cvParam accession=\"MS:1001371\" name=\"mascot:identity threshold\"  cvRef=\"PSI-MS\" value=\"" . $identityThreshold . "\" />\n";
          if ($homologyThreshold > 0) {
            print "          <cvParam accession=\"MS:1001370\" name=\"mascot:homology threshold\"  cvRef=\"PSI-MS\" value=\"" . $homologyThreshold . "\" />\n";
          }
        }
        print "          <cvParam accession=\"MS:1001030\" name=\"number of peptide seqs compared to each spectrum\"  cvRef=\"PSI-MS\" value=\"" . $qmatch . "\" />\n";
        if ($objQuery->getScanNumbers) {
          print "          <cvParam accession=\"MS:1000797\" name=\"peak list scans\"  cvRef=\"PSI-MS\" value=\"" . $objQuery->getScanNumbers . "\" />\n";
        }
        if ($objQuery->getRetentionTimes) {
          print "          <cvParam accession=\"MS:1001114\" name=\"retention time(s)\"  cvRef=\"PSI-MS\" value=\"" . $objQuery->getRetentionTimes . "\" unitAccession=\"UO:0000010\" unitName=\"second\" unitCvRef=\"UO\" />\n";
        }
        if ($objQuery->getStringTitle(1)) {
          print "          <cvParam accession=\"MS:1000796\" name=\"spectrum title\"  cvRef=\"PSI-MS\" value=\"" . &noXmlTag($objQuery->getStringTitle(1)) . "\" />\n";
        }
        if ($objQuery->getPepTol && $objQuery->getPepTolUnits) {
          if ($objQuery->getPepTolUnits eq "Da") {
            print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objQuery->getPepTol . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
            print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objQuery->getPepTol . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
          } elsif ($objQuery->getPepTolUnits eq "mmu") {
            print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objQuery->getPepTol / 1000 . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
            print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objQuery->getPepTol / 1000 . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000221\" unitName=\"dalton\" unitCvRef=\"UO\" />\n";
          } elsif ($objQuery->getPepTolUnits eq "%") {
            print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objQuery->getPepTol . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000187\" unitName=\"percent\" unitCvRef=\"UO\" />\n";
            print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objQuery->getPepTol . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000187\" unitName=\"percent\" unitCvRef=\"UO\" />\n";
          } elsif ($objQuery->getPepTolUnits eq "ppm") {
            print "        <cvParam accession=\"MS:1001412\" name=\"search tolerance plus value\" value=\"" . $objQuery->getPepTol . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000169\" unitName=\"parts per million\" unitCvRef=\"UO\" />\n";
            print "        <cvParam accession=\"MS:1001413\" name=\"search tolerance minus value\" value=\"" . $objQuery->getPepTol . "\" cvRef=\"PSI-MS\" unitAccession=\"UO:0000169\" unitName=\"parts per million\" unitCvRef=\"UO\" />\n";
          }
        }
        for (my $j = 1; $j <= 20; $j++) {
          if ($objQuery->getSeq($j)) {
            print "            <userParam name=\"SEQ_$j\" value=\"" . $objQuery->getSeq($j) . "\"/>\n";
          } else {
            last;
          }
        }
        for (my $j = 1; $j <= 20; $j++) {
          if ($objQuery->getComp($j)) {
            print "            <userParam name=\"COMP_$j\" value=\"" . $objQuery->getComp($j) . "\"/>\n";
          } else {
            last;
          }
        }
        for (my $j = 1; $j <= 20; $j++) {
          if ($objQuery->getTag($j)) {
            $objQuery->getTag($j) =~ /([et]),(.*)/i;
            if (lc($1) eq "e") {
              print "            <userParam name=\"ETAG_$j\" value=\"" . $2 . "\"/>\n";
            } else {
              print "            <userParam name=\"TAG_$j\" value=\"" . $2 . "\"/>\n";
            }
          } else {
            last;
          }
        }
        if ($objQuery->getIT_MODS(1)) {
        # Need reference to query level mods, otherwise cannot fully understand results.
        # Structured information for mods in matched peptides will be found in 
        # /mzIdentML/SequenceCollection/Peptide/Modification
          print "            <userParam name=\"IT_MODS\" value=\"" . &noXmlTag($objQuery->getIT_MODS(1)) . "\"/>\n";
        }
        if ($objQuery->getINSTRUMENT(1)) {
          print "            <userParam name=\"INSTRUMENT\" value=\"" . &noXmlTag($objQuery->getINSTRUMENT(1)) . "\"/>\n";
        }
        if ($objQuery->getRULES()) {
          print "            <userParam name=\"RULES\" value=\"" . $objQuery->getRULES() . "\"/>\n";
        }
        print "        </SpectrumIdentificationResult>\n";
      }
    }
  }
  if ($objResFile->isPMF) {
    print "        </SpectrumIdentificationResult>\n";
  }
  print "      </SpectrumIdentificationList>\n";

  
  print "      <ProteinDetectionList id=\"PDL_1\">\n";
  for (my $i = 1; $i <= $objSummary->getNumberOfHits; $i++) {
    my $objProtein = $objSummary->getHit($i);
    unless ($objResFile->isPMF && $objProtein->isPMFMixture()) {
      print "        <ProteinAmbiguityGroup id=\"PAG_hit_" . $i . "\" >\n";
      &mzIdentMLProteinDetection($objProtein);
      
      my $j;
      if ($thisScript->param($urlParams{'show_same_sets'})) {
        $j = 1;
        while ($objProtein = $objSummary->getNextSimilarProtein($i, $j)) {
          &mzIdentMLProteinDetection($objProtein);
          $j++;
        }
      }
      $j = 1;
      while ($objProtein = $objSummary->getNextSubsetProtein($i, $j)) {
        &mzIdentMLProteinDetection($objProtein);
        $j++;
      }
      
      print "        </ProteinAmbiguityGroup>\n";
    }
  }
  print "      </ProteinDetectionList>\n";
  
  print "    </AnalysisData>\n";
  print "  </DataCollection>\n";
  
#  if ($objParams->getFILENAME eq "thermophilic_bacterium.txt") {
    print "  <BibliographicReference authors=\"David N. Perkins, Darryl J. C. Pappin, David M. Creasy, John S. Cottrell\"";
    print " editor=\"\" id=\"10.1002/(SICI)1522-2683(19991201)20:18&lt;3551::AID-ELPS3551&gt;3.0.CO;2-2\"";
    print " name=\"Probability-based protein identification by searching sequence databases using mass spectrometry data\"";
    print " issue=\"18\" pages=\"3551-3567\" publication=\"Electrophoresis\" volume=\"20\" year=\"1999\"";
    print " publisher=\"Wiley VCH\""; 
    print " title=\"Probability-based protein identification by searching sequence databases using mass spectrometry data\"";
    print "/>\n";
#  }

}


###############################################################################
# &mzIdentMLOutputProtein()
# output mzIdentML proteins
# 
###############################################################################
sub mzIdentMLOutputProtein {
  my ($dbIdx, $accession) = @_;

  print "    <DBSequence id=\"DBSeq_" . $dbIdx . "_" . &noXmlTag($accession) . "\" ";
  if ($thisScript->param($urlParams{'prot_len'})) {
    my $length = &getProteinLen($accession, $objSummary, $objParams, \%fastaLen, 0, $dbIdx); # best to use NA length? $objProtein->getFrame()
    if ($length) {
      print "length=\"" . $length . "\" ";
    }
  }
  print "SearchDatabase_ref=\"SDB_" . &noXmlTag($objParams->getDB($dbIdx)) . "\" accession=\""
                 . $accession . "\" ";
  print ">\n";


  if ($thisScript->param($urlParams{'prot_seq'}))  {
    my $seq = &mustGetProteinSeq($accession, 0, $dbIdx); # have to use NA because PI doesn't support anything other than [A-Z] and frame may be mixed
    if ($seq) {
        print "      <seq>" . $seq . "</seq>\n";
    }
  }
  if ($thisScript->param($urlParams{'prot_desc'}))  {
    my $description = &mustGetProteinDescription($accession, \%fastaTitles, $dbIdx);
    if ($description) {
        print "      <cvParam accession=\"MS:1001088\" name=\"protein description\" cvRef=\"PSI-MS\" value=\"" . &noXmlTag($description) . "\" />\n";
    }
  }
  
  if ($thisScript->param($urlParams{'prot_tax_str'}) || $thisScript->param($urlParams{'prot_tax_id'})) {
    my $db = $objParams->getDB($dbIdx);
    my @getTax;
    if (open SOCK, "../x-cgi/ms-gettaxonomy.exe 1 $db \"$accession\" |") { 
      @getTax = <SOCK>;
      close SOCK; 
    }
    my $accNum = "xxxxxxxx";
    my $species = "";
    my $taxID = "";
    if (@getTax && $#getTax > 1) {
      ($accNum, $taxID, $species) = (split(/\s+/, $getTax[2], 3));
      if ($accNum ne $accession) {
        $species = "";
        $taxID = "";
      }
    }
    if ($thisScript->param($urlParams{'prot_tax_str'}) && $species) {
      chomp $species;
      print "      <cvParam accession=\"MS:1001469\" name=\"taxonomy: scientific name\" cvRef=\"PSI-MS\" value=\"" . &noXmlTag($species) . "\"/>\n";
    }
    if ($thisScript->param($urlParams{'prot_tax_id'}) && $taxID) {
      print "      <cvParam accession=\"MS:1001467\" name=\"taxonomy: NCBI TaxID\" cvRef=\"PSI-MS\" value=\"" . $taxID . "\"/>\n";
    }
  }

  print "    </DBSequence>\n";
}

###############################################################################
# &mzIdentMLProteinDetection()
# output mzIdentML protein determination result
# 
###############################################################################
sub mzIdentMLProteinDetection() {
  my ($objProtein) = @_;
  my $pepnum;
  
  my $passThreshold = "true";
  if ($objResFile->isPMF && $objProtein->getScore < $objSummary->getProteinThreshold(1 / $sigThreshold)) { 
    $passThreshold = "false"
  }
  
  print "          <ProteinDetectionHypothesis id=\"PDH_" . &noXmlTag($objProtein->getAccession()) . "_" . $objProtein->getFrame() . "\" DBSequence_ref=\"DBSeq_" . $objProtein->getDB . "_" . &noXmlTag($objProtein->getAccession()) . "\"  passThreshold=\"" . $passThreshold . "\">\n";
  for ($pepnum=1; $pepnum <= $objProtein->getNumPeptides(); $pepnum++) {
    my $query     = $objProtein->getPeptideQuery($pepnum);
    my $rank      = $objProtein->getPeptideP($pepnum);
    my $startpos  = $objProtein->getPeptideStart($pepnum);
    my $endpos    = $objProtein->getPeptideEnd($pepnum);
    my $resbefore = $objProtein->getPeptideResidueBefore($pepnum);
    my $resafter  = $objProtein->getPeptideResidueAfter($pepnum);     
    print "            <PeptideHypothesis  PeptideEvidence_Ref=\"PE_" . $query . "_" . $rank . "_" 
      . &noXmlTag($objProtein->getAccession()) . "_" . $objProtein->getPeptideFrame($pepnum) 
      . "_" . $startpos . "_" . $endpos . "\" />\n";
  }
  print "            <cvParam accession=\"MS:1001171\" name=\"mascot:score\" cvRef=\"PSI-MS\" value=\"" . $objProtein->getScore() . "\" />\n";
  
  if ($reportType eq 'concise') {
    my $expect = $objSummary->getProteinExpectationValue($objProtein->getScore());
    print "            <cvParam accession=\"MS:1001172\" name=\"mascot:expectation value\" cvRef=\"PSI-MS\" value=\"" . 
      sprintf("%.3g", $expect) . "\" />\n";
  }

  if ($thisScript->param($urlParams{'prot_len'})) {
    my $coverage = 0;  
    my $length = &getProteinLen($objProtein->getAccession(), $objSummary, $objParams, \%fastaLen, $objProtein->getFrame(), $objProtein->getDB);
    if ($length) {
    # accurate
      $coverage = $objProtein->getCoverage() * 100 / $length;
    } else {
      my $protMass = &mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame(), $objProtein->getDB);
      if ($protMass) {
      # approximate
        $coverage = $objProtein->getCoverage() * 100 * 110 / $protMass;
      }
    }
    $coverage = int $coverage;
    
    print "            <cvParam accession=\"MS:1001093\" name=\"sequence coverage\" cvRef=\"PSI-MS\" value=\"" . $coverage . "\" />\n";
  }
  
  if ($reportType eq 'concise') {
    my $numUnmatched = $objResFile->getNumQueries - $objProtein->getNumPeptides;
    print "            <cvParam accession=\"MS:1001362\" name=\"number of unmatched peaks\" cvRef=\"PSI-MS\" value=\"" . $numUnmatched . "\" />\n";
  } else {
    print "            <cvParam accession=\"MS:1001097\" name=\"distinct peptide sequences\" cvRef=\"PSI-MS\" value=\"" . $objProtein->getNumDistinctPeptides(0, $msparser::ms_protein::DPF_SEQUENCE) . "\" />\n";
  }
  print "          </ProteinDetectionHypothesis>\n";
}

###############################################################################
# &mzIdentMLfragmentation()
# output mzIdentML Fragmentation element
#
#
###############################################################################
sub mzIdentMLfragmentation() {
  my ($query, $rank, $peptide, $objAahelper) = @_;

  print "            <Fragmentation>\n";

  my @rules = split(/,/, $objResFile->params->getRULES);
  @rules = sort { $a <=> $b } @rules; # ensure sorted ascending
  my ($singleCharge, $doubleCharge);
  $singleCharge = 0;
  $doubleCharge = 0;
  foreach my $rule (@rules) {
    if ($rule == 1) {
      $singleCharge = 1;
    } elsif ($rule == 2 || $rule == 3) { 
      if (($rule == 2 && $peptide->getCharge > 1)
        || ($rule == 3 && $peptide->getCharge > 2)) {
        $doubleCharge = 1;
      }
    } else {
      my $charge;
      for ($charge = 1; $charge <= 2; $charge++) {
        if ($charge == 1 && $singleCharge || 
            $charge == 2 && $doubleCharge 
                         && $rule != $msparser::ms_fragmentationrules::FRAG_IMMONIUM
                         && $rule != $msparser::ms_fragmentationrules::FRAG_INTERNAL_YB
                         && $rule != $msparser::ms_fragmentationrules::FRAG_INTERNAL_YA) {
          my $fragments  = new msparser::ms_fragmentvector;
          my $err        = new msparser::ms_errs;
          if (!$objAahelper->calcFragmentsEx($peptide,
                                      $rule, 
                                      $charge,
                                      0,  # min fragment mass to return
                                      $peptide->getMrCalc, # max fragment mass to return 
                                      $objResFile->params->getMassType, # monoisotopic / average
                                      $fragments,
                                      $err)) {
            print "Error creating fragments\n";
          } else {
            $fragments->addExperimentalData($objResFile, $query);
            my ($idx, $exptMasses, $exptIntensities, $exptErrors, $separator);
            for (my $i=0; $i < $fragments->getNumberOfFragments; $i++) {
              my $fragment = $fragments->getFragmentByNumber($i);
              if ($fragment->getMatchedIonMass > 0) {
                if ($fragment->isInternal) {
                  $idx           = $idx             . $separator . $fragment->getStart . " " . $fragment->getEnd;
                } else {
                  $idx           = $idx             . $separator . $fragment->getColumn;
                }
                $exptMasses      = $exptMasses      . $separator . $fragment->getMatchedIonMass;
                $exptIntensities = $exptIntensities . $separator . $fragment->getMatchedIonIntensity;
                $exptErrors      = $exptErrors      . $separator . sprintf("%.4f", ($fragment->getMatchedIonMass - $fragment->getMass));
                $separator = " ";
              }
            }
            my ($accession, $name);
            if ($rule == $msparser::ms_fragmentationrules::FRAG_IMMONIUM) {
              $accession = "MS:1001239"; $name = "frag: immonium ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_A_SERIES) {
              $accession = "MS:1001229"; $name = "frag: a ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_A_MINUS_NH3) {
              $accession = "MS:1001235"; $name = "frag: a ion - NH3";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_A_MINUS_H2O) {
              $accession = "MS:1001234"; $name = "frag: a ion - H2O";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_B_SERIES) {
              $accession = "MS:1001224"; $name = "frag: b ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_B_MINUS_NH3) {
              $accession = "MS:1001232"; $name = "frag: b ion - NH3";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_B_MINUS_H2O) {
              $accession = "MS:1001222"; $name = "frag: b ion - H2O";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_C_SERIES) {
              $accession = "MS:1001231"; $name = "frag: c ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_X_SERIES) {
              $accession = "MS:1001228"; $name = "frag: x ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_Y_SERIES) {
              $accession = "MS:1001220"; $name = "frag: y ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_Y_MINUS_NH3) {
              $accession = "MS:1001233"; $name = "frag: y ion - NH3";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_Y_MINUS_H2O) {
              $accession = "MS:1001223"; $name = "frag: y ion - H2O";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_Z_SERIES) {
              $accession = "MS:1001230"; $name = "frag: z ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_INTERNAL_YB) {
              $accession = "MS:1001365"; $name = "frag: internal yb ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_INTERNAL_YA) {
              $accession = "MS:1001366"; $name = "frag: internal ya ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_Z_PLUS_1) {
              $accession = "MS:1001367"; $name = "frag: z+1 ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_D_SERIES) {
              $accession = "MS:1001236"; $name = "frag: d ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_V_SERIES ) {
              $accession = "MS:1001237"; $name = "frag: v ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_W_SERIES) {
              $accession = "MS:1001238"; $name = "frag: w ion";
            } elsif ($rule == $msparser::ms_fragmentationrules::FRAG_Z_PLUS_2 ) {
              $accession = "MS:1001368"; $name = "frag: z+2 ion";
            }
            if ($name && $accession && $idx) {
              print "              <IonType index=\"" . $idx . "\" charge=\"" . $charge . "\">\n";
              print "                <cvParam cvRef=\"PSI-MS\" accession=\"" . $accession . "\" name=\"" . $name . "\"/>\n";
              print "                <FragmentArray values=\"" . $exptMasses      . " \" Measure_ref=\"m_mz\"/>\n";
              print "                <FragmentArray values=\"" . $exptIntensities . "\" Measure_ref=\"m_intensity\"/>\n";
              print "                <FragmentArray values=\"" . $exptErrors      . "\" Measure_ref=\"m_error\"/>\n";
              print "              </IonType>\n";
            }
          }
        }
      }
    }
  }
  print "            </Fragmentation>\n";
}

###############################################################################
# &mzIdentMLoutputMod()
# output Mods in mzIdentML format
# $_[0] modification name in mod_file format
# $_[1] true for fixed, false for variable
###############################################################################

sub mzIdentMLoutputMod {
  my ($mod_file_name, $fixed) = @_;
  
  $mod_file_name =~ /(.*)\s+\((.*)\)/;
  my $mod_name = $1;
  my $specificity = $2;
  my ($specificityAccession, $specificityName, $residues);
  if ($specificity =~ /^N-term/i) {
    $specificityAccession = "MS:1001189";
    $specificityName      = "modification specificity N-term";
    $specificity          =~ /^N-term\s+(.*)/i;
    $residues             = $1;
  } elsif ($specificity =~ /^C-term/i) {
    $specificityAccession = "MS:1001190";
    $specificityName      = "modification specificity C-term";
    $specificity          =~ /^C-term\s+(.*)/i;
    $residues             = $1;
  } elsif( $specificity =~ /^Protein N-term/i) {
    $specificityAccession = "MS:1001189";
    $specificityName      = "modification specificity N-term";
    $specificity          =~ /^Protein N-term\s+(.*)/i;
    $residues             = $1;
  } elsif ($specificity =~ /^Protein C-term/i) {
    $specificityAccession = "MS:1001190";
    $specificityName      = "modification specificity C-term";
    $specificity          =~ /^Protein C-term\s+(.*)/i;
    $residues             = $1;
  } else {
    $specificityAccession = "";
    $specificityName      = "";
    $residues             = $specificity;
  }
  my $acc;
  my $mod2 = $objUmodConfigFile2->getModificationByName($mod_name);
  if ($mod2) {
    $acc = "UNIMOD:" . $mod2->getRecordID;
  } else {
    $acc = "UNIMOD:unknown";
  }

  my $delta = $objModFile->getModificationByName($mod_file_name)->getDelta($mass_type);
  if (length($residues) > 1) {
    $residues = join(" ", split(//, $residues));
  }

  print "        <SearchModification fixedMod=\"" . $fixed . "\" >\n";
  print "          <ModParam massDelta=\"" . $delta . "\" residues=\"" . $residues . "\">\n";
  print "            <cvParam accession=\"" . $acc . "\" name=\"" . &noXmlTag($mod_name) . "\" cvRef=\"UNIMOD\"/>\n";
  print "          </ModParam>\n"; 
  if ($specificityAccession) {
    print "          <SpecificityRules>\n";
    print "            <cvParam accession=\"" . $specificityAccession . "\" cvRef=\"PSI-MS\" name=\"" . $specificityName . "\"/>\n";
    print "          </SpecificityRules>\n";
  }
  print "        </SearchModification>\n";
}


###############################################################################
# &getTaxonomyNameFromId()
# return taxonomy name as string
# $_[0] taxonomy ID
# $_[1] ref to %taxNames (cache)
###############################################################################

sub getTaxonomyNameFromId {

  my ($id, $taxNames_ref) = @_;
  
# First time through, populate hash with some common tax IDs to reduce number
# of times we have to open names.dmp. 
# Also, means we get some information even if names.dmp missing
  unless (scalar(%{ $taxNames_ref })) {
    ${ $taxNames_ref }{'2'} = "Bacteria";
    ${ $taxNames_ref }{'197'} = "Campylobacter jejuni";
    ${ $taxNames_ref }{'358'} = "Agrobacterium tumefaciens";
    ${ $taxNames_ref }{'487'} = "Neisseria meningitidis";
    ${ $taxNames_ref }{'562'} = "Escherichia coli";
    ${ $taxNames_ref }{'590'} = "Salmonella";
    ${ $taxNames_ref }{'1224'} = "Proteobacteria";
    ${ $taxNames_ref }{'1239'} = "Firmicutes";
    ${ $taxNames_ref }{'1313'} = "Streptococcus Pneumoniae";
    ${ $taxNames_ref }{'1423'} = "Bacillus subtilis";
    ${ $taxNames_ref }{'1769'} = "Actinobacteria";
    ${ $taxNames_ref }{'1902'} = "Streptomyces coelicolor";
    ${ $taxNames_ref }{'2093'} = "Mycoplasma";
    ${ $taxNames_ref }{'2157'} = "Archaeobacteria";
    ${ $taxNames_ref }{'2157'} = "Archaeobacteria";
    ${ $taxNames_ref }{'2759'} = "Eukaryota";
    ${ $taxNames_ref }{'3360'} = "Alveolata";
    ${ $taxNames_ref }{'3701'} = "Arabidopsis";
    ${ $taxNames_ref }{'3702'} = "Arabidopsis thaliana";
    ${ $taxNames_ref }{'4530'} = "Oryza sativa";
    ${ $taxNames_ref }{'4754'} = "Pneumocystis carinii";
    ${ $taxNames_ref }{'4896'} = "Schizosaccharomyces pombe";
    ${ $taxNames_ref }{'4932'} = "Saccharomyces Cerevisiae";
    ${ $taxNames_ref }{'5833'} = "Plasmodium falciparum";
    ${ $taxNames_ref }{'6239'} = "Caenorhabditis elegans";
    ${ $taxNames_ref }{'7215'} = "Drosophila";
    ${ $taxNames_ref }{'7711'} = "Chordata";
    ${ $taxNames_ref }{'7898'} = "Actinopterygii";
    ${ $taxNames_ref }{'7955'} = "Danio rerio";
    ${ $taxNames_ref }{'8287'} = "lobe-finned fish and tetrapod clade";
    ${ $taxNames_ref }{'8355'} = "Xenopus laevis";
    ${ $taxNames_ref }{'9443'} = "Primates";
    ${ $taxNames_ref }{'9606'} = "Homo sapiens";
    ${ $taxNames_ref }{'9989'} = "Rodentia";
    ${ $taxNames_ref }{'10088'} = "Mus.";
    ${ $taxNames_ref }{'10090'} = "Mus musculus";
    ${ $taxNames_ref }{'10114'} = "Rattus";
    ${ $taxNames_ref }{'10239'} = "Viruses";
    ${ $taxNames_ref }{'11103'} = "Hepatitis C virus";
    ${ $taxNames_ref }{'12908'} = "unclassified";
    ${ $taxNames_ref }{'31033'} = "Takifugu rubripes";
    ${ $taxNames_ref }{'33090'} = "Viridiplantae";
    ${ $taxNames_ref }{'33208'} = "Metazoa";
    ${ $taxNames_ref }{'40674'} = "Mammalia";
    ${ $taxNames_ref }{'45251'} = "Arabidopsis neglecta";
    ${ $taxNames_ref }{'77643'} = "Mycobacterium tuberculosis complex";
    ${ $taxNames_ref }{'117571'} = "bony vertebrates";
  }

# if name not in cache, get from names.dmp and add to cache
  unless (${ $taxNames_ref }{$id}) {
    if (open(TAXFILE, "../taxonomy/names.dmp")) {
      my @matches = grep /^$id\s+/, <TAXFILE>;
      close TAXFILE;
      foreach my $match (@matches) {
        my @fields = split(/\|/, $match);
        if ($fields[3] =~ /\s+scientific name\s+/i) {
          $fields[1] =~ s/^\s+//;
          $fields[1] =~ s/\s+$//;
          ${ $taxNames_ref }{$id} = $fields[1];
          last;
        }
      }
    }
  # if this fails, set cache entry to -1 to prevent further attempts
    unless (${ $taxNames_ref }{$id}) {
      ${ $taxNames_ref }{$id} = "-1";
    }
  }

  if (${ $taxNames_ref }{$id} eq "-1") {
    return "";
  } else {
    return ${ $taxNames_ref }{$id};
  }
      
}

 