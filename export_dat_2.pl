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
#       $Date: 2007-07-19 12:52:28 $ #
#   $Revision: 1.19 $ #
# $NoKeywords::                                                            $ #
##############################################################################
 use strict;                                                                #
##############################################################################

# The following (case insensitive) URL arguments are recognised:
#
# file                      - relative path to result file (required)
# do_export                 - 1 to export results, otherwise display format control form 
# export_format             - "XML" or "CSV" or "pepXML" or "DTASelect" or ...
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
    $export_format,            # "XML" or "CSV" or ...
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
    $objEnzymesFile,           # Mascot parser enzymes file object
    $objMassesFile,            # Mascot parser masses file object
    $objModFile,               # Mascot parser mod_file object
    $objParams,                # Mascot parser search parameters object
    $objProtein,               # Mascot parser protein object
    $objResFile,               # Mascot parser result file object
    $objSummary,               # Mascot parser result summary object (may be protein or peptide)
    $protColumnCount,          # Used to align peptide match data in CSV output 
    $queryColumnCount,         # Used to align peptide match data in CSV output 
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
    $thisScript,               # CGI object
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
  use msparser 2.000_054;
  use CGI;
  use CGI::Carp qw(fatalsToBrowser);
  use HTTP::Request::Common;
  use LWP::UserAgent;

  $| = 1; # set autoflush on STDOUT

# create CGI object
  $thisScript = new CGI;
 
# pull in some common subroutines
  require "./common_subs.pl";
# and pull mascot.dat into memory
  &readConfig();
  
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
# Unix path may be required to find decompression utilities in &decompress()
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
    unless (-e &decompress($fileIn)) {
      die("result file does not exist ", $fileIn);
    }
  } else {
    die("result filename could not be untainted");
  }
  
# create Mascot Parser result file object
  $objResFile = new msparser::ms_mascotresfile(&decompress($fileIn));

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
      &printHeader1("Matrix Science - Not authorised");
      &printHeader2("", "Not authorised", 1);
      print "<B><FONT COLOR=#FF0000>Sorry, "
        . $session->getUserName 
        . " is not authorised to export this result report</FONT></B>";
      &printFooter;
      print "</BODY>\n";
      print "</HTML>\n";
      exit 1;
    }
  } else {
    print $thisScript->header( -charset => "utf-8" );
    &printHeader1("Matrix Science - Not logged in");
    &printHeader2("", "Not logged in", 1);
    &go2login(&urlEscape($thisScript->self_url), $session->getLastError, &urlEscape($session->getLastErrorString));
    &printFooter;
    print "</BODY>\n";
    print "</HTML>\n";
    exit 1;
  }

# validate a variety of mascot.dat and URL parameters
  &validateParams();
  
