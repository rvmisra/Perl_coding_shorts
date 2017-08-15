<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>The Emili Lab Software</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body>
#!/usr/bin/perl
<p>##########################################################################<br>
  # proteogest.pl<br>
  # This program analyses a given proteome and reports the analysis in<br>
  # files created on users computer.<br>
  #<br>
  # The input this program is a valid proteome FASTA file in text format.<br>
  # There are few output files produced by this program.<br>
  #<br>
  # The following are the commandline arguments to this program<br>
  # ------------------------------------------------------------------------<br>
  # [-i input_file_name]<br>
  # this has to be a valid FASTA format file specifying the protins<br>
  # in the proteome<br>
  # ------------------------------------------------------------------------<br>
  # [-d ] creates simple.txt output file<br>
  # If -d is spcified on the commandline then a simple file will be<br>
  # created. This file has four columns. 1st column is the range<br>
  # where the peptide is in the protein. 2nd and 3rd columns are the<br>
  # isotopic mass and average mass respectively for each peptide in<br>
  # the protein.<br>
  # ------------------------------------------------------------------------<br>
  # [-a ] creates annotated outputfile<br>
  #<br>
  # [-c cleavage_citeria(,cleavage_criteria...)]<br>
  # [-s ] creates summary file<br>
  # [-R ] custom modification residue value<br>
  # [-W ] custom modification weight differential<br>
  # [-I ] ICAT modification on Cys<br>
  # [-M ] MCAT modification on Arg Lys<br>
  # [-L ] minimum peptide length<br>
  # [-S ] Phosphorylation on Ser (S)<br>
  # [-T ] Phosphorylation on Thr (T)<br>
  # [-Y ] Phosphorylation on Tyr (Y)<br>
  # [-C ] peptide modificaiton:complete<br>
  # [-N ] peptide modificaiton:incomplete<br>
  # [-G ] number of missed cleavages<br>
  # [-P ] include only modified peptides in output<br>
  # [-H ] display redundant peptides<br>
  # [-h ] help<br>
  #<br>
  # Authors: Thanuja Premawardena and Shiva Amiri<br>
  # Emili Proteomics Lab, University of Toronto<br>
  #<br>
  ##########################################################################<br>
</p>
<p>use Term::ANSIColor;<br>
  # a constant the mass of water<br>
  use constant WATER =&gt; 18;</p>
<p>use strict;<br>
  srand;</p>
<p># isotopic masses of 20 amino acids<br>
  my $mass_A = 71.03711; my $mass_C = 103.00919; my $mass_D = 115.02694; my $mass_E = 129.04259; my $mass_F = 147.06841;<br>
  my $mass_H = 137.05891; my $mass_I = 113.08406; my $mass_K = 128.09496; my $mass_L = 113.08406; my $mass_M = 131.04049;<br>
  my $mass_N = 114.04293; my $mass_P = 97.05276; my $mass_Q = 128.05858; my $mass_R = 156.10111; my $mass_S = 87.03203;<br>
  my $mass_G = 57.02146; my $mass_T = 101.04768; my $mass_V = 99.06841; my $mass_W= 186.07931; my $mass_Y = 163.06333;</p>
<p># average masses of 20 amino acids<br>
  my $amass_A = 71.0788; my $amass_C = 103.1388; my $amass_D = 115.0866; my $amass_E = 129.1155; my $amass_F = 147.1766;<br>
  my $amass_H = 137.1411; my $amass_I = 113.1594; my $amass_K = 128.1741; my $amass_L = 113.1411; my $amass_M = 131.1926;<br>
  my $amass_N = 114.1038; my $amass_P = 97.1167; my $amass_Q = 128.1307; my $amass_R = 156.1875; my $amass_S = 87.0782;<br>
  my $amass_G = 57.0519; my $amass_T = 101.1051; my $amass_Y = 163.1760; my $amass_V = 99.1326; my $amass_W= 186.2132;</p>
<p># isotopic masses of 20 amino acids with the incomplete modifications<br>
  my $mass_a = 71.03711; my $mass_c = 103.00919 + 8.00; my $mass_d = 115.02694; my $mass_e = 129.04259; my $mass_f = 147.06841;<br>
  my $mass_h = 137.05891; my $mass_i = 113.08406; my $mass_k = 128.09496 +<br>
  42; my $mass_l = 113.08406; my $mass_m = 131.04049;<br>
  my $mass_n = 114.04293; my $mass_p = 97.05276; my $mass_q = 128.05858;<br>
  my $mass_r = 156.10111; my $mass_s = 87.03203 + 80.00;<br>
  my $mass_g = 57.02146; my $mass_t = 101.04768 + 80.00; my $mass_v = 99.06841;<br>
  my $mass_w= 186.07931; my $mass_y = 163.06333 + 80.00;</p>
<p># average masses of 20 amino acids with the incomplete modifications<br>
  my $amass_a = 71.0788; my $amass_c = 103.1388 + 8.00; my $amass_d = 115.0866; my $amass_e = 129.1155; my $amass_f = 147.1766;<br>
  my $amass_h = 137.1411; my $amass_i = 113.1594; my $amass_k = 128.1741 +<br>
  42.00; my $amass_l = 113.1411; my $amass_m = 131.1926;<br>
  my $amass_n = 114.1038; my $amass_p = 97.1167; my $amass_q = 128.1307;<br>
  my $amass_r = 156.1875; my $amass_s = 87.0782 + 80.00;<br>
  my $amass_g = 57.0519; my $amass_t = 101.1051 + 80.00; my $amass_y = 163.1760 +<br>
  80.00; my $amass_v = 99.1326; my $amass_w= 186.2132;</p>
<p># isotopic masses of 20 amino acids for calculating total protein mass<br>
  my $mass_a_P = 71.03711; my $mass_c_P = 103.00919; my $mass_d_P = 115.02694; my $mass_e_P = 129.04259; my $mass_f_P = 147.06841;<br>
  my $mass_h_P = 137.05891; my $mass_i_P = 113.08406; my $mass_k_P = 128.09496; my $mass_l_P = 113.08406; my $mass_m_P = 131.04049;<br>
  my $mass_n_P = 114.04293; my $mass_p_P = 97.05276; my $mass_q_P = 128.05858; my $mass_r_P = 156.10111; my $mass_s_P = 87.03203;<br>
  my $mass_g_P = 57.02146; my $mass_t_P = 101.04768; my $mass_v_P = 99.06841; my $mass_w_P = 186.07931; my $mass_y_P = 163.06333;</p>
<p># average masses of 20 amino acids for calculating total protein mass<br>
  my $amass_a_P = 71.0788; my $amass_c_P = 103.1388; my $amass_d_P = 115.0866; my $amass_e_P = 129.1155; my $amass_f_P = 147.1766;<br>
  my $amass_h_P = 137.1411; my $amass_i_P = 113.1594; my $amass_k_P = 128.1741; my $amass_l_P = 113.1411; my $amass_m_P = 131.1926;<br>
  my $amass_n_P = 114.1038; my $amass_p_P = 97.1167; my $amass_q_P = 128.1307; my $amass_r_P = 156.1875; my $amass_s_P = 87.0782;<br>
  my $amass_g_P = 57.0519; my $amass_t_P = 101.1051; my $amass_y_P = 163.1760; my $amass_v_P = 99.1326; my $amass_w_P = 186.2132;</p>
<p># the number of each amino acid in each peptide<br>
  my $ACount = 0; my $CCount = 0; my $DCount = 0; my $ECount = 0; my $FCount = 0;<br>
  my $GCount = 0; my $HCount = 0; my $ICount = 0; my $KCount = 0; my $LCount = 0;<br>
  my $MCount = 0; my $NCount = 0; my $PCount = 0; my $QCount = 0; my $RCount = 0;<br>
  my $SCount = 0; my $TCount = 0; my $VCount = 0; my $WCount = 0; my $YCount = 0;</p>
<p># the count of each amino acid in each protein<br>
  my $totalACount = 0; my $totalCCount = 0; my $totalDCount = 0; my $totalECount = 0;<br>
  my $totalFCount = 0; my $totalGCount = 0; my $totalHCount = 0; my $totalICount = 0;<br>
  my $totalKCount = 0; my $totalLCount = 0; my $totalMCount = 0; my $totalNCount = 0;<br>
  my $totalPCount = 0; my $totalQCount = 0; my $totalRCount = 0; my $totalSCount = 0;<br>
  my $totalTCount = 0; my $totalVCount = 0; my $totalWCount = 0; my $totalYCount = 0;</p>
<p># the count of each amino acid in each protein<br>
  my $Aexists = 0; my $Cexists = 0; my $Dexists = 0; my $Eexists = 0; my $Fexists = 0;<br>
  my $Gexists = 0; my $Hexists = 0; my $Iexists = 0; my $Kexists = 0; my $Lexists = 0;<br>
  my $Mexists = 0; my $Nexists = 0; my $Pexists = 0; my $Qexists = 0; my $Rexists = 0;<br>
  my $Sexists = 0; my $Texists = 0; my $Vexists = 0; my $Wexists = 0; my $Yexists = 0;</p>
<p>my $A; my $C; my $D; my $E; my $F; my $G; my $H; my $I; my $K; my $L; my $M;<br>
  my $N; my $P; my $Q; my $R; my $S; my $T; my $V; my $W; my $Y;<br>
  my $nbr; my $oldpeptide;</p>
<p># if $opt_R is defined use these variable for average mass and isotopic mass<br>
  # isotopic masses of 20 amino acids with the incomplete modifications<br>
  my $mass_aZ = 71.03711; my $mass_cZ = 103.00919; my $mass_dZ = 115.02694; my $mass_eZ = 129.04259; my $mass_fZ = 147.06841;<br>
  my $mass_hZ = 137.05891; my $mass_iZ = 113.08406; my $mass_kZ = 128.09496; my $mass_lZ = 113.08406; my $mass_mZ = 131.04049;<br>
  my $mass_nZ = 114.04293; my $mass_pZ = 97.05276; my $mass_qZ = 128.05858; my $mass_rZ = 156.10111; my $mass_sZ = 87.03203;<br>
  my $mass_gZ = 57.02146; my $mass_tZ = 101.04768; my $mass_vZ = 99.06841; my $mass_wZ= 186.07931; my $mass_yZ = 163.06333;</p>
<p># average masses of 20 amino acids with the incomplete modifications<br>
  my $amass_aZ = 71.0788; my $amass_cZ = 103.1388; my $amass_dZ = 115.0866; my $amass_eZ = 129.1155; my $amass_fZ = 147.1766;<br>
  my $amass_hZ = 137.1411; my $amass_iZ = 113.1594; my $amass_kZ = 128.1741; my $amass_lZ = 113.1411; my $amass_mZ = 131.1926;<br>
  my $amass_nZ = 114.1038; my $amass_pZ = 97.1167; my $amass_qZ = 128.1307; my $amass_rZ = 156.1875; my $amass_sZ = 87.0782;<br>
  my $amass_gZ = 57.0519; my $amass_tZ = 101.1051; my $amass_yZ = 163.1760; my $amass_vZ = 99.1326 ; my $amass_wZ = 186.2132;</p>
<p># the number of acidic and basic residues in the proteome<br>
  my $acidic_count = 0;<br>
  my $basic_count = 0;<br>
  my $polar_count = 0;<br>
  my $nonpolar_count = 0;</p>
<p>my $prot_acid_count = 0;<br>
  my $prot_basic_count = 0;<br>
  my $prot_polar_count = 0;<br>
  my $prot_nonpolar_count = 0;<br>
  my $prot_iso_mass = 0;<br>
  my $prot_ave_mass = 0;</p>
<p># this hash holds the redundancy for each peptide in the protein<br>
  my %redun_hash = ();<br>
  my @counter_array;<br>
  my $seq;<br>
  my $num = 0;<br>
</p>
<p>#the missed cleavages by default<br>
  my $missed_cleavage =0;<br>
  my $peptide_length = 2;</p>
<p># variables used to edit cleavage</p>
<p>my $totalavemass=0; # initialization of masses<br>
  my $totalisomass = 0; # initialization of masses<br>
  my $totalisoEpoint = 0;</p>
<p>my $protein_name; # vairable that stores the name of the protein<br>
  my $protein; # each protein in the file<br>
  my $protein1; # the protein being separated into peptides<br>
  my $numpep =0; # initialization of number of peptides in each protein<br>
  my $peptide;<br>
  my @breakAt; # stores the cleavages<br>
  my @breakAt2;<br>
  my @first_nums;<br>
  my @second_nums;<br>
  my @positions;<br>
  my @joined;<br>
  my $key;<br>
  my $input_file; # name of the input fasta file<br>
  my $range;<br>
  my %peptide_hash; # keys are the range (position) of the peptide in the file</p>
<p>my @amino_acid_protein; # this hash keeps track of counts of amino acids per protein<br>
  # this is a multi dimensional array<br>
  my @aminoacids_count_protein;</p>
<p># this has keeps track of counts of amino acids per peptide this is a multi<br>
  # dimensional array. The zeroth column of this array stores all 20 amino<br>
  # acids. Every row also stores the MAX amount of columns to keep a count of<br>
  # proteins that has peptides with 0..MAX-1 amount of given amino acid<br>
  my @amino_acid_peptide;<br>
  # user can change the MAX to any number then like<br>
  use constant MAX =&gt; 20;</p>
<p>my @aminoacids_count_peptide;<br>
</p>
<p>my $totalPeptides; # this variable stores the total number of peptides in the proteome<br>
  my $totalProteins; # this variable stores the total number of proteins in the proteome</p>
<p>my @isoMass_protein; # array to store isoMass of each protein<br>
  my @avgMass_protein; # array to store the avgMass of each protein<br>
  my @len_protein; # array to store the lengths of each protein</p>
<p>my @peptides_protein; # keeps track of peptide length for each protein</p>
<p>my @AA_perProtein; # keeps all the amino acid per protein</p>
<p>my @isoMass_peptide; # array to store isoMass of each peptide<br>
  my @avgMass_peptide; # array to store the avgMass of each peptide<br>
  my @len_peptide; # array to store the lengths of each peptide<br>
  my @charge_peptide; # array to store the charge of every peptide</p>
<p>my @hydrophobicity_peptide;#holds the hydrophobicity values for each peptide</p>
<p># this is for proteins<br>
  my $totalIsoMass; # keeps the total IsoMass<br>
  my $totalAvgMass; # keeps the total AvgMass<br>
  my $totalLen;<br>
  my $totalPepds; # stores the peptides for each protein<br>
  my $totalHDPcity; # stores the hydrophobicity for each pepetide</p>
<p>my @amino_acids; # stores teh amino acids that are specified in residue</p>
<p>my $user_input_commandline=join(@ARGV,&quot; &quot;); # the commandline arugment typed by the user<br>
</p>
<p>my $k; my $j; my $f; my $s;<br>
  $totalPeptides = 0;<br>
  $totalProteins = 0;</p>
<p># this is for proteins<br>
  $totalIsoMass = 0;<br>
  $totalAvgMass = 0;<br>
  $totalLen = 0;<br>
  $totalPepds = 0;</p>