# branch here if we require the formatting form
  unless ($thisScript->param($urlParams{'do_export'})) {
    &formatControls();
    exit 0;
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
      &decompress($objParams->getErrTolParentFilename());
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

# emPAI is always available if we have MS/MS results and at least 100 spectra
# unless integrated decoy or old style ET
# if integrated ET, will report using only non-ET matches
  if (!$anyPepSumMatch
    || ($objParams->getDECOY() > 0 && $ShowDecoyReport)) {
    $quant_subs_active = 0;
  } elsif ($thisScript->param($urlParams{'prot_empai'}) 
    || $thisScript->param($urlParams{'pep_quant'})
    || $thisScript->param($urlParams{'prot_quant'})) {
    $quant_subs_active = 1;
  } else {
    $quant_subs_active = 0;
  }
  my($minExpMoverZ, $maxExpMoverZ);
  if ($quant_subs_active) {
  # pull in the quantitation subroutines
    do "./quant_subs.pl";
  # byte leaking messes up output
    $quant_subs::noKeepAlive = 1;
  # make temporary file, if required
    &quant_subs::create_text_file(&decompress($fileIn));
  # get experimental mass range estimate
    ($minExpMoverZ, $maxExpMoverZ) = &quant_subs::emPAI_mz_range($objResFile);
  }
       
# should this report include additional quantitation info?
# if so, $objQuantMethod will encapsulate the quantitation method
# report can only handle multiplex and reporter protocols
  if ($objParams->getQUANTITATION() 
    && lc($objParams->getQUANTITATION()) ne "none"
    && $quant_subs_active
    && ($thisScript->param($urlParams{'pep_quant'})
      || $thisScript->param($urlParams{'prot_quant'}))) {
    $objQuantFile = new msparser::ms_quant_configfile();
    if ($objResFile->getQuantitation($objQuantFile)) {
    # abort on fatal error. Note that isValid() remains true if there are only warnings
      unless ($objQuantFile->isValid) {
        die(&checkErrorHandler($objQuantFile), " ", $fileIn);
      }
      $objQuantMethod = $objQuantFile->getMethodByName($objParams->getQUANTITATION());
      if ($objQuantMethod) {
        my $tempString = uc($objQuantMethod->getProtocol->getType());
        if ($tempString eq "MULTIPLEX" || $tempString eq "REPORTER") {
          $objQuantFile->setSchemaFileName("../html/xmlns/schema/quantitation_1/quantitation_1.xsd");
          my $errorList = $objQuantFile->validateDocument();
          if ($errorList) {
            die("Mascot Parser error(s): ", $errorList, " ", $fileIn);
          }
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
        } else {
          undef $objQuantMethod;
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
      $minPepLen
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

  if ($export_format eq "pepXML" || $export_format eq "DTASelect") {

  # create a masses file object
    $objMassesFile = new msparser::ms_masses("../config/masses");
  # abort on fatal error. Note that isValid() is true if there are only warnings
    unless ($objMassesFile->isValid) {
      my $errorList = "Mascot Parser error(s):<BR>\n";
      my $objErr = $objMassesFile->getErrorHandler();
      for (my $i = 1; $i <= $objErr->getNumberOfErrors(); $i++) {
        $errorList .= $objErr->getErrorNumber($i) 
          . ": " . $objErr->getErrorString($i) . "<BR>\n";
      }
      die $errorList;
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
  
  # create a modifications file object
    $objModFile = new msparser::ms_modfile("../config/mod_file", $objMassesFile);
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
  
  # create an enzymes file object
    $objEnzymesFile = new msparser::ms_enzymefile("../config/enzymes");
  # abort on fatal error. Note that isValid() is true if there are only warnings
    unless ($objEnzymesFile->isValid) {
      my $errorList = "Mascot Parser error(s):<BR>\n";
      my $objErr = $objEnzymesFile->getErrorHandler();
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
  
}

# parse out result file name root
  ($fileNameRoot) = $fileIn =~ /([^\/\\]*)\.dat$/;

# output HTTP header
  if ($ENV{'SERVER_NAME'}) {
    if ($export_format eq "XML" || $export_format eq "pepXML") {
      print $thisScript->header( -type => "text/xml",
                                 -charset => "utf-8",
                                 -attachment => "$fileNameRoot.xml");
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
    print "  majorVersion=\"2\" minorVersion=\"0\">\n";
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
      if ($objParams->getVarModsName(1)) {
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
# globals:
# my($objSummary, $objParams, $shipper);
###############################################################################

sub mustGetProteinDescription{

  my ($accession, $fastaTitles_ref) = @_;

# first try the Mascot Parser summary object  
  my $description = $objSummary->getProteinDescription($accession);
  if ($description) {
    return $description;
  }
# if this is the public web site, give up
  if ($shipper eq 'FALSE') {
    return;
  }
# next try the cache
  $description = ${ $fastaTitles_ref }{$accession};
  if ($description == -1) {
  # failed to get a title when we tried the first time, so give up
    return;
  } elsif ($description) {
    return $description;
  }
# finally, try ms-getseq.exe
  my @retVal = &getExtInfo($accession, 0, $objParams->getDB(), "title");
  if ($retVal[0]) {
  # success, save in cache
    ${ $fastaTitles_ref }{$accession} = &parseTitle($retVal[1], $objParams->getDB());
    return ${ $fastaTitles_ref }{$accession};
  } else {
  # failure, set cache entry to -1
    ${ $fastaTitles_ref }{$accession} = -1;
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
###############################################################################

sub mustGetProteinMass {

  my ($accession, $objSummary, $objParams, $fastaMasses_ref, $frame) = @_;
  
# if protein contains matches in mixed frames, then choose frame 1 to get approximate mass
  if ($frame == -1) {$frame = 1}

# first try the Mascot Parser summary object  
  my $mass = $objSummary->getProteinMass($accession);
  if ($mass) {
    return $mass;
  }
  
# if this is the public web site, give up
  if ($shipper eq 'FALSE') {
    return;
  }
  
# next try the cache
  $mass = ${ $fastaMasses_ref }{$accession . "<" . $frame . ">"};
  if ($mass == -1) {
  # failed to get a title when we tried the first time, so give up
    return;
  } elsif ($mass) {
  # mass was in the cache
    return $mass;
  }
  
# OK, have to get the sequence and calculate the mass
  my $seqString = &mustGetProteinSeq($accession, $frame);
  if ($seqString) {
    $mass = $objSummary->getSequenceMass($seqString);
    ${ $fastaMasses_ref }{$accession . "<" . $frame . ">"} = $mass;
  } else {
 # Cannot retrieve sequence
    $mass = ""; 
    ${ $fastaMasses_ref }{$accession . "<" . $frame . ">"} = -1;
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
###############################################################################

sub getProteinpI {

  my ($accession, $objSummary, $objParams, $fastapI_ref, $frame) = @_;

# if protein contains matches in mixed frames, then return empty handed
  if ($frame == -1) {return}

# first try the cache
  my $pI = ${ $fastapI_ref }{$accession . "<" . $frame . ">"};
  if ($pI == -1) {
  # failed to calculate pI when we tried the first time, so give up
    return;
  } elsif ($pI) {
  # pI was in the cache
    return $pI;
  }
  
# calculate pI from ms-getseq.exe
  my @retVal = &getExtInfo($accession, $frame, $objParams->getDB(), "pI");
  if ($retVal[0]) {
    if ($retVal[1] =~ /plain\s+([\d\.]+)\s*$/) {
      $pI = $1;
    }
  }
  if ($pI) {
    ${ $fastapI_ref }{$accession . "<" . $frame . ">"} = $pI;
  } else {
    $pI = ""; 
    ${ $fastapI_ref }{$accession . "<" . $frame . ">"} = -1;
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
###############################################################################

sub getProteinLen {

  my ($accession, $objSummary, $objParams, $fastaLen_ref, $frame) = @_;

# if protein contains matches in mixed frames, then choose frame 1 to get approximate length
  if ($frame == -1) {$frame = 1}

# first try the cache
  my $Len = ${ $fastaLen_ref }{$accession . "<" . $frame . ">"};
  if ($Len == -1) {
  # failed to calculate length when we tried the first time, so give up
    return;
  } elsif ($Len) {
  # length was in the cache
    return $Len;
  }
  
# calculate length from ms-getseq.exe
  my @retVal = &getExtInfo($accession, $frame, $objParams->getDB(), "length");
  if ($retVal[0]) {
    if ($retVal[1] =~ /plain\s+([\d\.]+)\s*$/) {
      $Len = $1;
    }
  }
  if ($Len) {
    ${ $fastaLen_ref }{$accession . "<" . $frame . ">"} = $Len;
  } else {
    $Len = ""; 
    ${ $fastaLen_ref }{$accession . "<" . $frame . ">"} = -1;
  }
  
  return $Len;
  
}

###############################################################################
# &mustGetProteinSeq()
# tries very hard to get a description string
# $_[0] is an accession
# $_[2] frame number, 0 for protein, (-1 for mixed is not allowed)
# globals:
# my($objParams, $shipper);
###############################################################################

sub mustGetProteinSeq {

  my ($accession, $frame) = @_;

# if this is the public web site, give up
  if ($shipper eq 'FALSE') {
    return;
  }
  
# cannot get sequence for mixed frame match
  if ($frame < 0 || $frame > 6) {
    return;
  }
  
# first try the cache
  my $seq = $seqCache{$accession . "<" . $frame . ">"};
  if ($seq == -1) {
  # failed to get a seq when we tried the first time, so give up
    return;
  } elsif ($seq) {
  # success, sequence was in cache
    return $seq;
  }

# Get sequence from ms-getseq.exe
  my @retVal = &getExtInfo($accession, $frame, $objParams->getDB(), "sequence");
  if ($retVal[0]) {
    $seq = &parseSequence($retVal[1], $retVal[2]);
    if ($seq) {
      $seqCache{$accession . "<" . $frame . ">"} = $seq;
    } else {
    # Empty sequence
      $seqCache{$accession . "<" . $frame . ">"} = -1;
    }
  } else {
 # unable to retrieve sequence
    $seqCache{$accession . "<" . $frame . ">"} = -1;
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
  $tempString = &getConfigParam("Options", "MassDecimalPlaces");
  if ($tempString =~ /^MassDecimalPlaces\s+(\d+)/i) {
    $massDP = $1;
  } else {
    $massDP = 2;
  }
  $massDP = int($massDP);
  if ($massDP < 1 || $massDP > 6) {
    $massDP = 2;
  }
  
# peptides shorter than $minPepLen are not interesting
# default is to ignore anything shorter than 6 residues
  $tempString = &getConfigParam("Options", "MinPepLenInPepSummary");
  if ($tempString =~ /^MinPepLenInPepSummary\s+(\d+)/i) {
    $minPepLen = $1;
  } else {
    $minPepLen = 6;
  }
  $minPepLen = int($minPepLen); 
  if ($minPepLen < 1 || $minPepLen > 9) {
    $minPepLen = 6;
  }
  
# ignoreIonsScoreBelow is a threshold on MS/MS ions scores
# a value of 0 specifies that all peptides are included (default)
# a value greater than 1 indicates an absolute score cutoff 
# a value less than 1 is treated as a probability threshold 
  if (defined($thisScript->param($urlParams{'_ignoreionsscorebelow'}))
    && $thisScript->param($urlParams{'_ignoreionsscorebelow'}) > 0) {
    $ignoreIonsScoreBelow = $thisScript->param($urlParams{'_ignoreionsscorebelow'}) + 0;
  } else {
    $tempString = &getConfigParam("Options", "IgnoreIonsScoreBelow");
    if ($tempString =~ /^IgnoreIonsScoreBelow\s+([0-9\.]+)/i) {
      $ignoreIonsScoreBelow = $1;
    } else {
      $ignoreIonsScoreBelow = 0;
    }
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
    my $tempString = &getConfigParam("Options", "MudpitSwitch");
    if ($tempString =~ /^MudpitSwitch\s+([0-9\.]+)/i) {
      if ($1 > 0) {
        $mudpitSwitch = $1 + 0;
      }
    }
  }

# If $ShowDecoyReport is true, a report for the integrated decoy search is shown
  if (defined($thisScript->param($urlParams{'_show_decoy_report'}))) {
    $ShowDecoyReport = $thisScript->param($urlParams{'_show_decoy_report'}) + 0;
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
    && $thisScript->param($urlParams{'_sigthreshold'}) <= 0.1) {
    $sigThreshold = $thisScript->param($urlParams{'_sigthreshold'}) + 0;
  } else {
    my $tempString = &getConfigParam("Options", "SigThreshold");
    if ($tempString =~ /SigThreshold\s+([0-9\.]+)/i) {
      $sigThreshold = $1;
    } else {
      $sigThreshold = 0.05;
    }
    if ($sigThreshold < 1E-18 || $sigThreshold > 0.1) {
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
    my $tempString = &getConfigParam("Options", "ShowSubSets");
    if ($tempString =~ /^ShowSubSets\s+([\d\.]+)/i) {
      $ShowSubSets = $1 + 0;
    } else {
      $ShowSubSets = 0;
    }
  }

# If RequireBoldRed is true, only display protein hits that include at least one bold, red peptide match
  if (defined($thisScript->param($urlParams{'_requireboldred'}))) {
    $RequireBoldRed = $thisScript->param($urlParams{'_requireboldred'}) + 0;
  } elsif ($thisScript->param($urlParams{'do_export'})) {
    $RequireBoldRed = 0;
  } else {
    my $tempString = &getConfigParam("Options", "RequireBoldRed");
    if ($tempString =~ /^RequireBoldRed\s+(\d)/i) {
      $RequireBoldRed = $1 + 0;
    } else {
      $RequireBoldRed = 0;
    }
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
      $UniGeneFile = &getConfigParam("UniGene", $species)
        || die("cannot find UniGene $species in mascot.dat ", $fileIn);
      $UniGeneFile =~ s/^$species\s+//i;
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

  print $thisScript->header( -charset => "utf-8" );

  &printHeader1("Matrix Science - Mascot - Export search results");

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
      form.show_header.disabled = !checkState;
      form.show_decoy.disabled = !checkState;
      form.show_mods.disabled = !checkState;
      form.show_params.disabled = !checkState;
      form.show_format.disabled = !checkState;
      form.show_masses.disabled = !checkState;
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
      form.prot_desc.disabled = !checkState;
      form.prot_mass.disabled = !checkState;
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
      form.prot_pi.disabled = !checkState || !shipper;
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
      form.pep_exp_mr.disabled = !checkState;
      form.pep_exp_z.disabled = !checkState;
      form.pep_calc_mr.disabled = !checkState;
      form.pep_delta.disabled = !checkState;
      form.pep_start.disabled = !checkState;
      form.pep_end.disabled = !checkState;
      form.pep_miss.disabled = !checkState;
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
      form.pep_seq.disabled = !checkState;
      form.pep_frame.disabled = !checkState;
      form.pep_var_mod.disabled = !checkState;
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

  &printHeader2("", "Export search results", 1);
  
  print <<"end_of_static_HTML_text_block";
  <FORM ACTION="./$myName" NAME="Re-format" METHOD="GET">
  <INPUT TYPE="hidden" NAME="file" VALUE="$fileIn">
  <INPUT TYPE="hidden" NAME="do_export" VALUE=1>
  <INPUT TYPE="hidden" NAME="prot_hit_num" VALUE=1>
  <INPUT TYPE="hidden" NAME="prot_acc" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_query" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_rank" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_isbold" VALUE=1>
  <INPUT TYPE="hidden" NAME="pep_exp_mz" VALUE=1>
  <INPUT TYPE="hidden" NAME="_showallfromerrortolerant" VALUE=$ShowAllFromErrorTolerant>
  <INPUT TYPE="hidden" NAME="_onlyerrortolerant" VALUE=$OnlyErrorTolerant>
  <INPUT TYPE="hidden" NAME="_noerrortolerant" VALUE=$NoErrorTolerant>
  <INPUT TYPE="hidden" NAME="_show_decoy_report" VALUE=$ShowDecoyReport>
end_of_static_HTML_text_block

# pass through any quantitation parameters
  while (my($key, $value) = each %urlParams) {
    if ($key =~ /^_quant/i) {
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
  if ($reportType eq 'peptide' && $export_format eq "DTASelect") {
    print "         <OPTION SELECTED>DTASelect</OPTION>\n";
  } elsif ($reportType eq 'peptide') {
    print "         <OPTION>DTASelect</OPTION>\n";
  }
  
  print <<"end_of_static_HTML_text_block";
        </SELECT>
      </TD> 
    </TR>

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
      print "       <INPUT NAME=\"REPORT\" TYPE=text SIZE=5 VALUE=$numHits>\n";
    } else {
      print "       <INPUT NAME=\"REPORT\" TYPE=text SIZE=5 VALUE=AUTO>\n";
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
    &checkBox("Include same-set protein hits<BR>(additional proteins that span<BR>the same set of peptides)", 
      "show_same_sets", "", "");
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
    if (my $tempString = &getConfigParam("UniGene", $objParams->getDB())) {
      my @tempList = split(/\s+/, $tempString);
      if (defined($tempList[1])) {
        print "  <TR>\n";
        print "    <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>\n";
        print "UniGene index </TD>";
        print "    <TD BGCOLOR=#EEEEFF>\n";
        print "      <SELECT NAME=\"UNIGENE\">\n";
        shift @tempList;
        unshift @tempList, "None";
        my $species = "None";
        if ($thisScript->param($urlParams{'unigene'})) {
          $species = $thisScript->param($urlParams{'unigene'});
        }
        for (my $i = 0; $i < scalar(@tempList); $i++) {
          print "  <OPTION";
          if ($species eq $tempList[$i]) {
            print " SELECTED";
          }
          print ">$tempList[$i]</OPTION>\n";
        }
        print "</SELECT>\n";
        print "    </TD>\n";
        print "  </TR>\n";
      }
    }
    
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
    &checkBox("Variable mod. info.", "show_mods", "CHECKED", "");
    &checkBox("Search parameters", "show_params", "CHECKED", "");
    &checkBox("Format parameters", "show_format", "CHECKED", "");
    &checkBox("Residue masses", "show_masses", "", "");
  }

  print "   <TR>\n";
  print "     <TD NOWRAP ALIGN=RIGHT COLSPAN=2>&nbsp;</TD>\n";
  print "   </TR>\n";

  print "   <TR>\n";
  print "     <TD NOWRAP>\n";
  print "     <H3>Protein Hit Information</H3></TD>\n";
  print "     <TD NOWRAP VALIGN=top>\n";
  if ($export_format eq "pepXML" || $export_format eq "DTASelect") {
    print "     &nbsp;</TD>\n";
  } else {
    print "     <INPUT TYPE=\"checkbox\" NAME=\"protein_master\" VALUE=1 CHECKED onClick=\"check_slaves(this, this.form)\"></TD>\n";
  }
  print "   </TR>\n";

  unless ($export_format eq "pepXML" || $export_format eq "DTASelect") {
    &checkBox("Score", "prot_score", "CHECKED", "");
    unless ($anyPepSumMatch) {
      &checkBox("Significance threshold", "prot_thresh", "CHECKED", "");
      &checkBox("Expectation value", "prot_expect", "CHECKED", "");
    }
  }
  &checkBox("Description<SUP>*</SUP>", "prot_desc", "CHECKED", "");
  &checkBox("Mass (Da)<SUP>*</SUP>", "prot_mass", "CHECKED", "");
  my $disabled = "";
  if ($shipper eq 'FALSE') {
    $disabled = "disabled";
  }
  unless ($export_format eq "pepXML" || $export_format eq "DTASelect") {
    &checkBox("Number of queries matched", "prot_matches", "CHECKED", "");
    &checkBox("Percent coverage<SUP>**</SUP>", "prot_cover", "", $disabled);
  }
  unless ($export_format eq "pepXML") {
    &checkBox("Length in residues<SUP>**</SUP>", "prot_len", "", $disabled);
  }
  &checkBox("pI<SUP>**</SUP>", "prot_pi", "", $disabled);
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

  unless ($export_format eq "pepXML" || $export_format eq "DTASelect") {
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
    print "   <TR>\n";
    print "     <TD NOWRAP>\n";
    print "     <H3>Query Level Information</H3></TD>\n";
    print "     <TD NOWRAP VALIGN=top>\n";
    print "     <INPUT TYPE=\"checkbox\" NAME=\"query_master\" VALUE=1 onClick=\"check_slaves(this, this.form)\"></TD>\n";
    print "   </TR>\n";

    unless ($objResFile->isPMF()){
      &checkBox("Query title", "query_title", "", "disabled");
      &checkBox("seq(), comp(), tag(), etc.", "query_qualifiers", "", "disabled");
      &checkBox("Query level<BR>search parameters", "query_params", "", "disabled");
      &checkBox("MS/MS Peak lists", "query_peaks", "", "disabled");
      &checkBox("Raw peptide match data", "query_raw", "", "disabled");
    }
  }


  print <<"end_of_static_HTML_text_block";

    <TR>
      <TD NOWRAP ALIGN=RIGHT COLSPAN=2>&nbsp;</TD>
    </TR>
    <TR>
      <TD BGCOLOR=#EEEEFF NOWRAP ALIGN=RIGHT>&nbsp;</TD>
      <TD BGCOLOR=#EEEEFF NOWRAP>
        <INPUT TYPE="submit" VALUE="Export search results">
      </TD>
    </TR>
    
  </TABLE>
  
</FORM>

end_of_static_HTML_text_block

  &printFooter;
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

  if ($export_format eq "XML") {
    print "<protein accession=\"" . $objProtein->getAccession() . "\">\n";
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
        print $hitNum . $delimiter x $protColumnCount;
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

  my $string = "";
  if ($export_format eq "CSV") {
    $string .=  $hitNum . $delimiter;
    $string .= "\"" . &noQuotes($objProtein->getAccession()) . "\"$delimiter";
  }
  $protColumnCount++;
  $protColumnCount++;
  if ($thisScript->param($urlParams{'prot_desc'})) {
    $string .= &formatElement($export_format, "", 1, "prot_desc", 
      &mustGetProteinDescription($objProtein->getAccession(), \%fastaTitles)) . $delimiter;
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
    if (&mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame())) {
      $string .= &formatElement($export_format, "", 0, "prot_mass", 
        sprintf("%.0f", &mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame()))) . $delimiter;
    } else {
      if ($export_format eq "CSV") {
        $string .= $delimiter;
      }
    }
    $protColumnCount++;
  }
  if ($thisScript->param($urlParams{'prot_matches'})) {
    $string .= &formatElement($export_format, "", 0, "prot_matches", 
      $objProtein->getNumDisplayPeptides()) . $delimiter;
    $protColumnCount++;
  }
  if ($thisScript->param($urlParams{'prot_cover'}) || $thisScript->param($urlParams{'prot_len'})) {
    my $coverage = "";
    my $length = &getProteinLen($objProtein->getAccession(), $objSummary, $objParams, \%fastaLen, $objProtein->getFrame());
    if ($length) {
    # accurate
      $coverage = $objProtein->getCoverage() * 100 / $length;
    } else {
      my $protMass = &mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame());
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
    my $pI = &getProteinpI($objProtein->getAccession(), $objSummary, $objParams, \%fastapI, $objProtein->getFrame());
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
    my $db = $objParams->getDB();
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
    my $seq = &mustGetProteinSeq($objProtein->getAccession(), $objProtein->getFrame());
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
        } elsif ($objSummary->getUnassignedIsBold($i)) {
          $string .= "1" . $delimiter;
        } else {
          $string .= "0" . $delimiter;
        }
      } else {
        $string .= $delimiter;
      }
    } else {
      $string .= $delimiter . $delimiter;
    }
  }
  $string .= &formatElement($export_format, "", 0, "pep_exp_mz",
    sprintf("%." . $massDP . "f", $objPeptide->getObserved())) . $delimiter;
  if ($thisScript->param($urlParams{'pep_exp_mr'})) {
    $string .= &formatElement($export_format, "", 0, "pep_exp_mr",
      sprintf("%." . $massDP . "f", $objResFile->getObservedMrValue($queryNum))) . $delimiter;
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
      $string .= &formatElement($export_format, "", 0, "pep_homol", 
        $objSummary->getHomologyThreshold($queryNum, 1 / $sigThreshold)) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_ident'})) {
    if ($objPeptide->getAnyMatch() &&
      $objSummary->getPeptideIdentityThreshold($queryNum, 1 / $sigThreshold) &&
      $objSummary->getPeptideIdentityThreshold($queryNum, 1 / $sigThreshold) > -1) {
      $string .= &formatElement($export_format, "", 0, "pep_ident", 
        $objSummary->getPeptideIdentityThreshold($queryNum, 1 / $sigThreshold)) . $delimiter;
    } elsif ($export_format eq "CSV") {
      $string .= $delimiter;
    }
  }
  if ($thisScript->param($urlParams{'pep_expect'})) {
    if ($objPeptide->getAnyMatch()) {
      $string .= &formatElement($export_format, "", 0, "pep_expect", 
        sprintf("%.2g", $objSummary->getPeptideExpectationValue($objPeptide->getIonsScore(), $queryNum))) . $delimiter;
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

  my @ratioValues;
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
  print &formatElement($export_format, "Database", 1, "DB", $objParams->getDB()) . "\n";
  print &formatElement($export_format, "Fasta file", 1, "FastaVer", $objResFile->getFastaVer()) . "\n";
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
    if ($losses) {
      my $j = 1;
      foreach(@{ $losses }) {
        my $letter = $j;
        if ($j > 9) {
          $letter = chr($j + 55);
        }
        $string .= &formatElement($export_format, "", 0, "neutral_loss", $_, "identifier", $letter) . $delimiter;
        $j++;
      }
      chop $string;
    }
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
  } else {
    print &formatElement($export_format, "ICAT experiment", 0, "ICAT", $objParams->getICAT()) . "\n";
  }
  my $local_it_mods = $objParams->getIT_MODS();
  if ($objParams->getICAT()){
    my $ICATLight = &getConfigParam("Options", "ICATLight");
    if ($ICATLight) {
      if ($ICATLight =~ /ICATLight\s+(.+)/) {
        $ICATLight = $1;
      } else {
        $ICATLight = "";
      }
    }
    $ICATLight = "ICAT_light" unless $ICATLight;
    my $ICATHeavy = &getConfigParam("Options", "ICATHeavy");
    if ($ICATHeavy) {
      if ($ICATHeavy =~ /ICATHeavy\s+(.+)/) {
        $ICATHeavy = $1;
      } else {
        $ICATHeavy = "";
      }
    }
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
  
  my $string = "";
  for (my $queryNum = 1; $queryNum <= $objResFile->getNumQueries; $queryNum++) {
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
  print "<search_database";
  my $objDatabases = $objDatFile->getDatabases;
  my $databasePath = "";
  if ($objDatabases->isSectionAvailable) {
    for(my $i = 0; $i < $objDatabases->getNumberOfDatabases; $i++) {
      if ($objDatabases->getDatabase($i)->getName eq $objParams->getDB) {
        $databasePath = $objDatabases->getDatabase($i)->getPath;
        last;
      }
    }
  }
  $databasePath = glob($databasePath);
  print " local_path=\"$databasePath\"";
  # optional URL
  print " database_name=\"" . &noXmlTag($objParams->getDB) . "\"";
  # optional orig_database_url
  # optional database_release_date
  print " database_release_identifier=\"" . $objResFile->getFastaVer . "\"";
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
my @res_mods;
  my $mod_string = $objParams->getMODS();
  if ($mod_string) {
    my @mod_list = split(/,/, $mod_string);
    foreach my $modName (@mod_list) {
      push @res_mods, &getResidueMods($modName, "N");
    }
  }
  $mod_string = $objParams->getIT_MODS();
  if ($mod_string) {
    my @mod_list = split(/,/, $mod_string);
    foreach my $modName (@mod_list) {
      push @res_mods, &getResidueMods($modName, "Y");
    }
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
  my @term_mods;
  $mod_string = $objParams->getMODS();
  if ($mod_string) {
    my @mod_list = split(/,/, $mod_string);
    foreach my $modName (@mod_list) {
      push @term_mods, &getTerminalMods($modName, "N");
    }
  }
  $mod_string = $objParams->getIT_MODS();
  if ($mod_string) {
    my @mod_list = split(/,/, $mod_string);
    foreach my $modName (@mod_list) {
      push @term_mods, &getTerminalMods($modName, "Y");
    }
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
          my $tempString = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_PEPTIDES, "q$queryNum\_p$rank");
          my($left, $right) = split(/;/, $tempString, 2);
          my @protein_list = $right =~ /"(.+?)"/g;
          $tempString = $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_PEPTIDES, "q$queryNum\_p$rank\_terms");
          my($peptide_prev_aa, $peptide_next_aa) = $tempString =~ /^(.),(.)/;
          if ($rank == 1) {
          # spectrum_query
            $needClosingTag = 1;
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
            $repeatSearchString =~ s/^\s*//;
            $repeatSearchString =~ s/\s*$//;
            if ($repeatSearchString) {
              print " search_specification=\"$repeatSearchString\"";
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
          print " protein=\"" . &noXmlTag($protein_list[0]) . "\"";
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
            $prot_desc = &noXmlTag(&mustGetProteinDescription($protein_list[0], \%fastaTitles));
          }
          if ($prot_desc) {
            print " protein_descr=\"$prot_desc\"";
          }
          my $frame = 0;
          if (($thisScript->param($urlParams{'prot_pi'}) 
            || $thisScript->param($urlParams{'prot_mass'}))
            && $objSummary->isNA) {
            my $objProtein = $objSummary->getProtein($protein_list[0]);
            if ($objProtein) {
              $frame = $objProtein->getFrame();
            }
          }
          if ($thisScript->param($urlParams{'prot_pi'})) {
            my $pI = &getProteinpI($protein_list[0], $objSummary, $objParams, \%fastapI, $frame);
            if ($pI) {
              print " calc_pI=\"$pI\"";
            }
          }
          my $protein_mw = 0;
          if ($thisScript->param($urlParams{'prot_mass'})) {
            $protein_mw = &mustGetProteinMass($protein_list[0], $objSummary, $objParams, \%fastaMasses, $frame);
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
              print " protein=\"" . &noXmlTag($protein_list[$prot_num]) . "\"";
              if ($thisScript->param($urlParams{'prot_desc'})) {
              # only look for description in result file for alternative proteins
                if ($tempString = &noXmlTag($objSummary->getProteinDescription($protein_list[$prot_num]))) {
                  print " protein_descr=\"$tempString\"";
                }
              }
              # optional num_tol_term
              if ($thisScript->param($urlParams{'prot_mass'})) {
              # only look for mass in result file for alternative proteins
                if ($tempString = $objSummary->getProteinMass($protein_list[$prot_num])) {
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
                $objResFile->getSectionValueStr($msparser::ms_mascotresfile::SEC_PEPTIDES, "q$queryNum\_p$rank\_et_mods");
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
            $repeatSearchString =~ s/^\s*//;
            $repeatSearchString =~ s/\s*$//;
            if ($repeatSearchString) {
              print " search_specification=\"$repeatSearchString\"";
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
  my @term_mods;
  my $mod_string = $objParams->getMODS();
  if ($mod_string) {
    my @mod_list = split(/,/, $mod_string);
    foreach my $modName (@mod_list) {
      push @term_mods, &getTerminalMods($modName, "N");
    }
  }
  $mod_string = $objParams->getIT_MODS();
  if ($mod_string) {
    my @mod_list = split(/,/, $mod_string);
    foreach my $modName (@mod_list) {
      push @term_mods, &getTerminalMods($modName, "Y");
    }
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
  print  "S\t" . $objResFile->getFastaVer() . "\t$fixProtC\t$fixProtN\t$fixPepC\t$fixPepN\tfalse\ttrue\n";
    
# aminoacid_modifications
  my @res_mods;
  $mod_string = $objParams->getMODS();
  if ($mod_string) {
    my @mod_list = split(/,/, $mod_string);
    foreach my $modName (@mod_list) {
      push @res_mods, &getResidueMods($modName, "N");
    }
  }
  $mod_string = $objParams->getIT_MODS();
  if ($mod_string) {
    my @mod_list = split(/,/, $mod_string);
    foreach my $modName (@mod_list) {
      push @res_mods, &getResidueMods($modName, "Y");
    }
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
    $Description = &mustGetProteinDescription($objProtein->getAccession(), \%fastaTitles);
  }
  $Description = "no description" unless ($Description);
  if ($thisScript->param($urlParams{'prot_mass'})) {
    $MW = &mustGetProteinMass($objProtein->getAccession(), $objSummary, $objParams, \%fastaMasses, $objProtein->getFrame());
  }
  $MW = 0 unless ($MW);
  if ($thisScript->param($urlParams{'prot_len'})) {
    $Length = &getProteinLen($objProtein->getAccession(), $objSummary, $objParams, \%fastaLen, $objProtein->getFrame());
  } elsif ($MW) {
    $Length = int($MW / 110);
  }
  $Length = 0 unless ($Length);
  if ($thisScript->param($urlParams{'prot_pi'})) {
    $pI = &getProteinpI($objProtein->getAccession(), $objSummary, $objParams, \%fastapI, $objProtein->getFrame());
  }
  $pI = 0 unless ($pI);
  
  print  join("\t", 
    "L", 
    $objProtein->getAccession(), 
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
      ($objResFile->getObservedMrValue($queryNum) + $masses{'hydrogen'} - $masses{'electron'}),
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