<p>my $display_redun=0;</p>
<p>use Getopt::Std;<br>
  # options to run the program<br>
  use vars qw($opt_i $opt_d $opt_a $opt_c $opt_s $opt_S $opt_T $opt_Y $opt_R $opt_W $opt_I $opt_M<br>
  $opt_C $opt_N $opt_G $opt_L $opt_H $opt_h );<br>
</p>
<p>$opt_i=&quot;&quot;; # input file name<br>
  #$opt_d = 1; # simple output file<br>
  #$opt_a = 1; # annotated output file<br>
  $opt_s = 1; # summary file<br>
  # $opt_c, # cleavage criteria(AA's seperated by commas)<br>
  # $opt_S,# Phosphorylation on Ser (S)<br>
  # $opt_T,# Phosphorylation on Thr (T)<br>
  # $opt_Y,# Phosphorylation on Tyr (Y)<br>
  # $opt_R, # custom modification residue<br>
  # $opt_W, # custom modification weight differential<br>
  # $opt_I, # ICAT modification on Cys<br>
  # $opt_M, # MCAT modification on Arg Lys<br>
  # $opt_C,# peptide modificaiton:complete<br>
  # $opt_N,# peptide modificaiton:incomplete</p>
<p># $opt_G,# number of missed cleavages<br>
  # $opt_L, # minimum peptide length</p>
<p># $opt_P,# include only modified peptides in output<br>
  # $opt_H,# display redundant peptides</p>
<p>$opt_h=0; # help<br>
  # get the processing options</p>
<p>#***********************USER DEFINED VALUES ************************</p>
<p># specifies the option user enters in.<br>
  if ( ! getopts('i:dasc:STYR:W:IMCNG:L:Hh')) {<br>
  error_msg();<br>
  exit;<br>
  }<br>
  $user_input_commandline= $Getopt::Std;</p>
<p>print &quot;$user_input_commandline\n&quot;; <br>
</p>
<p>checkArgs();<br>
  sub error_msg{<br>
  print STDERR &quot;USAGE: $0 \n&quot;,<br>
&quot;\t[-i input_file_name-protein sequence in fasta format]\n&quot;,<br>
&quot;\t[-d ] creates simple.txt output file\n&quot;,<br>
&quot;\t[-a ] creates annotated outputfile\n&quot;,<br>
&quot;\t[-c cleavage_citeria(,cleavage_criteria...)]\n&quot;,<br>
&quot;\t[-s ] creates summary file\n&quot;,<br>
&quot;\t[-R custom modification residue value]\n&quot;,<br>
&quot;\t[-W custom modification weight differential]\n&quot;,<br>
&quot;\t[-I ] ICAT modification on Cys\n&quot;,<br>
&quot;\t[-M ] MCAT modification on Arg Lys\n&quot;,<br>
&quot;\t[-L minimum peptide length]\n&quot;,<br>
&quot;\t[-S ] Phosphorylation on Ser (S)\n&quot;,<br>
&quot;\t[-T ] Phosphorylation on Thr (T)\n&quot;,<br>
&quot;\t[-Y ] Phosphorylation on Tyr (Y)\n&quot;,<br>
&quot;\t[-C ] peptide modificaiton:complete\n&quot;,<br>
&quot;\t[-N ] peptide modificaiton:incomplete\n&quot;,<br>
&quot;\t[-G number of missed cleavages]\n&quot;,<br>
&quot;\t[-H ] display redundant peptides\n&quot;,<br>
&quot;\t[-h ] help\n\n&quot;;<br>
  }</p>
<p># take care of the commandline arguments<br>
  sub checkArgs{<br>
  # **********$opt_h is the help option*********************#<br>
  if($opt_h ==1){<br>
  print &quot;\n\nProtein Cleavage and Classification Options\n&quot;;<br>
  print &quot;===========================================\n\n&quot;;<br>
  print &quot;Options:\n&quot;;<br>
  print &quot; [-i input_file_name-protein sequence in fasta format]]\n&quot;;<br>
  print &quot; [-d ] creates simple.txt output file\n&quot;;<br>
  print &quot; [-a ] creates annotated outputfile\n&quot;;<br>
  print &quot; [-c cleavage_citeria(,cleavage_criteria...)]\n&quot;;<br>
  print &quot; [-s ] creates summary file\n&quot;;<br>
  print &quot; [-R custom modification residue value]\n&quot;;<br>
  print &quot; [-W custom modification weight differential]\n&quot;;<br>
  print &quot; [-I ] ICAT modification on Cys\n&quot;;<br>
  print &quot; [-M ] MCAT modification on Arg Lys\n&quot;;<br>
  print &quot; [-L minimum peptide length]\n&quot;;<br>
  print &quot; [-S ] Phosphorylation on Ser (S)\n&quot;;<br>
  print &quot; [-T ] Phosphorylation on Thr (T)\n&quot;;<br>
  print &quot; [-Y ] Phosphorylation on Tyr (Y)\n&quot;;<br>
  print &quot; [-C ] peptide modificaiton:complete\n&quot;;<br>
  print &quot; [-N ] peptide modificaiton:incomplete\n&quot;;<br>
  print &quot; [-G number of missed cleavages]\n&quot;;<br>
  print &quot; [-H ] display redundant peptides\n&quot;;<br>
  print &quot; [-h ] help\n&quot;;<br>
  exit;<br>
  }<br>
  # *******opt_i input file name ********<br>
  if ($opt_i=~ /^$/){ # user must specify a valid input file name<br>
  error_msg();<br>
  exit;<br>
  }# check whether input file exists, readable and it is a non empty file<br>
  elsif(-e $opt_i &amp;&amp; -r $opt_i &amp;&amp; -s $opt_i){<br>
  my $c = 0;<br>
  open(INPUT_FASTA, &quot;&lt;$opt_i&quot;) || die &quot; Cannot open file $opt_i\n&quot;;<br>
  open(FASTA, &quot;&lt;$opt_i&quot;) || die &quot; Cannot open file $opt_i\n&quot;;<br>
  # check whether this file is fasta formated<br>
  while(&lt;FASTA&gt;){<br>
  if($_ =~ /^&gt;/ &amp;&amp; $c ==0){<br>
  close(FASTA);<br>
  <br>
  last;<br>
  }<br>
  else{<br>
  print &quot;Not a valid FASTA file. Please re-run the program with a valid FASTA file\n&quot;;<br>
  close(FASTA);<br>
  exit;<br>
  }<br>
  } #end while</p>
<p> $input_file = $opt_i;<br>
  # takes away all the letters followed by the . for the appending for the outputfile<br>
  $opt_i =~ s/(\..*)$//;<br>
  } #end else if<br>
  else{<br>
  print &quot;$opt_i doesn't exist,no read access or no data in the file\n&quot;;<br>
  exit(0);<br>
  }<br>
</p>
<p> # *******opt_c cleavage criteria ********<br>
  if ($opt_c =~ /^$/){ # user must specify a valid cleavage criteria<br>
  print STDERR &quot;You must enter a valid cleavage criteria\n&quot;;<br>
  error_msg();<br>
  exit;<br>
  }</p>
<p> my $cleavage = $opt_c;<br>
    <br>
  my $builder = &quot;&quot;;<br>
  my $builder2 = &quot;&quot;;<br>
  my $builder3 = &quot;&quot;;<br>
  my $tryp_flag1 = 0;<br>
  my $tryp_flag2 = 0;<br>
  my @AAs = (&quot;A&quot;,&quot;C&quot;,&quot;D&quot;,&quot;E&quot;,&quot;F&quot;,&quot;G&quot;,&quot;H&quot;,&quot;I&quot;,&quot;K&quot;,&quot;L&quot;,&quot;M&quot;,&quot;N&quot;,&quot;P&quot;,&quot;Q&quot;,&quot;R&quot;,&quot;S&quot;,&quot;T&quot;,&quot;V&quot;,&quot;W&quot;,&quot;Y&quot;);<br>
  $cleavage =~ tr/a-z/A-Z/;<br>
  if ($cleavage =~ /[^A-Z,]/) {<br>
  print STDERR &quot;You must enter a valid cleavage criteria\n&quot;;<br>
  error_msg();<br>
  exit;<br>
  }</p>
<p> elsif ($cleavage =~ /[A-Z,]/){<br>
  my $temp_cleave = $cleavage;<br>
  my @splices = split(/,/,$temp_cleave);<br>
  for (my $i=0; $i&lt;=$#splices; $i++) {<br>
  if ($splices[$i]=~/Z/) {<br>
  for ($j=0; $j&lt;=$#AAs; $j++) {<br>
  my $wildcard = $splices[$i];<br>
  $wildcard =~ s/Z/$AAs[$j]/;<br>
  $wildcard = $wildcard.&quot;,&quot;;<br>
  $builder = $builder.$wildcard;<br>
  }<br>
  }<br>
  if ($splices[$i] =~ /TRYPSIN/) {<br>
  splice(@splices, $i, 1);<br>
  $tryp_flag1 = 1; </p>
<p> }<br>
  }<br>
  <br>
  if ($tryp_flag1 == 1) {<br>
  $builder2 =<br>
&quot;KXA,KXC,KXD,KXE,KXF,KXG,KXH,KXI,KXK,KXL,KXM,KXN,KXQ,KXR,KXS,KXT,KXV,KXY,KXW,RXA,RXC,RXD,RXE,RXF,RXG,RXH,RXI,RXK,RXL,RXM,RXN,RXQ,RXR,RXS,RXT,RXV,RXY,RXW&quot;;<br>
  for (my $k = 0; $k &lt;= $#splices; $k++) {<br>
  $builder3 = $builder3.$splices[$k].&quot;,&quot;;</p>
<p> }<br>
  $cleavage = $builder3.$builder2;<br>
  }<br>
  else {<br>
  $cleavage = $cleavage.&quot;,&quot;;<br>
  $cleavage = $cleavage.$builder;<br>
  }<br>
  if($cleavage=~/^,/){ # removes the leading commas from cleavage<br>
  $cleavage =~ s/^,+//;<br>
  }<br>
  if($cleavage=~/,$/){ # removes the trailing commas from cleavage<br>
  $cleavage =~ s/\,+$//;<br>
  }<br>
  @breakAt = split(/,/,$cleavage);<br>
  <br>
  for ($k=0; $k&lt;=$#breakAt; $k++) {<br>
  if ($breakAt[$k] =~ /Z/){<br>
  splice(@breakAt, $k, 1);<br>
  $k = $k-1;<br>
  }<br>
  }</p>
<p> for (my $a=0; $a&lt;=$#breakAt; $a++) {<br>
  push(@breakAt2, $breakAt[$a]);<br>
  }<br>
</p>
<p> for my $j (0 .. $#breakAt){<br>
  $breakAt[$j] =~ s/X//g;<br>
  }<br>
  }</p>
<p> my $simple_file_name;<br>
  my $annotated_file_name;<br>
  my $summary_file_name;<br>
  # *******opt_d creates simple.txt output file ********<br>
  if ($opt_d==1){<br>
  # name of the simple.txt output file<br>
  $simple_file_name = &quot;$opt_i&quot;.&quot;_simple.txt&quot;;<br>
  open (SIMPLE, &quot;&gt;$simple_file_name&quot;)|| die &quot;Cannot open $simple_file_name $!&quot;;</p>
<p> }<br>
</p>
<p> # *******opt_a creates annotated outputfile ********<br>
  if ($opt_a==1){<br>
  # name of the annotated.txt output file<br>
  $annotated_file_name = &quot;$opt_i&quot;.&quot;_annotated.txt&quot;;<br>
  open (ANNOTATED, &quot;&gt;$annotated_file_name&quot;)|| die &quot;Cannot open $annotated_file_name $!&quot;;<br>
  }<br>
</p>
<p> # *******opt_s creates summary file ********<br>
  if ($opt_s==1){ # if user specify for the summary then the summary will be written<br>
  # name of the summary output file<br>
  $summary_file_name = &quot;summary.html&quot;;<br>
  #$summary_file_name = &quot;/home/thanuja/public_html/proteogest/summary.html&quot;;<br>
  open (SUMMARY, &quot;&gt;$summary_file_name&quot;)|| die &quot;Cannot open $summary_file_name $!&quot;;<br>
  }<br>
  # *******$opt_L minimum peptide length. default is 2********<br>
  # user specifies the miminum length of peptides to include in the<br>
  # analysis<br>
  if (defined($opt_L) &amp;&amp; $opt_L&gt;0){<br>
  $peptide_length = $opt_L;<br>
  }<br>
</p>
<p> # *******$opt_G number of missed cleavages default is 0********<br>
  if (defined($opt_G) &amp;&amp; $opt_G &gt;0){<br>
  $missed_cleavage = $opt_G;<br>
  }<br>
</p>
<p> # *******$opt_S Phosphorylation on Ser (S)********<br>
  if($opt_S ==1 &amp;&amp; $opt_N==0){<br>
  # add 80 to Ser<br>
  $mass_S = $mass_S + 80.00;<br>
  $amass_S = $amass_S + 80.00;<br>
  }<br>
</p>
<p> # *******$opt_T Phosphorylation on Thr (T)********<br>
  if($opt_T ==1 &amp;&amp; $opt_N==0){<br>
  # add 80 to Thr<br>
  $mass_T = $mass_T + 80.00;<br>
  $amass_T = $amass_T + 80.00;<br>
  }<br>
</p>
<p> # *******$opt_Y Phosphorylation on Tyr (Y)********<br>
  if($opt_Y ==1 &amp;&amp; $opt_N==0){<br>
  # add 80 to Tyr<br>
  $mass_Y = $mass_Y + 80.00;<br>
  $amass_Y = $amass_Y + 80.00;<br>
  }<br>
</p>
<p> # *******$opt_I ICAT modification on Cys (C)********<br>
  #if ($opt_I==1 &amp;&amp; $opt_N==0){<br>
  # $mass_C = $mass_C + 8.00;<br>
  # $amass_C = $amass_C + 8.00;</p>
<p> #}</p>
<p> # *******$opt_M MCAT modification on Arg Lys ********<br>
  if ($opt_M==1 &amp;&amp; $opt_N==0){<br>
  $mass_K = $mass_K + 42.00;<br>
  $amass_K = $amass_K + 42.00;<br>
  }</p>
<p> # *******$opt_R custom modification residue value ********<br>
  if (defined($opt_R) &amp;&amp; ($opt_R =~ /^$/)){ # user must specify a valid positive integer<br>
  print STDERR &quot; Custom Modification Error: Please specify a valid Amino Acid and re-run the program\n&quot;;<br>
  exit;<br>
  }<br>
  # translate small case to upper case<br>
  $opt_R =~ tr/a-z/A-Z/;</p>
<p> # if $opt_R is not a letter then send an error message<br>
  if(defined($opt_R) &amp;&amp; ($opt_R =~/[^A-Z,]/)){<br>
  print STDERR &quot; Custom Modification Error: Please specify a valid Amino Acid and re-run the program\n&quot;;<br>
  exit;<br>
  }<br>
  # check whether it is a valid amino acid<br>
  elsif(defined($opt_R) &amp;&amp; ($opt_R =~/B/ || $opt_R =~/J/ || $opt_R =~/O/ || $opt_R =~/U/ || $opt_R =~/X/ || $opt_R =~/Z/)){<br>
  print STDERR &quot; Custom Modification Error: Please specify a valid Amino Acid and re-run the program\n&quot;;<br>
  exit;<br>
  }<br>
</p>
<p> # *******$opt_W custom modification weight differential********<br>
  if (defined($opt_W) &amp;&amp; ($opt_R) &amp;&amp; ($opt_W =~ /^$/ )){ # user must specify a valid positive real integer<br>
  print STDERR &quot; Custom Modification Error: Please specify Weight differential and re-run the program\n&quot;;<br>
  exit;<br>
  }<br>
  elsif($opt_W !~ /^-?\d+\.?\d*$/ &amp;&amp; $opt_R){<br>
  # check whether the weight is valid positive real integer<br>
  print STDERR &quot;Custom Modification Error: Invalid weight differential: $opt_W\nPlease re-run the program\n&quot;;<br>
  exit;<br>
  }</p>
<p> @amino_acids = split(/,/,$opt_R);<br>
  foreach my $amino_acid (@amino_acids){<br>
  if(length($amino_acid) &gt;1){<br>
  print STDERR &quot; Please specify Amino Acid seperated by commas (eg: R,T,A) and re-run the program\n&quot;;<br>
  exit;<br>
  }<br>
  }<br>
  # now add the given weight to the given AA<br>
  if($opt_R &amp;&amp; $opt_W &amp;&amp; $opt_N!=1){<br>
  sleep 5;<br>
  foreach my $amino_acid (@amino_acids){<br>
  if($amino_acid =~ /^A$/){<br>
  $mass_A = $mass_A + $opt_W;<br>
  $amass_A = $amass_A + $opt_W;<br>
  }<br>
  if($amino_acid =~ /^C$/){<br>
  $mass_C = $mass_C + $opt_W;<br>
  $amass_C = $amass_C+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^D$/){<br>
  $mass_D = $mass_D + $opt_W;<br>
  $amass_D = $amass_D+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^E$/){<br>
  $mass_E = $mass_E + $opt_W;<br>
  $amass_E = $amass_E+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^F$/){<br>
  $mass_F = $mass_F + $opt_W;<br>
  $amass_F = $amass_F+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^G$/){<br>
  $mass_G = $mass_G + $opt_W;<br>
  $amass_G = $amass_G+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^H$/){<br>
  $mass_H = $mass_H + $opt_W;<br>
  $amass_H = $amass_H+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^I$/){<br>
  $mass_I = $mass_I + $opt_W;<br>
  $amass_I = $amass_I+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^K$/){<br>
  $mass_K = $mass_K + $opt_W;<br>
  $amass_K = $amass_K+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^L$/){<br>
  $mass_L = $mass_L + $opt_W;<br>
  $amass_L = $amass_L+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^M$/){<br>
  $mass_M = $mass_M + $opt_W;<br>
  $amass_M = $amass_M+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^N$/){<br>
  $mass_N = $mass_N + $opt_W;<br>
  $amass_N = $amass_N+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^P$/){<br>
  $mass_P = $mass_P + $opt_W;<br>
  $amass_P = $amass_P+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^Q$/){<br>
  $mass_Q = $mass_Q + $opt_W;<br>
  $amass_Q = $amass_Q+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^R$/){<br>
  $mass_R = $mass_R + $opt_W;<br>
  $amass_R = $amass_R+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^S$/){<br>
  $mass_S = $mass_S + $opt_W;<br>
  $amass_S = $amass_S+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^T$/){<br>
  $mass_T = $mass_T + $opt_W;<br>
  $amass_T = $amass_T+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^V$/){<br>
  $mass_V = $mass_V + $opt_W;<br>
  $amass_V = $amass_V+ $opt_W;<br>
  }<br>
  if($amino_acid =~ /^W$/){<br>
  $mass_W = $mass_W + $opt_W;<br>
  $amass_W = $amass_W+ $opt_W;</p>
<p> }<br>
  if($amino_acid =~ /^Y$/){<br>
  $mass_Y = $mass_Y + $opt_W;<br>
  $amass_Y = $amass_Y+ $opt_W;<br>
  }<br>
  } # end for<br>
  } # end if<br>
</p>
<p> # *******$opt_N peptide modificaiton:incomplete ********<br>
  if ($opt_N==1){<br>
  # tricky<br>
  }</p>
<p> # Now display to STDOUT the options selected<br>
  print &quot;Protein Cleavage and Classification\n&quot;;<br>
  print &quot;===================================\n\n&quot;;<br>
  print &quot;Options:\n&quot;;<br>
  print &quot; input FASTA file:\t $input_file\n&quot;;<br>
  print &quot; cleavage criteria:\t $cleavage\n&quot;;<br>
  if ($opt_d==1){print &quot; simple output file:\t $simple_file_name\n&quot;;}<br>
  if ($opt_a==1){print &quot; annotated output file:\t$annotated_file_name\n&quot;;}<br>
  if ($opt_s==1){print &quot; summary file: $summary_file_name\n&quot;;}<br>
  print &quot; minimum peptide length:\t$peptide_length\n&quot;;<br>
  print &quot; number of missed cleavages:\t$missed_cleavage\n&quot;;<br>
  if ($opt_S ==1){print &quot; Phosphorylation on Ser (S)\n&quot;;}<br>
  if ($opt_T ==1){print &quot; Phosphorylation on Thr (T)\n&quot;;}<br>
  if ($opt_Y ==1){print &quot; Phosphorylation on Tyr (Y)\n&quot;;}<br>
  if ($opt_I ==1){print &quot; ICAT modification on Cys (C)\n&quot;;}<br>
  if ($opt_M ==1){print &quot; MCAT modification on Arg Lys\n&quot;;}<br>
  if ($opt_N ==1){print &quot; peptide modificaiton:incomplete\n&quot;;}<br>
  if ($opt_H ==1){print &quot; display redundant peptides\n&quot;;}<br>
  if (defined($opt_R)){print &quot; custom modification residue value on : $opt_R\n&quot;;}<br>
  if (defined($opt_W)){print &quot; custom modification weight differential is: $opt_W\n&quot;;}<br>
  #*******************************************************************<br>
  print &quot;\n\n&quot;;<br>
  print &quot;Running proteogest..\n&quot;;<br>
  print &quot;\n\n&quot;;<br>
  } # end sub<br>
</p>
<p>open(PEPTIDES, &quot;&gt;peptides.txt&quot;) || die &quot;Cannot open peptides.txt $!&quot;;<br>
</p>
<p># formatting the output for output file1<br>
  format SIMPLE =<br>
  @####### @&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt; @#####.##### @#####.##### @&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;<br>
  $numpep, $range, $totalisomass, $totalavemass, $peptide<br>
  .</p>
<p># formatting the output for output file2<br>
  format ANNOTATED=<br>
  @&gt;&gt;&gt;&gt;&gt;&gt;&gt; @###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@### @&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;<br>
  $nbr, $A, $C, $D, $E, $F, $G, $H, $I, $K, $L, $M, $N, $P, $Q, $R, $S, $T, $V, $W, $Y, $oldpeptide<br>
  .</p>
<p># formatting the output for standard out<br>
  format STDOUT=<br>
  @###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###@###<br>
  $A, $C, $D, $E, $F, $G, $H, $I, $K, $L, $M, $N, $P, $Q, $R, $S, $T, $V, $W, $Y<br>
  .</p>
<p># formatting the output for standard out<br>
  format PEPTIDES=<br>
  @&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;&lt;<br>
  $peptide<br>
  .<br>
</p>
<p># this subroutine gets called to initialize the multi-dimensional array to<br>
  # store peptide statistics analysis displayed in the summary file.<br>
  initilizePeptideStatisticsArray();</p>
<p># calls the main subroutine<br>
  main();</p>
<p># sub routine::comparison function<br>
  # compares the lengths of 2 arrays<br>
  sub by_length{<br>
  $f = length $a;<br>
  $s = length $b;<br>
  $s&lt;=&gt;$f;<br>
  }</p>
<p>&nbsp;</p>
<p># reinitializes the variables<br>
  sub reinitialize{<br>
  $totalIsoMass = 0;<br>
  $totalAvgMass = 0;<br>
  $totalLen = 0;<br>
  $totalPepds = 0;</p>
<p> undef @aminoacids_count_protein;</p>
<p> $totalACount = 0; $totalCCount = 0; $totalDCount = 0; $totalECount = 0;<br>
  $totalFCount = 0; $totalGCount = 0; $totalHCount = 0; $totalICount = 0;<br>
  $totalKCount = 0; $totalLCount = 0; $totalMCount = 0; $totalNCount = 0;<br>
  $totalPCount = 0; $totalQCount = 0; $totalRCount = 0; $totalSCount = 0;<br>
  $totalTCount = 0; $totalVCount = 0; $totalWCount = 0; $totalYCount = 0;</p>
<p> $Aexists = 0; $Cexists = 0; $Dexists = 0; $Eexists = 0; $Fexists = 0;<br>
  $Gexists = 0; $Hexists = 0; $Iexists = 0; $Kexists = 0; $Lexists = 0;<br>
  $Mexists = 0; $Nexists = 0; $Pexists = 0; $Qexists = 0; $Rexists = 0;<br>
  $Sexists = 0; $Texists = 0; $Vexists = 0; $Wexists = 0; $Yexists = 0;</p>
<p> $prot_acid_count = 0;<br>
  $prot_basic_count = 0;<br>
  $prot_polar_count = 0;<br>
  $prot_nonpolar_count = 0;<br>
  $prot_iso_mass = 0;<br>
  $prot_ave_mass = 0;<br>
  }</p>
<p>&nbsp;</p>
<p># This subroutine takes care of analyzing each peptide. This subroutine takes<br>
  # care of calculting the total isotopic and average mass of each peptide. It<br>
  # also takes care of counting amino acids present in each peptide.<br>
  sub analyze_peptide{<br>
  my ($p) = $_[0];<br>
  my ($x) = $_[1];<br>
  my ($r) = $_[2];<br>
  my $complete =$_[3];<br>
  # get the value of the pointer<br>
  $peptide = $$p;<br>
  $numpep = $$x;<br>
  $range = $$r;</p>
<p> # keep this peptide for the redundancy calculations for the summary<br>
  # do only if the user requests<br>
  if($opt_H==1 &amp;&amp; $complete==1){<br>
  if(exists $redun_hash{$peptide}){<br>
  if ($peptide !~ &quot;par&quot;){<br>
  my @protein = @{$redun_hash{$peptide}};<br>
  push(@protein,$protein_name);<br>
  $redun_hash{$peptide} = [@protein];<br>
  undef @protein;<br>
  $display_redun =1;<br>
  }</p>
<p> }<br>
  else{<br>
  if (($peptide !~ &quot;par&quot;) &amp;&amp; ($peptide !~<br>
  /[a-z]/)) {<br>
  my @protein;<br>
  push(@protein,$protein_name);<br>
  <br>
  $redun_hash{$peptide} = [@protein];<br>
  undef @protein;<br>
  }<br>
  }<br>
  }</p>
<p> # initializes the counts of each amino acid back to 0, for the next peptide<br>
  $ACount = 0; $CCount = 0; $DCount = 0; $ECount = 0; $FCount = 0;<br>
  $GCount = 0; $HCount = 0; $ICount = 0; $KCount = 0; $LCount = 0;<br>
  $MCount = 0; $NCount = 0; $PCount = 0; $QCount = 0; $RCount = 0;<br>
  $SCount = 0; $TCount = 0; $VCount = 0; $WCount = 0; $YCount = 0;<br>
  # calculates the average an isotopic and average mass of each peptide<br>
  for($j = 0; $j&lt;=(length($peptide)); $j++){<br>
  if (substr($peptide, $j, 2) eq &quot;aZ&quot;){<br>
  $j= $j+1;<br>
  $totalavemass = $totalavemass + $amass_aZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_aZ + $opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;cZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_cZ +$opt_W ;<br>
  $totalisomass = $totalisomass + $mass_cZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;dZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_dZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_dZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;eZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_eZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_eZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;fZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_fZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_fZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;gZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_gZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_gZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;hZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_hZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_hZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;iZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_iZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_iZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;kZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_kZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_kZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;lZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_lZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_lZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;mZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_mZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_mZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;nZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_nZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_nZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;pZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_pZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_pZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;qZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_qZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_qZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;rZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_rZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_rZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;sZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_sZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_sZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;tZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_tZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_tZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;vZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_vZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_vZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;wZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_wZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_wZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 2) eq &quot;yZ&quot;){<br>
  $j = $j+1;<br>
  $totalavemass = $totalavemass + $amass_yZ +$opt_W;<br>
  $totalisomass = $totalisomass + $mass_yZ +$opt_W;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;A&quot;){<br>
  $totalavemass = $totalavemass + $amass_A;<br>
  $totalisomass = $totalisomass + $mass_A;<br>
  $ACount++;<br>
  $totalACount++;<br>
  $prot_iso_mass += $mass_a_P;<br>
  $prot_ave_mass += $amass_a_P;<br>
  $aminoacids_count_protein[0]=&quot;A=&quot;.&quot;$totalACount&quot;;<br>
  $nonpolar_count++;<br>
  $prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;C&quot;){<br>
  $totalavemass = $totalavemass + $amass_C;<br>
  $totalisomass = $totalisomass + $mass_C;<br>
  $CCount++;<br>
  $totalCCount++;<br>
  $prot_iso_mass += $mass_c_P;<br>
  $prot_ave_mass += $amass_c_P;<br>
  $aminoacids_count_protein[1]=&quot;C=&quot;.&quot;$totalCCount&quot;;<br>
  $nonpolar_count++;<br>
  #$prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;D&quot;){<br>
  $totalavemass = $totalavemass + $amass_D;<br>
  $totalisomass = $totalisomass + $mass_D;<br>
  $DCount++;<br>
  $totalDCount++;<br>
  $acidic_count++;<br>
  $prot_iso_mass += $mass_d_P;<br>
  $prot_ave_mass += $amass_d_P;<br>
  $aminoacids_count_protein[2]=&quot;D=&quot;.&quot;$totalDCount&quot;;<br>
  $prot_acid_count++;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;E&quot;){<br>
  $totalavemass = $totalavemass + $amass_E;<br>
  $totalisomass = $totalisomass + $mass_E;<br>
  $ECount++;<br>
  $totalECount++;<br>
  $acidic_count++;<br>
  $prot_iso_mass += $mass_e_P;<br>
  $prot_ave_mass += $amass_e_P;<br>
  $aminoacids_count_protein[3]=&quot;E=&quot;.&quot;$totalECount&quot;;<br>
  $prot_acid_count++;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;F&quot;){<br>
  $totalavemass = $totalavemass + $amass_F;<br>
  $totalisomass = $totalisomass + $mass_F;<br>
  $FCount++;<br>
  $totalFCount++;<br>
  $prot_iso_mass += $mass_f_P;<br>
  $prot_ave_mass += $amass_f_P;<br>
  $aminoacids_count_protein[4]=&quot;F=&quot;.&quot;$totalFCount&quot;;<br>
  $nonpolar_count++;<br>
  $prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;G&quot;){<br>
  $totalavemass = $totalavemass + $amass_G;<br>
  $totalisomass = $totalisomass + $mass_G;<br>
  $GCount++;<br>
  $totalGCount++;<br>
  $prot_iso_mass += $mass_g_P;<br>
  $prot_ave_mass += $amass_g_P;<br>
  $aminoacids_count_protein[5]=&quot;G=&quot;.&quot;$totalGCount&quot;;<br>
  $nonpolar_count++;<br>
  $prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;H&quot;){<br>
  $totalavemass = $totalavemass + $amass_H;<br>
  $totalisomass = $totalisomass + $mass_H;<br>
  $HCount++;<br>
  $totalHCount++;<br>
  $prot_iso_mass += $mass_h_P;<br>
  $prot_ave_mass += $amass_h_P;<br>
  $aminoacids_count_protein[6]=&quot;H=&quot;.&quot;$totalHCount&quot;;<br>
  $basic_count++;<br>
  $prot_basic_count++;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;I&quot;){<br>
  $totalavemass = $totalavemass + $amass_I;<br>
  $totalisomass = $totalisomass + $mass_I;<br>
  $ICount++;<br>
  $totalICount++;<br>
  $prot_iso_mass += $mass_i_P;<br>
  $prot_ave_mass += $amass_i_P;<br>
  $aminoacids_count_protein[7]=&quot;I=&quot;.&quot;$totalICount&quot;;<br>
  $nonpolar_count++;<br>
  $prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;K&quot;){<br>
  $totalavemass = $totalavemass + $amass_K;<br>
  $totalisomass = $totalisomass + $mass_K;<br>
  $KCount++;<br>
  $totalKCount++;<br>
  $prot_iso_mass += $mass_k_P;<br>
  $prot_ave_mass += $amass_k_P;<br>
  $aminoacids_count_protein[8]=&quot;K=&quot;.&quot;$totalKCount&quot;;<br>
  $basic_count++;<br>
  $prot_basic_count++;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;L&quot;){<br>
  $totalavemass = $totalavemass + $amass_L;<br>
  $totalisomass = $totalisomass + $mass_L;<br>
  $LCount++;<br>
  $totalLCount++;<br>
  $prot_iso_mass += $mass_l_P;<br>
  $prot_ave_mass += $amass_l_P;<br>
  $aminoacids_count_protein[9]=&quot;L=&quot;.&quot;$totalLCount&quot;;<br>
  $nonpolar_count++;<br>
  $prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;M&quot;){<br>
  $totalavemass = $totalavemass + $amass_M;<br>
  $totalisomass = $totalisomass + $mass_M;<br>
  $MCount++;<br>
  $totalMCount++;<br>
  $prot_iso_mass += $mass_m_P;<br>
  $prot_ave_mass += $amass_m_P;<br>
  $aminoacids_count_protein[10]=&quot;M=&quot;.&quot;$totalMCount&quot;;<br>
  $nonpolar_count++;<br>
  $prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;N&quot;){<br>
  $totalavemass = $totalavemass + $amass_N;<br>
  $totalisomass = $totalisomass + $mass_N;<br>
  $NCount++;<br>
  $totalNCount++;<br>
  $prot_iso_mass += $mass_n_P;<br>
  $prot_ave_mass += $amass_n_P;<br>
  $aminoacids_count_protein[11]=&quot;N=&quot;.&quot;$totalNCount&quot;;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;P&quot;){<br>
  $totalavemass = $totalavemass + $amass_P;<br>
  $totalisomass = $totalisomass + $mass_P;<br>
  $PCount++;<br>
  $totalPCount++;<br>
  $prot_iso_mass += $mass_p_P;<br>
  $prot_ave_mass += $amass_p_P;<br>
  $aminoacids_count_protein[12]=&quot;P=&quot;.&quot;$totalPCount&quot;;<br>
  $nonpolar_count++;<br>
  $prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;Q&quot;){<br>
  $totalavemass = $totalavemass + $amass_Q;<br>
  $totalisomass = $totalisomass + $mass_Q;<br>
  $QCount++;<br>
  $totalQCount++;<br>
  $prot_iso_mass += $mass_q_P;<br>
  $prot_ave_mass += $amass_q_P;<br>
  $aminoacids_count_protein[13]=&quot;Q=&quot;.&quot;$totalQCount&quot;;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }</p>
<p> elsif (substr($peptide, $j, 1) eq &quot;R&quot;){<br>
  $totalavemass = $totalavemass + $amass_R;<br>
  $totalisomass = $totalisomass + $mass_R;<br>
  $RCount++;<br>
  $totalRCount++;<br>
  $prot_iso_mass += $mass_r_P;<br>
  $prot_ave_mass += $amass_r_P;<br>
  $aminoacids_count_protein[14]=&quot;R=&quot;.&quot;$totalRCount&quot;;<br>
  $basic_count++;<br>
  $prot_basic_count++;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;S&quot;){<br>
  $totalavemass = $totalavemass + $amass_S;<br>
  $totalisomass = $totalisomass + $mass_S;<br>
  $SCount++;<br>
  $totalSCount++;<br>
  $prot_iso_mass += $mass_s_P;<br>
  $prot_ave_mass += $amass_s_P;<br>
  $aminoacids_count_protein[15]=&quot;S=&quot;.&quot;$totalSCount&quot;;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;T&quot;){<br>
  $totalavemass = $totalavemass + $amass_T;<br>
  $totalisomass = $totalisomass + $mass_T;<br>
  $TCount++;<br>
  $totalTCount++;<br>
  $prot_iso_mass += $mass_t_P;<br>
  $prot_ave_mass += $amass_t_P;<br>
  $aminoacids_count_protein[16]=&quot;T=&quot;.&quot;$totalTCount&quot;;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;V&quot;){<br>
  $totalavemass = $totalavemass + $amass_V;<br>
  $totalisomass = $totalisomass + $mass_V;<br>
  $VCount++;<br>
  $totalVCount++;<br>
  $prot_iso_mass += $mass_v_P;<br>
  $prot_ave_mass += $amass_v_P;<br>
  $aminoacids_count_protein[17]=&quot;V=&quot;.&quot;$totalVCount&quot;;<br>
  $nonpolar_count++;<br>
  $prot_nonpolar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;W&quot;){<br>
  $totalavemass = $totalavemass + $amass_W;<br>
  $totalisomass = $totalisomass + $mass_W;<br>
  $WCount++;<br>
  $totalWCount++;<br>
  $prot_iso_mass += $mass_w_P;<br>
  $prot_ave_mass += $amass_w_P;<br>
  $aminoacids_count_protein[18]=&quot;W=&quot;.&quot;$totalWCount&quot;;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;Y&quot;){<br>
  $totalavemass = $totalavemass + $amass_Y;<br>
  $totalisomass = $totalisomass + $mass_Y;<br>
  $YCount++;<br>
  $totalYCount++;<br>
  $prot_iso_mass += $mass_y_P;<br>
  $prot_ave_mass += $amass_y_P;<br>
  $aminoacids_count_protein[19]=&quot;Y=&quot;.&quot;$totalYCount&quot;;<br>
  $polar_count++;<br>
  $prot_polar_count++;<br>
  }<br>
</p>
<p> elsif (substr($peptide, $j, 1) eq &quot;a&quot;){<br>
  $totalavemass = $totalavemass + $amass_a;<br>
  $totalisomass = $totalisomass + $mass_a;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;c&quot;){<br>
  $totalavemass = $totalavemass + $amass_c;<br>
  $totalisomass = $totalisomass + $mass_c;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;d&quot;){<br>
  $totalavemass = $totalavemass + $amass_d;<br>
  $totalisomass = $totalisomass + $mass_d;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;e&quot;){<br>
  $totalavemass = $totalavemass + $amass_e;<br>
  $totalisomass = $totalisomass + $mass_e;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;f&quot;){<br>
  $totalavemass = $totalavemass + $amass_f;<br>
  $totalisomass = $totalisomass + $mass_f;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;g&quot;){<br>
  $totalavemass = $totalavemass + $amass_g;<br>
  $totalisomass = $totalisomass + $mass_g;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;h&quot;){<br>
  $totalavemass = $totalavemass + $amass_h;<br>
  $totalisomass = $totalisomass + $mass_h;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;i&quot;){<br>
  $totalavemass = $totalavemass + $amass_i;<br>
  $totalisomass = $totalisomass + $mass_i;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;k&quot;){<br>
  $totalavemass = $totalavemass + $amass_k;<br>
  $totalisomass = $totalisomass + $mass_k;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;l&quot;){<br>
  $totalavemass = $totalavemass + $amass_l;<br>
  $totalisomass = $totalisomass + $mass_l;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;m&quot;){<br>
  $totalavemass = $totalavemass + $amass_m;<br>
  $totalisomass = $totalisomass + $mass_m;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;n&quot;){<br>
  $totalavemass = $totalavemass + $amass_n;<br>
  $totalisomass = $totalisomass + $mass_n;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;p&quot;){<br>
  $totalavemass = $totalavemass + $amass_p;<br>
  $totalisomass = $totalisomass + $mass_p;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;q&quot;){<br>
  $totalavemass = $totalavemass + $amass_q;<br>
  $totalisomass = $totalisomass + $mass_q;<br>
  }</p>
<p> elsif (substr($peptide, $j, 1) eq &quot;r&quot;){<br>
  $totalavemass = $totalavemass + $amass_r;<br>
  $totalisomass = $totalisomass + $mass_r;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;s&quot;){<br>
  $totalavemass = $totalavemass + $amass_s;<br>
  $totalisomass = $totalisomass + $mass_s;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;t&quot;){<br>
  $totalavemass = $totalavemass + $amass_t;<br>
  $totalisomass = $totalisomass + $mass_t;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;v&quot;){<br>
  $totalavemass = $totalavemass + $amass_v;<br>
  $totalisomass = $totalisomass + $mass_v;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;w&quot;){<br>
  $totalavemass = $totalavemass + $amass_w;<br>
  $totalisomass = $totalisomass + $mass_w;<br>
  }<br>
  elsif (substr($peptide, $j, 1) eq &quot;y&quot;){<br>
  $totalavemass = $totalavemass + $amass_y;<br>
  $totalisomass = $totalisomass + $mass_y;<br>
  }<br>
  } # end for</p>
<p> # add the mass of water to each masses<br>
  if( $totalavemass &gt;0){<br>
  $totalavemass = $totalavemass + WATER;<br>
  }<br>
  if( $totalisomass &gt;0){<br>
  $totalisomass = $totalisomass + WATER;<br>
  }</p>
<p> # keeps track of the total masses for the proteins calculations<br>
  $totalIsoMass += $totalisomass;<br>
  $totalAvgMass += $totalavemass;</p>
<p> # do not add these calculation to the incoplete case<br>
  if($complete ==1){<br>
  $totalLen += length($peptide);<br>
  # this for each peptide calculations<br>
  push(@len_peptide,length($peptide));<br>
  push(@charge_peptide, charge_of_peptides(\$peptide));<br>
  }</p>
<p> # this for each peptide calculations<br>
  push(@isoMass_peptide,$totalisomass);<br>
  my $l = $#isoMass_peptide;<br>
  # for each peptide keep teh count of total average mass and total iso mass<br>
  push(@avgMass_peptide,$totalavemass);</p>
<p> if($opt_d==1){<br>
  # writes out all the information to the outputfile1<br>
  write(SIMPLE);<br>
  }<br>
  # reinitialization<br>
  $totalavemass = 0;<br>
  $totalisomass = 0;<br>
  $totalisoEpoint = 0;</p>
<p> $A = $ACount; $C = $CCount; $D = $DCount; $E = $ECount; $F = $FCount; $G = $GCount;<br>
  $H = $HCount; $I = $ICount; $K = $KCount; $L = $LCount; $M = $MCount; $N = $NCount;<br>
  $P = $PCount; $Q = $QCount; $R = $RCount; $S = $SCount; $T = $TCount; $V = $VCount;<br>
  $W = $WCount; $Y = $YCount;<br>
  $nbr = $numpep; $oldpeptide = $peptide;<br>
  if($opt_a==1){<br>
  # write the info to the output file<br>
  write(ANNOTATED);<br>
  }<br>
</p>
<p> if($complete==1){<br>
  if ($ACount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[0][$ACount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[0][$ACount+1] = &quot;$val=T&quot;;<br>
  }<br>
  } # increments when there are one or more A's in each peptide<br>
  if ($CCount &lt;= MAX) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[1][$CCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[1][$CCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  } # increments when there are one or more C's in each peptide<br>
  if ($DCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[2][$DCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[2][$DCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($ECount &lt;= MAX) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[3][$ECount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[3][$ECount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($FCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[4][$FCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[4][$FCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($GCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[5][$GCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[5][$GCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($HCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[6][$HCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[6][$HCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($ICount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[7][$ICount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[7][$ICount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($KCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[8][$KCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[8][$KCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($LCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[9][$LCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[9][$LCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($MCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[10][$MCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[10][$MCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($NCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[11][$NCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[11][$NCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($PCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[12][$PCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[12][$PCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($QCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[13][$QCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[13][$QCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($RCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[14][$RCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[14][$RCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($SCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[15][$SCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[15][$SCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($TCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[16][$TCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[16][$TCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($VCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[17][$VCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[17][$VCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($WCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[18][$WCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[18][$WCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }<br>
  if ($YCount &lt;= MAX ) {<br>
  my ($val,$bool) = split(/=/,$amino_acid_peptide[19][$YCount+1]);<br>
  if($bool !~ /^T$/){<br>
  $val++;<br>
  $amino_acid_peptide[19][$YCount+1] = &quot;$val=T&quot;;<br>
  }<br>
  }</p>
<p> # Determines how many peptides have at least one of each of the twenty amino acids<br>
  if ($ACount &gt;= 1 ) {<br>
  $Aexists++;<br>
  } # increments when there are one or more A's in each peptide<br>
  if ($CCount &gt;= 1 ) {<br>
  $Cexists++;<br>
  } # increments when there are one or more C's in each peptide<br>
  if ($DCount &gt;= 1 ) {<br>
  $Dexists++;<br>
  }<br>
  if ($ECount &gt;= 1 ) {<br>
  $Eexists++;<br>
  }<br>
  if ($FCount &gt;= 1 ) {<br>
  $Fexists++;<br>
  }<br>
  if ($GCount &gt;= 1 ) {<br>
  $Gexists++;<br>
  }<br>
  if ($HCount &gt;= 1 ) {<br>
  $Hexists++;<br>
  }<br>
  if ($ICount &gt;= 1 ) {<br>
  $Iexists++;<br>
  }<br>
  if ($KCount &gt;= 1 ) {<br>
  $Kexists++;<br>
  }<br>
  if ($LCount &gt;= 1 ) {<br>
  $Lexists++;<br>
  }<br>
  if ($MCount &gt;= 1 ) {<br>
  $Mexists++;<br>
  }<br>
  if ($NCount &gt;= 1 ) {<br>
  $Nexists++;<br>
  }<br>
  if ($PCount &gt;= 1 ) {<br>
  $Pexists++;<br>
  }<br>
  if ($QCount &gt;= 1 ) {<br>
  $Qexists++;<br>
  }<br>
  if ($RCount &gt;= 1 ) {<br>
  $Rexists++;<br>
  }<br>
  if ($SCount &gt;= 1 ) {<br>
  $Sexists++;<br>
  }<br>
  if ($TCount &gt;= 1 ) {<br>
  $Texists++;<br>
  }<br>
  if ($VCount &gt;= 1 ) {<br>
  $Vexists++;<br>
  }<br>
  if ($WCount &gt;= 1 ) {<br>
  $Wexists++;<br>
  }<br>
  if ($YCount &gt;= 1 ) {<br>
  $Yexists++;<br>
  }</p>
<p> # Calculating hydrophobicity<br>
  my $hydrophobicity = ($ACount*1.8) + ($CCount*0.04) + ($DCount*(-0.72)) + ($ECount*(-0.62)) + ($FCount*0.61)<br>
  + ($GCount*0.16) + ($HCount*(-0.40)) + ($ICount*0.73) + ($KCount*(-1.1)) + ($LCount*0.53)<br>
  + ($MCount*0.26) + ($NCount*(-0.64)) + ($PCount*(-0.07)) + ($QCount*(-0.69)) + ($RCount*(-1.8))<br>
  + ($SCount*(-0.26)) + ($TCount*(-0.18)) + ($VCount*0.54) + ($WCount*0.37) + ($YCount*0.02);<br>
  push(@hydrophobicity_peptide, $hydrophobicity);<br>
  }# end if<br>
  } #end sub</p>
<p>&nbsp;</p>
<p># writes to the output file<br>
  sub print_final<br>
  {<br>
  $nbr = &quot; &quot;; $oldpeptide = &quot; &quot;;</p>
<p> print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot; Amino Acid Representation \n&quot;;<br>
  print ANNOTATED &quot; The number of peptides with at least one of each amino acid\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot; A C D E F G H I K L M N P Q R S T V W Y\n&quot;;<br>
  print ANNOTATED &quot; ---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+\n&quot;;<br>
  # print &quot;\n&quot;;<br>
  # print &quot; Amino Acid Representation \n&quot;;<br>
  # print &quot; The number of peptides with at least one of each amino acid\n&quot;;<br>
  # print &quot;\n&quot;;<br>
  # print &quot; A C D E F G H I K L M N P Q R S T V W Y\n&quot;;<br>
  # print &quot; ---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+\n&quot;;<br>
  $A = $Aexists; $C = $Cexists; $D = $Dexists; $E = $Eexists; $F = $Fexists;<br>
  $G = $Gexists; $H = $Hexists; $I = $Iexists; $K = $Kexists; $L = $Lexists;<br>
  $M = $Mexists; $N = $Nexists; $P = $Pexists; $Q = $Qexists; $R = $Rexists;<br>
  $S = $Sexists; $T = $Texists; $V = $Vexists; $W = $Wexists; $Y = $Yexists;<br>
  #**************debug**********************<br>
  # write(STDOUT);<br>
  #*****************************************<br>
  write(ANNOTATED);<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot; Total Number of Each Amino Acid in the Protein \n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot; A C D E F G H I K L M N P Q R S T V W Y\n&quot;;<br>
  print ANNOTATED &quot; ---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+\n&quot;;<br>
  # print &quot;\n&quot;;<br>
  # print &quot; Total Number of Each Amino Acid in the Protein \n&quot;;<br>
  # print &quot;\n&quot;;<br>
  # print &quot; A C D E F G H I K L M N P Q R S T V W Y\n&quot;;<br>
  # print &quot; ---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+\n&quot;;</p>
<p> $A = $totalACount; $C = $totalCCount; $D = $totalDCount; $E = $totalECount;<br>
  $F = $totalFCount; $G = $totalGCount; $H = $totalHCount; $I = $totalICount;<br>
  $K = $totalKCount; $L = $totalLCount; $M = $totalMCount; $N = $totalNCount;<br>
  $P = $totalPCount; $Q = $totalQCount; $R = $totalRCount; $S = $totalSCount;<br>
  $T = $totalTCount; $V = $totalVCount; $W = $totalWCount; $Y = $totalYCount;</p>
<p> write(ANNOTATED);<br>
  write(PEPTIDES);<br>
  #**************debug**********************<br>
  # write(STDOUT);<br>
  #*****************************************<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot;Number of acidic residues in protein: $prot_acid_count\n&quot;;<br>
  print ANNOTATED &quot;Number of basic residues in protein: $prot_basic_count\n&quot;;<br>
  print ANNOTATED &quot;Number of polar residues in protein: $prot_polar_count\n&quot;;<br>
  print ANNOTATED &quot;Number of nonpolar residues in protein: $prot_nonpolar_count\n&quot;;<br>
  print ANNOTATED &quot;Isotopic mass of protein: $prot_iso_mass\n&quot;;<br>
  print ANNOTATED &quot;Average mass of protein: $prot_ave_mass\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  }<br>
</p>
<p># this sub routine generates the missed clevages as well as the hash to<br>
  # store the postions of peptides in the input file<br>
  sub missedCleavage{<br>
  my ($peptides_array) = shift;<br>
  my $len = @$peptides_array;<br>
  for my $q(0 .. $missed_cleavage){<br>
  my $initial=1;<br>
  for my $i(0 .. $len-1){<br>
  if($i&gt;0){<br>
  $initial += length($$peptides_array[$i-1]);<br>
  }<br>
  my $x = $i + $q;<br>
  my $string;<br>
  if($x &gt;= $len){<br>
  last;<br>
  }<br>
  for my $j ($i .. $x){<br>
  $string = $string.$$peptides_array[$j];<br>
  }<br>
  my $l = length($string);<br>
  my $position = join(&quot;-&quot;,$initial, $initial+$l-1);<br>
  $peptide_hash{$position} = $string;<br>
  }<br>
  }<br>
  }<br>
</p>
<p># this subroutine takes care of doing the analysis for each protein.<br>
  sub process(){<br>
  if($protein &amp;&amp; !($protein =~ /^$/)){<br>
  foreach my $i (0 ..$#breakAt){<br>
  $protein =~ s/$breakAt[$i]/$breakAt2[$i]/g;<br>
  }<br>
  <br>
  # the unsorted array that stores peptides<br>
  my @peptides=split(/X/,$protein);<br>
  <br>
  #for (my $i=0; $i&lt;=$#peptides; $i++) {<br>
  # print &quot;peptides at $i is $peptides[$i]\n&quot;;<br>
  #}<br>
  <br>
  $totalProteins++;<br>
  if(@peptides){<br>
  missedCleavage(\@peptides);<br>
  my @sorted = sort { length ($peptide_hash{$b}) &lt;=&gt; length ($peptide_hash{$a})} keys %peptide_hash;<br>
  my %rev = reverse %peptide_hash;</p>
<p> %peptide_hash = reverse %rev;</p>
<p> # if user wants the simple file<br>
  if($opt_d==1){<br>
  # writes the protein name<br>
  print SIMPLE &quot;Protein Name: $protein_name\n&quot;;<br>
  print SIMPLE &quot;\n&quot;;<br>
  # write the header to output file 1<br>
  print SIMPLE &quot; No. Range Isotopic Mass Average Mass Peptide\n&quot;;<br>
  }</p>
<p> if($opt_a==1){<br>
  print ANNOTATED &quot;Protein Name: $protein_name\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;</p>
<p> # write the header to output file 2<br>
  print ANNOTATED &quot; ***Amino Acid Count Within Peptide***\n&quot;;<br>
  print ANNOTATED &quot;No. A C D E F G H I K L M N P Q R S T V W Y Peptide\n&quot;;<br>
  print ANNOTATED &quot;------- +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+--------\n&quot;;<br>
  }</p>
<p> # initialize the</p>
<p> my $i=0;<br>
  my $flag;<br>
  foreach $a (@sorted){<br>
  <br>
  if(length ($peptide_hash{$a}) &gt;$peptide_length){<br>
  $flag=0;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  analyze_peptide(\$peptide_hash{$a},\++$i, \$a, 1);<br>
  # if incomplete peptide modificaitons is selected then<br>
  # do the substitutions and make this peptide a new peptide<br>
  if($opt_N==1){<br>
  my $contains=0;<br>
  my $copy;<br>
  my $count;<br>
  my $where;<br>
  my $orig;<br>
  my @copies;<br>
  if($opt_S==1 &amp;&amp; $peptide_hash{$a}=~ /S/){<br>
  my @mod_peps;<br>
  $copy = $peptide_hash{$a};<br>
  $orig = $copy;<br>
  $count = $copy =~ tr/S//; <br>
  $where = index($copy, &quot;S&quot;);<br>
  substr($copy,$where,1) =~ s/S/s/;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copies[0],\++$i,\$a, 1);</p>
<p> for (my $m=1;$m&lt;=$count; $m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /S/) {<br>
  $where = index($copies[$m], &quot;S&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/S/s/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/S/s/;<br>
  analyze_peptide(\$temp,\++$i,\$a, 1);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  }<br>
  <br>
  } <br>
  @copies = &quot;&quot;; <br>
  }<br>
  if($opt_T==1 &amp;&amp; $peptide_hash{$a}=~ /T/){</p>
<p> my @mod_peps;<br>
  $copy = $peptide_hash{$a};<br>
  $orig = $copy;<br>
  $count = $copy =~ tr/T//; <br>
  $where = index($copy, &quot;T&quot;);<br>
  substr($copy,$where,1) =~ s/T/t/;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copies[0],\++$i,\$a, 1);</p>
<p> for (my $m=1;$m&lt;=$count; $m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /T/) {<br>
  $where = index($copies[$m], &quot;T&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/T/t/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/T/t/;<br>
  analyze_peptide(\$temp,\++$i,\$a, 1);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  }<br>
  <br>
  } <br>
  @copies = &quot;&quot;;<br>
  }</p>
<p> if($opt_Y==1 &amp;&amp; $peptide_hash{$a}=~ /Y/){</p>
<p> my @mod_peps;<br>
  $copy = $peptide_hash{$a};<br>
  $orig = $copy;<br>
  $count = $copy =~ tr/Y//; <br>
  $where = index($copy, &quot;Y&quot;);<br>
  substr($copy,$where,1) =~ s/Y/y/;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copies[0],\++$i,\$a, 1);</p>
<p> for (my $m=1;$m&lt;=$count; $m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /Y/) {<br>
  $where = index($copies[$m], &quot;Y&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/Y/y/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/Y/y/;<br>
  analyze_peptide(\$temp,\++$i,\$a, 1);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  }<br>
  <br>
  } <br>
  <br>
  @copies = &quot;&quot;;<br>
  }</p>
<p> if($opt_I==1 &amp;&amp; $peptide_hash{$a}=~ /C/){</p>
<p> my @mod_peps;<br>
  $copy = $peptide_hash{$a};<br>
  $orig = $copy;<br>
  $count = $copy =~ tr/C//; <br>
  $where = index($copy, &quot;C&quot;);<br>
  substr($copy,$where,1) =~ s/C/c/;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  $copies[0]=$copy;<br>
  $mass_C =<br>
  $mass_C + 415.5;<br>
  $amass_C =<br>
  $amass_C + 415.5;<br>
  analyze_peptide(\$copies[0],\++$i,\$a, 1);<br>
  $mass_C =<br>
  103.00919;<br>
  $amass_C =<br>
  103.1388;<br>
  $mass_C =<br>
  $mass_C + 423.5;<br>
  $amass_C =<br>
  $amass_C = 423.5;<br>
  analyze_peptide(\$copies[0],\++$i,\$a,<br>
  1);<br>
  $mass_C =<br>
  103.00919;<br>
  $amass_C =<br>
  103.1388;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  for (my $m=1;$m&lt;=$count; $m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /C/) {<br>
  $where = index($copies[$m], &quot;C&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/C/c/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/C/c/;<br>
  $mass_C<br>
  = $mass_C + 415.5;<br>
  $amass_C<br>
  = $amass_C + 423.5;<br>
  analyze_peptide(\$temp,\++$i,\$a, 1);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  $mass_C<br>
  = 103.00919;<br>
  $amass_C<br>
  = 103.1388;<br>
  $mass_C<br>
  = $mass_C + 415.5;<br>
  $amass_C<br>
  = $amass_C + 423.5;<br>
  analyze_peptide(\$temp,\++$i,\$a,1);<br>
  $mass_C<br>
  = 103.00919;<br>
  $amass_C<br>
  = 103.1388;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  }<br>
  <br>
  } <br>
  @copies = &quot;&quot;; <br>
  }</p>
<p> if($opt_M==1 &amp;&amp; $peptide_hash{$a}=~ /K/){</p>
<p> my @mod_peps;<br>
  $copy = $peptide_hash{$a};<br>
  $orig = $copy;<br>
  $count = $copy =~ tr/K//; <br>
  $where = index($copy, &quot;K&quot;);<br>
  substr($copy,$where,1) =~ s/K/k/;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copies[0],\++$i,\$a, 1);</p>
<p> for (my $m=1;$m&lt;=$count; $m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /K/) {<br>
  $where = index($copies[$m], &quot;K&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/K/k/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/K/k/;<br>
  analyze_peptide(\$temp,\++$i,\$a, 1);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  }<br>
  <br>
  } <br>
  <br>
  @copies = &quot;&quot;;<br>
  }</p>
<p> if($opt_R &amp;&amp; $opt_W){<br>
  $copy = $peptide_hash{$a};<br>
  $orig = $copy;<br>
</p>
<p> <br>
  foreach my $aa (@amino_acids){<br>
  # now add the given weight to the given AA<br>
  if($aa =~ /^A$/ &amp;&amp; $copy=~ /A/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/A//;<br>
  $where = index($copy, &quot;A&quot;);<br>
  substr($copy2, $where, 1) =~ s/A/aZ/;<br>
  substr($copy, $where, 1) =~ s/A/a/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /A/) {<br>
  $where = index($copies[$m], &quot;A&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/A/a/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/A/aZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}</p>
<p> <br>
  } <br>
  <br>
  elsif($aa =~ /^C$/ &amp;&amp; $copy=~ /C/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/C//;<br>
  $where = index($copy, &quot;C&quot;);<br>
  substr($copy2, $where, 1) =~ s/C/cZ/;<br>
  substr($copy, $where, 1) =~ s/C/c/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /C/) {<br>
  $where = index($copies[$m], &quot;C&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/C/c/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/C/cZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^D$/ &amp;&amp; $copy=~ /D/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/D//;<br>
  $where = index($copy, &quot;D&quot;);<br>
  substr($copy2, $where, 1) =~ s/D/dZ/;<br>
  substr($copy, $where, 1) =~ s/D/d/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /D/) {<br>
  $where = index($copies[$m], &quot;D&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/D/d/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/D/dZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^E$/ &amp;&amp; $copy=~ /E/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/E//;<br>
  $where = index($copy, &quot;E&quot;);<br>
  substr($copy2, $where, 1) =~ s/E/eZ/;<br>
  substr($copy, $where, 1) =~ s/E/e/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /E/) {<br>
  $where = index($copies[$m], &quot;E&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/E/e/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/E/eZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^F$/ &amp;&amp; $copy=~ /F/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/F//;<br>
  $where = index($copy, &quot;F&quot;);<br>
  substr($copy2, $where, 1) =~ s/F/fZ/;<br>
  substr($copy, $where, 1) =~ s/F/f/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /F/) {<br>
  $where = index($copies[$m], &quot;F&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/F/f/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/F/fZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^G$/ &amp;&amp; $copy=~ /G/){<br>
  $flag=1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/G//;<br>
  $where = index($copy, &quot;G&quot;);<br>
  substr($copy2, $where, 1) =~ s/G/gZ/;<br>
  substr($copy, $where, 1) =~ s/G/g/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /G/) {<br>
  $where = index($copies[$m], &quot;G&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/G/g/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/G/gZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}</p>
<p> }<br>
  elsif($aa =~ /^H$/ &amp;&amp; $copy=~ /H/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/H//;<br>
  $where = index($copy, &quot;H&quot;);<br>
  substr($copy2, $where, 1) =~ s/H/hZ/;<br>
  substr($copy, $where, 1) =~ s/H/h/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /H/) {<br>
  $where = index($copies[$m], &quot;H&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/H/h/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/H/hZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}</p>
<p> }<br>
  elsif($aa =~ /^I$/ &amp;&amp; $copy=~ /I/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/I//;<br>
  $where = index($copy, &quot;I&quot;);<br>
  substr($copy2, $where, 1) =~ s/I/iZ/;<br>
  substr($copy, $where, 1) =~ s/I/i/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /I/) {<br>
  $where = index($copies[$m], &quot;I&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/I/i/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/I/iZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}</p>
<p> }<br>
  elsif($aa =~ /^K$/ &amp;&amp; $copy=~ /K/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/K//;<br>
  $where = index($copy, &quot;K&quot;);<br>
  substr($copy2, $where, 1) =~ s/K/kZ/;<br>
  substr($copy, $where, 1) =~ s/K/k/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /K/) {<br>
  $where = index($copies[$m], &quot;K&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/K/k/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/K/kZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^L$/ &amp;&amp; $copy=~ /L/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/L//;<br>
  $where = index($copy, &quot;L&quot;);<br>
  substr($copy2, $where, 1) =~ s/L/lZ/;<br>
  substr($copy, $where, 1) =~ s/L/l/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /L/) {<br>
  $where = index($copies[$m], &quot;L&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/L/l/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/L/lZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  if($aa =~ /^M$/ &amp;&amp; $copy=~ /M/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/M//;<br>
  $where = index($copy, &quot;M&quot;);<br>
  substr($copy2, $where, 1) =~ s/M/mZ/;<br>
  substr($copy, $where, 1) =~ s/M/m/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /M/) {<br>
  $where = index($copies[$m], &quot;M&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/M/m/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/M/mZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^N$/ &amp;&amp; $copy =~/N/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/N//;<br>
  $where = index($copy, &quot;N&quot;);<br>
  substr($copy2, $where, 1) =~ s/N/nZ/;<br>
  substr($copy, $where, 1) =~ s/N/n/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /N/) {<br>
  $where = index($copies[$m], &quot;N&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/N/n/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/N/nZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  if($aa =~ /^P$/ &amp;&amp; $copy=~ /P/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/P//;<br>
  $where = index($copy, &quot;P&quot;);<br>
  substr($copy2, $where, 1) =~ s/P/pZ/;<br>
  substr($copy, $where, 1) =~ s/P/p/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /P/) {<br>
  $where = index($copies[$m], &quot;P&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/P/p/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/P/pZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}</p>
<p> }<br>
  elsif($aa =~ /^Q$/ &amp;&amp; $copy=~ /Q/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/Q//;<br>
  $where = index($copy, &quot;Q&quot;);<br>
  substr($copy2, $where, 1) =~ s/Q/qZ/;<br>
  substr($copy, $where, 1) =~ s/Q/q/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /Q/) {<br>
  $where = index($copies[$m], &quot;Q&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/Q/q/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/Q/qZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^R$/ &amp;&amp; $copy=~ /R/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/R//;<br>
  $where = index($copy, &quot;R&quot;);<br>
  substr($copy2, $where, 1) =~ s/R/rZ/;<br>
  substr($copy, $where, 1) =~ s/R/r/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /R/) {<br>
  $where = index($copies[$m], &quot;R&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/R/r/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/R/rZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^S$/ &amp;&amp; $copy=~ /S/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/S//;<br>
  $where = index($copy, &quot;S&quot;);<br>
  substr($copy2, $where, 1) =~ s/S/sZ/;<br>
  substr($copy, $where, 1) =~ s/S/s/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /S/) {<br>
  $where = index($copies[$m], &quot;S&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/S/s/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/S/sZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^T$/ &amp;&amp; $copy=~ /T/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/T//;<br>
  $where = index($copy, &quot;T&quot;);<br>
  substr($copy2, $where, 1) =~ s/T/tZ/;<br>
  substr($copy, $where, 1) =~ s/T/t/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /T/) {<br>
  $where = index($copies[$m], &quot;T&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/T/t/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/T/tZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}</p>
<p> }<br>
  if($aa =~ /^V$/ &amp;&amp; $copy=~ /V/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/V//;<br>
  $where = index($copy, &quot;V&quot;);<br>
  substr($copy2, $where, 1) =~ s/V/vZ/;<br>
  substr($copy, $where, 1) =~ s/V/v/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /V/) {<br>
  $where = index($copies[$m], &quot;V&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/V/v/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/V/vZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^W$/ &amp;&amp; $copy=~ /W/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/W//;<br>
  $where = index($copy, &quot;W&quot;);<br>
  substr($copy2, $where, 1) =~ s/W/wZ/;<br>
  substr($copy, $where, 1) =~ s/W/w/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /W/) {<br>
  $where = index($copies[$m], &quot;W&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/W/w/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/W/wZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  elsif($aa =~ /^Y$/ &amp;&amp; $copy=~ /Y/){<br>
  $flag =1;<br>
  my $copy2 = $copy;<br>
  $count = $copy =~ tr/Y//;<br>
  $where = index($copy, &quot;Y&quot;);<br>
  substr($copy2, $where, 1) =~ s/Y/yZ/;<br>
  substr($copy, $where, 1) =~ s/Y/y/;<br>
  $copies[0]=$copy;<br>
  analyze_peptide(\$copy2, \++$i, \$a, 0);</p>
<p>for (my $m=1;$m&lt;=$count;$m++) {<br>
  $copies[$m]=$copies[$m-1];<br>
  if($copies[$m] =~ /Y/) {<br>
  $where = index($copies[$m], &quot;Y&quot;);<br>
  substr($copies[$m], $where, 1) =~ s/Y/y/;<br>
  my $temp = $orig;<br>
  substr($temp, $where, 1) =~ s/Y/yZ/;<br>
  analyze_peptide(\$temp, \++$i, \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  <br>
  }</p>
<p>}<br>
  }<br>
  } #end for<br>
  #if($flag==1){<br>
  # $totalPeptides++;<br>
  # $totalPepds++;<br>
  # analyze_peptide(\$copy,\++$i,\$a, 0);</p>
<p> #}<br>
  } #end if</p>
<p> } # end opt_N<br>
  if (($opt_N == 0) &amp;&amp; ($opt_I == 1) &amp;&amp;<br>
  ($peptide_hash{$a} =~ /C/)) {<br>
  my $copy = $peptide_hash{$a};<br>
  $mass_C = $mass_C + 415.5;<br>
  $amass_C = $amass_C + 415.5;<br>
  analyze_peptide(\$copy, \++$i,<br>
  \$a, 0);<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  $mass_C = 103.00919;<br>
  $amass_C = 103.1388;<br>
  $mass_C = $mass_c + 423.5; <br>
  $amass_C = $amass_C + 423.5;<br>
  analyze_peptide(\$copy, \++$i,<br>
  \$a, 0);<br>
  $mass_C = 103.00919;<br>
  $amass_C = 103.1388;<br>
  $totalPeptides++;<br>
  $totalPepds++;<br>
  }<br>
  }<br>
  } #end for<br>
</p>
<p> # store all the necessary calculations(for each protein) for the summary<br>
  push(@isoMass_protein, $totalIsoMass);<br>
  push(@avgMass_protein, $totalAvgMass);</p>
<p> # collect these results only if complete is 1</p>
<p> # for each protein store the total length of the protein<br>
  push(@len_protein, $totalLen);<br>
  # for each protein store the count of amino acid composition<br>
  push(@amino_acid_protein,[@aminoacids_count_protein]);<br>
  # for each protein store the total peptides for this protein<br>
  push(@peptides_protein, $totalPepds);<br>
</p>
<p> # if annotated is chosen by the user then write data to annotated file<br>
  if($opt_a==1){<br>
  print_final();<br>
  }<br>
  # re-initializes the values<br>
  reinitialize();<br>
  initializeValues();<br>
  # if user has chosen to have a simple file then write data to simple file<br>
  if($opt_d==1){<br>
  # write out the number of peptides in each protein<br>
  print SIMPLE &quot;Number of peptides = $numpep\n&quot;;<br>
  print SIMPLE &quot;\n&quot;;<br>
  }</p>
<p> } # end if<br>
  else{<br>
  print &quot;There is no proteins to process\n&quot;;<br>
  exit(0);<br>
  }</p>
<p> }</p>
<p>} #end sub</p>
<p># this subroutine returns the sum of the array elements<br>
  sub sum{<br>
  my ($dataset) = shift;<br>
  my $result;<br>
  for (@{$dataset}) {<br>
  $result += $_;<br>
  }<br>
  return $result;<br>
  }<br>
</p>
<p># this subroutine returns the mean of a given set of data<br>
  sub average{<br>
  my ($dataset) = shift;<br>
  my $sum = sum(\@{$dataset});</p>
<p> my $len = @{$dataset};<br>
  return $sum/$len;</p>
<p>}</p>
<p>#this subrotine returns the standard deviation of a data set<br>
  sub standard_deviation{<br>
  my ($dataset) = shift;<br>
  my $sum_square;<br>
  my $sum;<br>
  my $n = @{$dataset};<br>
  for (@{$dataset}) {<br>
  $sum_square += $_ ** 2;<br>
  $sum += $_;<br>
  }<br>
  my $numerator = ($n * $sum_square)-($sum ** 2);<br>
  if($n==1){<br>
  return sqrt($numerator / ($n*$n));<br>
  }<br>
  return sqrt($numerator / ($n*($n-1)));<br>
  }</p>
<p>&nbsp;</p>
<p>########################################### PEPTIDE ANALYSIS SECTION ####################################</p>
<p># this subroutine calculates the charge of every peptide<br>
  sub charge_of_peptides {<br>
  my ($p) = shift;<br>
  my $peptide = $$p;<br>
  my $charge = 0;</p>
<p> for($j = 0; $j&lt;=(length($peptide)); $j++){</p>
<p> if (substr($peptide, $j, 1) eq &quot;D&quot;){<br>
  $charge += -1;<br>
  }<br>
  if (substr($peptide, $j, 1) eq &quot;E&quot;){<br>
  $charge += -1;<br>
  }<br>
  if (substr($peptide, $j, 1) eq &quot;H&quot;){<br>
  $charge += 1;<br>
  }<br>
  if (substr($peptide, $j, 1) eq &quot;K&quot;){<br>
  $charge += 1;<br>
  }<br>
  if (substr($peptide, $j, 1) eq &quot;R&quot;){<br>
  $charge += 1;<br>
  }<br>
  <br>
  } # end for<br>
  return $charge;<br>
  }<br>
</p>
<p>sub physicalProperties{</p>
<p> my $description = shift;<br>
  my $range = shift;<br>
  my $max = shift;<br>
  my ($dataset) = shift;<br>
  my $choice = shift;<br>
  my $initial = shift;<br>
  my $denominator = $totalProteins;</p>
<p> if($choice =~ /Peptides/){ $denominator = $totalPeptides;}<br>
  my $string;<br>
  my %buckets;<br>
  # build the buckets<br>
  my $j=$initial;<br>
  my $k=$j;<br>
  if($description =~ /^Charge$/){<br>
  displayCharge($description,$initial,$denominator,$range,$max,\@{$dataset});<br>
  }<br>
  else{<br>
  for(my $i=1;$i &lt;= $max;$i++){<br>
  $k += $range;<br>
  my $key = $j.&quot;-&quot;.&quot;$k&quot;;<br>
  $buckets{$key} =0;<br>
  $j= $k;<br>
  }<br>
  my $lastKey = &quot;&gt;=$j&quot;;<br>
  $buckets{$lastKey}=0;<br>
  # now fill the buckets<br>
  for (@{$dataset}) {<br>
  foreach my $key (keys %buckets){<br>
  if($key =~ /^&gt;=/){<br>
  my $n = $key;<br>
  $n =~ s/^&gt;=//g;<br>
  if($_ &gt;= $n){<br>
  $buckets{$key}++;<br>
  }<br>
  }else{<br>
  my $g; my $h;<br>
  if($initial&lt;0){<br>
  my $dup = $key;<br>
  if($dup =~ /--/){<br>
  $dup =~ s/\--/\^-/g;<br>
  ($g,$h) = split (/\^/,$dup,2);<br>
  }<br>
  elsif($key =~ /^-1-0$/){<br>
  $g = -1;<br>
  $h=0;<br>
  }<br>
  else{<br>
  ($g,$h) = split (/\-/,$key,2);<br>
  }</p>
<p> }<br>
  else{<br>
  ($g,$h) = split (/\-/,$key,2);<br>
  }<br>
  if(($_ &gt; $g) &amp;&amp; ($h &gt;= $_)){<br>
  $buckets{$key}++;<br>
  }<br>
  else{<br>
  next;<br>
  }<br>
  }<br>
  }<br>
  }<br>
  <br>
  $string = &quot;&lt;table border celllpadding=10 cellspacing=0 align=center width=100%&gt;\n&quot;;<br>
  $string.=&quot; &lt;tr&gt;\n&quot;;<br>
  $string.=&quot;&lt;th bgcolor=#800000&gt;&lt;font size=4 color=#FFFFFF&gt;$description&lt;/font&gt;&lt;/th&gt;\n&quot;;</p>
<p> foreach my $key (sort { my ($v,$y)= split(&quot;_&quot;,$a); $v&lt;=&gt;$b}keys %buckets){<br>
  if($key =~ /&gt;/){<br>
  $lastKey = $key;<br>
  }<br>
  else{<br>
  my ($a, $b);<br>
  if($key =~ /^\-/){<br>
  $b = $key;<br>
  $b =~ s/^\-\d+\-//g;<br>
  $a = $key;<br>
  if($a =~ /\-\-/){<br>
  $a =~ s/\-\-\d+//g;<br>
  }<br>
  elsif($a =~ /\-\d+$/){<br>
  $a =~ s/\-\d+$//g;<br>
  }<br>
  }<br>
  else{<br>
  ($a, $b) = split(&quot;-&quot;,$key);<br>
  }<br>
  $string .= &quot;&lt;th bgcolor=#800000&gt;&lt;font size=4 color=#FFFFFF&gt;$a -&lt;br&gt;$b&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  }<br>
  }<br>
  $string .= &quot;&lt;th bgcolor=#800000&gt;&lt;font size=4 color=#FFFFFF&gt;$lastKey&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;tr&gt;\n&quot;;<br>
  $string.=&quot;&lt;th align=left&gt;&lt;font size=4&gt;Count&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  foreach my $key (sort {my ($v,$y)= split(&quot;_&quot;,$a); $v&lt;=&gt;$b}keys %buckets){<br>
  if($key =~ /&gt;/){<br>
  $lastKey = $key;<br>
  }<br>
  else{<br>
  $string .= &quot;&lt;td align=center&gt;$buckets{$key}&lt;/td&gt;\n&quot;;<br>
  }<br>
  }<br>
  $string .= &quot;&lt;td align=center&gt;$buckets{$lastKey}&lt;/td&gt;\n&quot;;<br>
  $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  $string.=&quot; &lt;tr&gt;\n&quot;;<br>
  $string.=&quot;&lt;th align=left&gt;&lt;font size=4&gt;Fraction&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  foreach my $key (sort {my ($v,$y)= split(&quot;_&quot;,$a); $v&lt;=&gt;$b}keys %buckets){<br>
  if($key =~ /&gt;/){<br>
  $lastKey = $key;<br>
  }<br>
  else{<br>
  my $val = $buckets{$key}/$denominator;<br>
  $val = sprintf(&quot;%.3f&quot;,$val);<br>
  $string .= &quot;&lt;td align=center&gt;$val&lt;/td&gt;\n&quot;;<br>
  }<br>
  }<br>
  my $val = $buckets{$lastKey}/$denominator;<br>
  $val = sprintf(&quot;%.3f&quot;,$val);<br>
  $string .= &quot;&lt;td align=center&gt;$val&lt;/td&gt;\n&quot;;<br>
  $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;/table&gt;&lt;br&gt;&lt;br&gt;\n&quot;;<br>
  print SUMMARY $string;<br>
  }<br>
</p>
<p>}</p>
<p>sub displayCharge{<br>
  # print &quot;IN display charge\n&quot;;<br>
  my $string;<br>
  my $description = shift;<br>
  my $initial = shift;<br>
  my $denominator = shift;<br>
  my $range = shift;<br>
  my $max = shift;<br>
  my ($dataset) = shift;<br>
  my %buckets;<br>
  my $j = $initial;<br>
  for(my $i=$initial;$i &lt;= $max;$i++){<br>
  my $key = $j;<br>
  $buckets{$key} =0;<br>
  $j = $j +1;<br>
  }<br>
  # print &quot;J is $j \t$range\t$max\n&quot;;<br>
  #sleep 5;<br>
  # now fill the buckets<br>
  for (@{$dataset}) {<br>
  if($_&gt;$max){<br>
  $buckets{$max}++;<br>
  }<br>
  elsif($_ &lt;$initial){<br>
  $buckets{$initial}++;<br>
  }<br>
  else{<br>
  $buckets{$_}++;<br>
  }<br>
  # print &quot;VAL IS $_\n&quot;;<br>
  #sleep 1;<br>
  #$buckets{$_}++;<br>
  }<br>
  $string = &quot;&lt;table border celllpadding=10 cellspacing=0 align=center width=100%&gt;\n&quot;;<br>
  $string.=&quot; &lt;tr&gt;\n&quot;;<br>
  $string.=&quot;&lt;th bgcolor=#800000&gt;&lt;font size=4 color=#FFFFFF&gt;$description&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  foreach $a (sort{$a &lt;=&gt;$b} keys %buckets){<br>
  if($a &gt;0){ $a = &quot;+$a&quot;;}<br>
  if($a==$max){<br>
  $a .= &quot;&gt;=&quot;;<br>
  }<br>
  if($a==$initial){<br>
  $a.= &quot;&lt;=&quot;;<br>
  }<br>
  $string .= &quot;&lt;th bgcolor=#800000&gt;&lt;font size=4 color=#FFFFFF&gt;$a&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  # print &quot; $a : $buckets{$a}\n&quot;;<br>
  }<br>
  $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;tr&gt;\n&quot;;<br>
  $string.=&quot;&lt;th align=left&gt;&lt;font size=4&gt;Count&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  foreach $a (sort{$a &lt;=&gt;$b} keys %buckets){<br>
  $string .= &quot;&lt;td align=center&gt;$buckets{$a}&lt;/td&gt;\n&quot;;</p>
<p> }<br>
  $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  $string.=&quot; &lt;tr&gt;\n&quot;;<br>
  $string.=&quot;&lt;th align=left&gt;&lt;font size=4&gt;Fraction&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  foreach $a (sort{$a &lt;=&gt;$b} keys %buckets){<br>
  my $val = $buckets{$a}/$denominator;<br>
  $val = sprintf(&quot;%.3f&quot;,$val);<br>
  $string .= &quot;&lt;td align=center&gt;$val&lt;/td&gt;\n&quot;;</p>
<p> }</p>
<p> $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;/table&gt;&lt;br&gt;&lt;br&gt;\n&quot;;<br>
  print SUMMARY $string;</p>
<p>}<br>
</p>
<p>sub physicalStatistics{<br>
  my $choice = shift;<br>
  my $BODY;<br>
  $BODY=&lt;&lt;END;<br>
&lt;table border celllpadding=&quot;10&quot; cellspacing=&quot;0&quot; align=&quot;center&quot; width=&quot;100%&quot;&gt;<br>
&lt;tr&gt;<br>
&lt;th bgcolor=&quot;#800000&quot;&gt;&lt;font size=&quot;4&quot; color=&quot;#FFFFFF&quot;&gt;Description&lt;/font&gt;&lt;/th&gt;<br>
&lt;th bgcolor=&quot;#800000&quot;&gt;&lt;font size=&quot;4&quot; color=&quot;#FFFFFF&quot;&gt;Mean&lt;/font&gt;&lt;/th&gt;<br>
&lt;th bgcolor=&quot;#800000&quot;&gt;&lt;font size=&quot;4&quot; color=&quot;#FFFFFF&quot;&gt;Std. Dev.&lt;/font&gt;&lt;/th&gt;<br>
&lt;th bgcolor=&quot;#800000&quot;&gt;&lt;font size=&quot;4&quot; color=&quot;#FFFFFF&quot;&gt;Maximum&lt;/font&gt;&lt;/th&gt;<br>
&lt;th bgcolor=&quot;#800000&quot;&gt;&lt;font size=&quot;4&quot; color=&quot;#FFFFFF&quot;&gt;Minimum&lt;/font&gt;&lt;/th&gt;<br>
&lt;th bgcolor=&quot;#800000&quot;&gt;&lt;font size=&quot;4&quot; color=&quot;#FFFFFF&quot;&gt;Total&lt;/font&gt;&lt;/th&gt;<br>
&lt;/tr&gt;<br>
  END<br>
  print SUMMARY $BODY;<br>
  if($choice =~ /^Protein$/){<br>
  fillStatistics(&quot;Length&quot;,\@len_protein);<br>
  fillStatistics(&quot;Isotopic Mass&quot;,\@isoMass_protein);<br>
  fillStatistics(&quot;Average Mass&quot;, \@avgMass_protein);<br>
  }</p>
<p> elsif($choice =~ /^Peptide$/){<br>
  fillStatistics(&quot;No. of Peptides/Protein&quot;,\@peptides_protein);<br>
  }<br>
  elsif($choice =~ /^Protein\/AA$/){<br>
  aminoAcidStatistics();<br>
  }<br>
  print SUMMARY &quot;&lt;/table&gt;\n&quot;;</p>
<p>}<br>
</p>
<p># this subroutine arranges the data for peptides to be displayed<br>
  sub aminoAcidRepPeptide{<br>
  for my $a (0 .. $#amino_acid_peptide){<br>
  my $description = aminoAcids($amino_acid_peptide[$a][0]);<br>
  my @temp;<br>
  for my $i (1 .. $#{$amino_acid_peptide[$a]}){<br>
  my($val,$bool) = split(/=/,$amino_acid_peptide[$a][$i]);<br>
  push(@temp,$val);<br>
  <br>
  }<br>
  displayAAOccurences($description,\@temp);<br>
  }</p>
<p>}<br>
</p>
<p>sub aminoAcids{<br>
  my $AA = shift;<br>
  if($AA =~ /^A$/){ $AA =&quot;Alanine(A)&quot;; }<br>
  if($AA =~ /^C$/){ $AA =&quot;Cysteine(C)&quot;;}<br>
  if($AA =~ /^D$/){ $AA =&quot;Aspartic Acid(D)&quot;;}<br>
  if($AA =~ /^E$/){ $AA =&quot;Glutamic Acid(E)&quot;;}<br>
  if($AA =~ /^F$/){ $AA =&quot;Phenylalanine(F)&quot;;}<br>
  if($AA =~ /^G$/){ $AA =&quot;Glycine(G)&quot;;}<br>
  if($AA =~ /^H$/){ $AA =&quot;Histidine(H)&quot;;}<br>
  if($AA =~ /^I$/){ $AA =&quot;Isoleucine(I)&quot;;}<br>
  if($AA =~ /^K$/){ $AA =&quot;Lysine(K)&quot;;}<br>
  if($AA =~ /^L$/){ $AA =&quot;Leucine(L)&quot;;}<br>
  if($AA =~ /^M$/){ $AA =&quot;Methionine(M)&quot;;}<br>
  if($AA =~ /^N$/){ $AA =&quot;Asparagine(N)&quot;;}<br>
  if($AA =~ /^Q$/){ $AA =&quot;Glutamine(Q)&quot;;}<br>
  if($AA =~ /^P$/){ $AA =&quot;Proline(P)&quot;;}<br>
  if($AA =~ /^R$/){ $AA =&quot;Arginine(R)&quot;;}<br>
  if($AA =~ /^S$/){ $AA =&quot;Serine(S)&quot;;}<br>
  if($AA =~ /^T$/){ $AA =&quot;Threonine(T)&quot;;}<br>
  if($AA =~ /^V$/){ $AA =&quot;Valine(V)&quot;;}<br>
  if($AA =~ /^W$/){ $AA =&quot;Tryptophan(W)&quot;;}<br>
  if($AA =~ /^Y$/){ $AA =&quot;Tyrosine(Y)&quot;;}<br>
  return $AA;<br>
  }</p>
<p># protein for the proteome<br>
  sub displayAAOccurences{</p>
<p> my $AA = shift;<br>
  my ($dataset) =shift;<br>
  my $string;<br>
  my $description = aminoAcids($AA);</p>
<p> $string = &quot;&lt;table border celllpadding=10 cellspacing=0 align=center width=100%&gt;\n&quot;;<br>
  $string .= &quot;&lt;tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;th bgcolor=#800000&gt;&lt;font size=4 color=#FFFFFF&gt;$description&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  for my $a (0 .. @{$dataset}-1) {<br>
  $string .= &quot;&lt;th bgcolor=#800000&gt;&lt;font size=4 color=#FFFFFF&gt;$a&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  }<br>
  $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;th align=left&gt;&lt;font size=4&gt;Count&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  for my $a (0 .. @{$dataset}-1) {<br>
  $string .= &quot;&lt;td align=center&gt;@{$dataset}[$a]&lt;/td&gt;\n&quot;;<br>
  }<br>
  $string .= &quot;&lt;/tr&gt;&lt;tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;th align=left&gt;&lt;font size=4&gt;Fraction&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  for my $a (0 .. @{$dataset}-1) {<br>
  my $fraction = (@{$dataset}[$a])/($totalProteins);<br>
  $fraction = sprintf(&quot;%.3f&quot;,$fraction);<br>
  $string .= &quot;&lt;td&gt;$fraction&lt;/td&gt;\n&quot;;<br>
  }</p>
<p> $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  $string .= &quot;&lt;/table&gt;&lt;br&gt;&lt;br&gt;\n&quot;;<br>
  print SUMMARY $string ;<br>
  }</p>
<p># this subroutine takes care of displaying amino acid occurences per protein<br>
  # for the proteome<br>
  sub aminoAcidOccurences(){<br>
  my $max = 50;<br>
  my $AA; my $val;</p>
<p> for my $i (0 .. $#AA_perProtein){<br>
  my @occurances;<br>
  for my $a (0 .. $max-1){<br>
  $occurances[$a]=0;<br>
  }<br>
  for my $j (0 .. $#{$AA_perProtein[$i]}){<br>
  ($AA,$val) = split(/=/,$AA_perProtein[$i][$j]);<br>
  if($val &lt; $max){<br>
  $occurances[$val]++;<br>
  }<br>
  }<br>
  displayAAOccurences($AA,\@occurances);<br>
  @occurances=();<br>
  }</p>
<p>}<br>
</p>
<p># caclulates and displays amino acid composition for each protein<br>
  sub aminoAcidStatistics(){<br>
  my $amino_acid;<br>
  my $HEADER;<br>
  my $val;<br>
  my $max;<br>
  for my $i (0 .. 19){<br>
  my @amino_acid_count;<br>
  my @AA;<br>
  for my $a (0 ..$#amino_acid_protein) {<br>
  if($amino_acid_protein[$a][0] !~ /^$/){<br>
  ($amino_acid,$val) = split(/=/,$amino_acid_protein[$a][0]);<br>
  }<br>
  else{ $val =0;}<br>
  push(@amino_acid_count,$val);<br>
  # remove the element<br>
  shift @{$amino_acid_protein[$a]};<br>
  # rebuild the array for later use<br>
  my $element = join(&quot;=&quot;,$amino_acid,$val);<br>
  push(@AA,$element);<br>
  }<br>
  push (@AA_perProtein,[@AA]);<br>
  # keeps track of the maximum amount of amino acid per protein for the<br>
  # displaying of occurences of amino acids<br>
  $max = fillStatistics($amino_acid,\@amino_acid_count);<br>
  }</p>
<p>}</p>
<p>sub fillStatistics(){<br>
  my $description = shift;<br>
  my ($dataset) = shift;<br>
  my @dup = @{$dataset};<br>
  @dup = sort{$b&lt;=&gt;$a} @dup;<br>
  my $string;<br>
  my $avg = average(\@dup);<br>
  $avg = sprintf(&quot;%.3f&quot;,$avg);<br>
  my $std = standard_deviation(\@dup);<br>
  $std = sprintf(&quot;%.3f&quot;,$std);<br>
  my $total = sum(\@dup);<br>
  $total = sprintf(&quot;%.0f&quot;,$total);<br>
  my $max = $dup[0];<br>
  my $min = $dup[$#dup];<br>
  if($description =~ /^Isotopic Mass$/ ||$description =~ /^Average Mass$/||$description =~ /^Isoelectric Point$/ ){<br>
  $avg = $b = sprintf(&quot;%.2f&quot;, $avg);<br>
  $max = sprintf(&quot;%.0f&quot;,$max);<br>
  $min = sprintf(&quot;%.0f&quot;,$min);<br>
  $total = sprintf(&quot;%.2f&quot;,$total);<br>
  }<br>
  $string = &quot;&lt;tr&gt;\n&quot;;<br>
  $string .= &quot; &lt;th align=left&gt;&lt;font size=4&gt;$description&lt;/font&gt;&lt;/th&gt;\n&quot;;<br>
  $string .= &quot; &lt;td align=center&gt;$avg&lt;/td&gt;\n&quot;;<br>
  $string .= &quot; &lt;td align=center&gt;$std&lt;/td&gt;\n&quot;;<br>
  $string .= &quot; &lt;td align=center&gt;$max&lt;/td&gt;\n&quot;;<br>
  $string .= &quot; &lt;td align=center&gt;$min&lt;/td&gt;\n&quot;;<br>
  $string .= &quot; &lt;td align=center&gt;$total&lt;/td&gt;\n&quot;;<br>
  $string .= &quot;&lt;/tr&gt;\n&quot;;<br>
  print SUMMARY $string;<br>
  # useful only when displaying the amino acid occurence<br>
  return ($dup[0]);<br>
  }<br>
</p>
<p>sub writeSummary(){<br>
  my $cleavage = join('X,',@breakAt);<br>
  $cleavage .= 'X';<br>
  my $HEADER;<br>
  $HEADER=&lt;&lt;END;<br>
&lt;html&gt;<br>
&lt;head&gt;<br>
&lt;title&gt; Proteome Summary&lt;/title&gt;<br>
&lt;/head&gt;</p>
<p> &lt;body&gt;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font face=&quot;Arial&quot;&gt;&lt;b&gt;ProteoGest ANALYSIS of '$input_file' digested with $cleavage&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
&lt;br&gt;<br>
&lt;p&gt;&lt;font size=&quot;3&quot; color=&quot;111111&quot;&gt;&lt;b&gt;Options:&lt;/b&gt; -i $opt_i -d $opt_d -a $opt_a -c $opt_c -s $opt_s -S $opt_S $opt_T $opt_Y $opt_R $opt_W $opt_I $opt_M $opt_C $opt_N $opt_G $opt_L -H $opt_H $opt_h&lt;/font&gt;&lt;/p&gt;<br>
&lt;p&gt;&lt;font size=&quot;3&quot; color=&quot;111111&quot;&gt;&lt;b&gt;TOTAL NUMBER OF PEPTIDES:&lt;/b&gt; $totalPeptides&lt;/font&gt;&lt;/p&gt;<br>
&lt;p&gt;&lt;font size=&quot;3&quot; coslor=&quot;111111&quot;&gt;&lt;b&gt;TOTAL NUMBER OF PROTEINS:&lt;/b&gt; $totalProteins&lt;/font&gt;&lt;/p&gt;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font face=&quot;Arial&quot;&gt;&lt;b&gt;PROTEIN ANALYSIS of '$input_file' proteome&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
  END<br>
  print SUMMARY $HEADER;<br>
  physicalStatistics(&quot;Protein&quot;);<br>
  $HEADER=&lt;&lt;END;<br>
&lt;br&gt;&lt;br&gt;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font face=&quot;Arial&quot;&gt;&lt;b&gt;Distribution of Protein Properties for '$input_file'&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
&lt;br&gt;<br>
  END<br>
  print SUMMARY $HEADER;<br>
  physicalProperties(&quot;Length(AA)&quot;,100,10,\@len_protein,&quot;Proteins&quot;,0);<br>
  physicalProperties(&quot;Isotopic Mass&quot;,10000,10,\@isoMass_protein,&quot;Proteins&quot;,0);<br>
  physicalProperties(&quot;Average Mass&quot;,10000,10,\@avgMass_protein,&quot;Proteins&quot;,0);<br>
  $HEADER=&lt;&lt;END;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font face=&quot;Arial&quot;&gt;&lt;b&gt;Protein Statistics (Amino Acid Composition) &lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
&lt;table border celllpadding=&quot;10&quot; cellspacing=&quot;0&quot; align=&quot;center&quot; width=&quot;100%&quot;&gt;<br>
  END<br>
  print SUMMARY $HEADER;<br>
  physicalStatistics(&quot;Protein/AA&quot;);</p>
<p>$HEADER=&lt;&lt;END;<br>
&lt;br&gt;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font face=&quot;Arial&quot;&gt;&lt;b&gt;Protein Statistics (Residue Representation)&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
&lt;p align=&quot;center&quot;&gt;This table lists the frequency of each amino acid residue per protein for the proteome&lt;/p&gt;<br>
  END<br>
  print SUMMARY $HEADER;<br>
  aminoAcidOccurences();<br>
  $HEADER=&lt;&lt;END;<br>
&lt;br&gt;&lt;br&gt;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font face=&quot;Arial&quot;&gt;&lt;b&gt;PEPTIDE ANALYSIS for '$input_file' digested with $cleavage&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font face=&quot;Arial&quot;&gt;&lt;b&gt;Peptide statistics(Digestion of '$input_file' with $cleavage)&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
  END<br>
  print SUMMARY $HEADER;<br>
  physicalStatistics(&quot;Peptide&quot;);<br>
</p>
<p>$HEADER=&lt;&lt;END;<br>
&lt;br&gt;&lt;br&gt;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font face=&quot;Arial&quot;&gt;&lt;b&gt;Distribution of peptide properties in '$input_file' proteome following digestion with $cleavage&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
&lt;br&gt;<br>
  END<br>
  print SUMMARY $HEADER;<br>
  physicalProperties(&quot;Length(AA)&quot;,5,10,\@len_peptide,&quot;Peptides&quot;,0);<br>
  physicalProperties(&quot;Isotopic Mass&quot;,500,10,\@isoMass_peptide,&quot;Peptides&quot;,0);<br>
  physicalProperties(&quot;Average Mass&quot;,500,10,\@avgMass_peptide,&quot;Peptides&quot;,0);<br>
  physicalProperties(&quot;Hydrophobicity&quot;,1,10,\@hydrophobicity_peptide,&quot;Peptides&quot;,-4);<br>
  physicalProperties(&quot;Charge&quot;,1,10,\@charge_peptide,&quot;Peptides&quot;,-6);<br>
  $HEADER=&lt;&lt;END;<br>
&lt;p align=&quot;center&quot;&gt;&lt;font size=&quot;5&quot; color=&quot;#000080&quot; font<br>
  face=&quot;Arial&quot;&gt;&lt;b&gt;Protein-Peptide Statistics (Amino Acid Representation)&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;<br>
&lt;p align=&quot;center&quot;&gt;This Table lists the number (and<br>
  fraction) of proteins with peptides with the tabulated number of each amino acid eg.<br>
  the first table lists the count of proteins with peptides that contain at least<br>
  0,1,2,3,4,5,6,7,8,9,10,... alanines (top row). The next row<br>
  gives the same data represented as the fraction of all proteins.&lt;/p&gt;<br>
&lt;table border celllpadding=&quot;10&quot; cellspacing=&quot;0&quot; align=&quot;center&quot; width=&quot;100%&quot;&gt;<br>
  END<br>
  print SUMMARY $HEADER;<br>
  aminoAcidRepPeptide();<br>
</p>
<p>if($opt_H==1 &amp;&amp;$display_redun==1){<br>
  # display the redundancy if asked by the user<br>
  print SUMMARY &quot;&lt;p align=\&quot;center\&quot;&gt;&lt;font size=\&quot;5\&quot; color=\&quot;#000080\&quot; font face=\&quot;Arial\&quot;&gt;&lt;b&gt;Redundant Peptides&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;\n&quot;;<br>
  print SUMMARY &quot;&lt;p align=\&quot;center\&quot;&gt;This Table lists peptides that occur in more than one protein&lt;/p&gt;\n&quot;;<br>
  displayRedundancy();<br>
  }<br>
  elsif($opt_H==1 &amp;&amp;$display_redun==0){<br>
  # display the redundancy if asked by the user<br>
  print SUMMARY &quot;&lt;p align=\&quot;center\&quot;&gt;&lt;font size=\&quot;5\&quot; color=\&quot;#000080\&quot; font face=\&quot;Arial\&quot;&gt;&lt;b&gt;Redundant Peptides&lt;/b&gt;&lt;/font&gt;&lt;/p&gt;\n&quot;;<br>
  print SUMMARY &quot;&lt;p align=\&quot;center\&quot;&gt;&lt;font size=\&quot;5\&quot;color=\&quot;red\&quot;&gt; NO REDUNDANCY DETECTED IN THIS PROTEOME!&lt;/font&gt;&lt;/p&gt;\n&quot;;<br>
  }<br>
  print SUMMARY &quot;&lt;/body&gt;\n&quot;;<br>
  print SUMMARY &quot;&lt;/html&gt;\n&quot;;<br>
  }<br>
</p>
<p># this subroutine displays the redundancy peptides in the summary file<br>
  sub displayRedundancy(){<br>
  my $HEAD;<br>
  my $string;<br>
  $HEAD=&lt;&lt;END;</p>
<p> &lt;center&gt;<br>
&lt;table border=&quot;1&quot; celllpadding=&quot;0&quot; cellspacing=&quot;0&quot; style=&quot;border-collapse: collapse&quot; align=&quot;center&quot; width=&quot;80%&quot;&gt;<br>
&lt;tr&gt;<br>
&lt;th width='25%' bgcolor='#800000'&gt;&lt;font size='4' color='#FFFFFF'&gt;Peptide&lt;/font&gt;&lt;/th&gt;<br>
&lt;th width= '75%' bgcolor='#800000'&gt;&lt;font size='4' color='#FFFFFF'&gt;Name of the protein&lt;/font&gt;&lt;/th&gt;<br>
&lt;/tr&gt;<br>
  END<br>
  print SUMMARY $HEAD;</p>
<p>foreach my $b (sort keys %redun_hash){<br>
    <br>
  if(@{$redun_hash{$b}} &gt; 1){<br>
  $string = &quot;&lt;tr&gt;\n&lt;td width='25%'&gt;$b&lt;/td&gt;\n&quot;;<br>
  $string .= &quot;&lt;td width='75%'&gt;\n&quot;;<br>
  my $i=0;<br>
  foreach my $protein (@{$redun_hash{$b}}){<br>
  ++$i;<br>
  $string .= &quot;$i) $protein&lt;br&gt;\n&quot;;<br>
  #print &quot;REDUN: $b=&gt;$protein,\n&quot;;<br>
  }<br>
  $string .= &quot;&lt;/td&gt;\n&lt;/tr&gt;\n&quot;;</p>
<p> print SUMMARY $string;<br>
  }<br>
  }<br>
  print SUMMARY &quot;&lt;/table&gt;&lt;/center&gt;\n&quot;;<br>
  }</p>
<p># The MAX number defined here can be changed. The MAX number defines<br>
  # the column headers. Column 0 contains all the amino acids.<br>
  sub initilizePeptideStatisticsArray{<br>
  # there are 20 amino acids<br>
  $amino_acid_peptide[0][0] =&quot;A&quot;;<br>
  $amino_acid_peptide[1][0] =&quot;C&quot;;<br>
  $amino_acid_peptide[2][0] =&quot;D&quot;;<br>
  $amino_acid_peptide[3][0] =&quot;E&quot;;<br>
  $amino_acid_peptide[4][0] =&quot;F&quot;;<br>
  $amino_acid_peptide[5][0] =&quot;G&quot;;<br>
  $amino_acid_peptide[6][0] =&quot;H&quot;;<br>
  $amino_acid_peptide[7][0] =&quot;I&quot;;<br>
  $amino_acid_peptide[8][0] =&quot;K&quot;;<br>
  $amino_acid_peptide[9][0] =&quot;L&quot;;<br>
  $amino_acid_peptide[10][0] =&quot;M&quot;;<br>
  $amino_acid_peptide[11][0] =&quot;N&quot;;<br>
  $amino_acid_peptide[12][0] =&quot;P&quot;;<br>
  $amino_acid_peptide[13][0] =&quot;Q&quot;;<br>
  $amino_acid_peptide[14][0] =&quot;R&quot;;<br>
  $amino_acid_peptide[15][0] =&quot;S&quot;;<br>
  $amino_acid_peptide[16][0] =&quot;T&quot;;<br>
  $amino_acid_peptide[17][0] =&quot;V&quot;;<br>
  $amino_acid_peptide[18][0] =&quot;W&quot;;<br>
  $amino_acid_peptide[19][0] =&quot;Y&quot;;<br>
  for my $q (0 .. 19){<br>
  for my $z (1 .. MAX){<br>
  $amino_acid_peptide[$q][$z]=&quot;0=F&quot;;<br>
  }<br>
  }</p>
<p>}</p>
<p># After each protein the elements in amino_acid_peptide multi- dimensional<br>
  # array gets re-initilized for the next count.<br>
  sub initializeValues{<br>
  for my $v (0 .. $#amino_acid_peptide){<br>
  for my $w (1 .. $#{$amino_acid_peptide[$v]}){<br>
  my ($val,$bool) =split(/=/,$amino_acid_peptide[$v][$w]);<br>
  $amino_acid_peptide[$v][$w] = &quot;$val&quot;.&quot;=F&quot;;<br>
  }<br>
  }<br>
  }</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p># this is the entry point to the program<br>
  # reads the file until the eof is satisfied<br>
  sub main(){</p>
<p> # if user wants the simple file<br>
  if($opt_d==1){<br>
  # writes the protein name<br>
  print SIMPLE &quot;$opt_i digested with $opt_c\n&quot;;<br>
  print SIMPLE &quot;Options: -i $opt_i -d $opt_d -a $opt_a -c $opt_c -s $opt_s -S $opt_S $opt_T $opt_Y $opt_R $opt_W $opt_I $opt_M $opt_C $opt_N $opt_G $opt_L -H $opt_H $opt_h \n&quot;;<br>
  print SIMPLE &quot;\n&quot;;<br>
  print SIMPLE &quot;\n&quot;;<br>
  }</p>
<p> if($opt_a==1){<br>
  print ANNOTATED &quot;$opt_i digested with $opt_c\n&quot;;<br>
  print ANNOTATED &quot;Options: -i $opt_i -d $opt_d -a $opt_a -c $opt_c -s $opt_s -S $opt_S $opt_T $opt_Y $opt_R $opt_W $opt_I $opt_M $opt_C $opt_N $opt_G $opt_L -H $opt_H $opt_h \n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  print ANNOTATED &quot;\n&quot;;<br>
  }</p>
<p> while (&lt;INPUT_FASTA&gt;) {<br>
  # gets rid of carriage return<br>
  $_ =~ s/\r//g;<br>
  # gets rid of new line character<br>
  chomp ($_);<br>
  # discards the first line which does not contain any amino acids<br>
  if($_ =~ /^&gt;/){<br>
  process();<br>
  $protein_name = $_;<br>
  $protein_name =~ s/^\&gt;//g;<br>
  undef $protein;<br>
  undef %peptide_hash;<br>
  ;<br>
  }<br>
  else{<br>
  # reads each line containing amino acids of one protein and joins them to create the entire protein<br>
  # stops when the new protein is reached<br>
  $protein = $protein.$_;<br>
  }<br>
  }<br>
  process();</p>
<p> if($opt_s==1){<br>
  writeSummary();<br>
  }</p>
<p>} # end main</p>
</body>
</html>
