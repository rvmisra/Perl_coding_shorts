#!/usr/bin/perl

# USAGE:
# the cgi-version needs a html-form passing 2 values with post-method
# 1) the name of patch-blast file
# 2) the number of hits to parse per each query

# NOTE: tested with outputfiles from gepardi.csc.fi
# paracell patch blast

#use warnings;
#use CGI;

#Initializing variables
my ($inline);
my ($indexnumber) = 0;
my ($numberofhits) = 5;
my ($firstline);
my ($nextline);
my ($lastline) =" ";
my ($expect);
my ($identities);
my ($foundannotations);
my ($beginningmarker);
my ($queryname) ="beginning";
my ($cgi_tiedot, $name, $nimi, $number);
my (@accessionnumberlist);

#Creating a new CGI-object,
#to handle the information passed in the form
#$cgi_tiedot = CGI->new();
#$blastfilename = $cgi_tiedot->param('nimi');
#$hitnumber = $cgi_tiedot->param('number');
#$downloadthis = $cgi_tiedot->param('downloadthis');
#$ignoreflag = $cgi_tiedot->param('ignoreflag');

$downloadthis = 0;

unless(@ARGV) {
	print $USAGE;
	#ask for blast result file
	print "please give the name of the paracell patch BLASTn or BLASTx result file: ";
	$blastfilename = <STDIN>;
	}
else{
	$blastfilename = @ARGV[0];
}	

	print "***\nSIMPLEPARSE version 0.7 written by Markus Storvik\n";
	print "Laboratory of Functional Genomics and Bioinformatics\n";
	print "AIV Institute, University of Kuopio\n***\n"; 

#BEGINNING OF THE BLAST PARSER

$inputfilename = $blastfilename;

chomp($inputfilename);
open (INFILE, "<$inputfilename") or die "Can't open $inputfilename for input - $!";
my (@inlines) = <INFILE>;
close INFILE;

$outputfilename = $inputfilename .'.parsed';
open (OUTFILE,">$outputfilename");

print (OUTFILE "INPUT FILE: $inputfilename\n");
print (OUTFILE "ANNOTATIONS, with chromosomal, genomic, patent, and plasmids ignored\n");
my $DATE = `/bin/date`;
chomp( $DATE );
print (OUTFILE "date: $DATE\n\n");
print (OUTFILE "AccNo of the blast query\tgene name of Blast result\tgene AccNo\tExp value (E - value)\t\tgene name of Blast result\tgene AccNo\tExp value (E - value)\n");

	print "please give the maximal number of results (5-30): ";
	$hitnumber = <STDIN>;


print "ignore ESTs, patents, clones, and most libraries which do not help during the annotation process: ";
	$ignore = <STDIN>;
if ($ignore=~ /y/i){
		$ignoreflag =1;	
	}
	else {
		$ignoreflag =0;	
	}


print "ignore non-mammal sequences: ";
	$nonmammal = <STDIN>;
if ($nonmammal=~ /y/i){
		$nonmammalflag =1;	
	}
	else {
		$nonmammalflag =0;	
	}

	if ($ignoreflag==0) {
		if ($nonmammalflag==0) {
			print "Writing all found hits into $outputfilename\n";
			IGNOROIMATON_SORTTAUS(); # ei poista klooneja, ei poista ep�mammaleita
		}
		else {
			print "Writing all found hits into $outputfilename\n";
	 		print "EXCEPT zebrafish, dosophila, arabidopsis, and xenobus
sequences\n";
			ONLYMAMMAL_SORTTAUS(); # ei poista klooneja, poistaa ep�mammalit 
		}
	}

	elsif ($ignoreflag==1){
		if ($nonmammalflag==1){
			print "Writing found hits into $outputfilename\n";
			print "EXCEPT those from model organisms\n";
			print "or ESTs, genomic sequences and clones\n";
			IGNOROIVA_SORTTAUS(); # poistaa kloonit, poistaa ep�mammalit
			}
		else	{
			print "Writing all hits into $outputfilename\n";
			print "EXCEPT ESTs, genomic sequences and clones\n";
			NOCLONES_SORTTAUS(); # poistaa kloonit, ei poista ep�mammaleja
			}
	}



############# EXIT RITUALS ####################
print "done\n";
close OUTFILE;


############# PROGRAM END ####################











sub ONLYMAMMAL_SORTTAUS

#### removes most zebrafish, arabidopsis, drosophila etc. requences ###
### does NOT remove any ESTs or library sequences ####
{
my $DATE = `/bin/date`;
chomp( $DATE );

$thisisbeginning = 1;
foreach $inline (@inlines)
{
	if ($inline =~ /^\s*Query=.*$/ )
	{
		$queryname = "$&";
		$queryname =~ tr/Query=/ /;
		$queryname =~ s/UI(.*?)$//;
###gi|4287963|gb|AA998164.1|AA998164 taking the last part	
## works with gepardi blast server, but is a potential problem point
                @otetaanquerynamevaikeasti = split(/\|/, $queryname);
		$queryname = @otetaanquerynamevaikeasti[4];
				#$queryname =~ s/^*(.*?)\|//gi;
				#$queryname =~ s/^*(.*?)\|//gi; #linux only??
		$numberofhits = $hitnumber +1;
		$foundannotations = 0;
	}

	if ($numberofhits>1)
	{
	    if ($inline =~ /^\s*>.*$/ ){
		$firstline = "$&";
		chomp $firstline;
		$firstline =~ s/\t*//g ;
		$indexnumber = $indexnumber = 2;
		$annotationline = $firstline;
	    }
	   elsif ($indexnumber == 2)
		{
		$lastline = $inline;
		chomp ($lastline);
		$indexnumber = 1;
		chomp ($annotationline);
		$annotationline = $annotationline . $lastline;
		}
	    if ($inline =~ /^\s*Score.*$/ ){
		$expect = "$&";
		$expect =~ tr/Score =/ /;
		$expect =~ tr/bits/ /;
		$expect =~ s/\n//g ;
			@ekatoka = split(/Exp/, $expect);
			$eka = pop @ekatoka;
			$toka = pop @ekatoka;

	    }
	    if ($inline =~ /^\s*Identities.*$/ ){

	if ($eka =~ /-\d*/ ){
	@eksponentti = split(/\-/, $eka);
	$eksponentti = pop @eksponentti;
	$eksponentti .= "\t";
		
	}
	else{
	$eksponentti = 05;
	}

### IGNORING HERE ###
                if ($annotationline=~ /chromosome|genomic clone|RIKEN full|expressed sequence tag|Normalized rat|cDNA,
RIKEN|cDNA,RIKEN|subtracted library|cDNA Library|cDNA clone|patent|enriched library|cDNA, clone|DRAFT|RIKEN full-length
microsatellite sequence|Xdirected cDNA|fis, clone|genomic clone|EST clone|partial sequence|UI-R-|SEQUENCING|BAC library|RAGE library/i){
                }
                elsif ($annotationline=~ /LOW-PASS|clone MGC|cDNA FLJ|BAC (Library|clone)/){
                }
                elsif ($annotationline=~ /zebrafish|xenopus|drosophila|elegans/i){
                }
		else{
		  if ($eksponentti=~ /\d\t/){
			$firstline =~ s/\n//g ;
			$firstline =~ s/\s+$// ;
			$lastline =~ s/\n//g ;
			chomp ($annotationline);
			$annotationline =~ tr/\t*/ / ;
			$annotationline =~ s/\t*//g ;
			$annotationline =~ s/\n//g ;
			chop ($annotationline);
			

			if ($numberofhits == $hitnumber){
			}

			$numberofhits = $numberofhits -1;	
				$firstline =~ s/Mus musculus/Mouse/;
				$firstline =~ s/>\w\w\d{5,7}//;
				$annotationline =~ s/          //;

#VOISI OTTAA ACCESSNUMERON ERILLEEN
				$otetaanaccessnro = $annotationline;
					@otetaanaccessnro = split(/ /, $otetaanaccessnro);

#JA SITTEN SE VIELÄ POISTETAAN ANNOTATIONLINESTÄ
				$annotationline =~ s/@otetaanaccessnro[0]//;
				@otetaanaccessnro[0] =~ s/>//;

					@removeLength = split(/Length =/, $annotationline);
				$alku = @removeLength[0];
				$alku =~ s/Rattus norvegicus/Rat/i;
				$alku =~ s/Mus musculus/Mouse/i;
				$alku =~ s/M.musculus/Mouse/i;
				$alku =~ s/Homo Sapiens/Human/i;

				push (@parsed_eksponentti, $eksponentti);

$blah = @otetaanaccessnro[0];
			if ($foundannotations == 0){
				print (OUTFILE "\n$queryname\t");
			$foundannotations = $foundannotations +1;
				}
			if (length($blah) != 0){
				$alku=~ s/^([0-9A-Za-z]{4-9})//;
				$alku=~ s/^\s*[0-9A-Za-z][0-9A-Za-z]*.1//;

				print (OUTFILE "$alku\t@otetaanaccessnro[0]\t-$eksponentti\t");

				#@tamanhetkinen = ($alku,otetaanaccessnro[0],$eksponentti);
				}
			if ($numberofhits == 5){
			}
		   }	
		}
	    }
	}
}
}








sub IGNOROIVA_SORTTAUS
## the tightest filter of this parser ##
## ignores both non-mammal sequences, and library rubbish ##

{

my $DATE = `/bin/date`;
chomp( $DATE );

$thisisbeginning = 1;
foreach $inline (@inlines)
{

	if ($inline =~ /^\s*Query=.*$/ )
	{
		$queryname = "$&";
		$queryname =~ tr/Query=/ /;
		$queryname =~ s/UI(.*?)$//;
				#$queryname =~ s/^*[w]\|/ /gi;
				###gi|4287963|gb|AA998164.1|AA998164  otetaan viimeinen osa
		
		@otetaanquerynamevaikeasti = split(/\|/, $queryname);
		$queryname = @otetaanquerynamevaikeasti[4];
				#$queryname =~ s/^*(.*?)\|//gi;
				#$queryname =~ s/^*(.*?)\|//gi; #just do not ask..
		$numberofhits = $hitnumber +1;
		$foundannotations = 0;
	}

	if ($numberofhits>1)
	{
	    
	    if ($inline =~ /^\s*>.*$/ ){
		$firstline = "$&";
		chomp $firstline;
		$firstline =~ s/\t*//g ;
		$indexnumber = $indexnumber = 2;
		$annotationline = $firstline;
	    }

	   elsif ($indexnumber == 2)
		{
		$lastline = $inline;
		chomp ($lastline);
		$indexnumber = 1;
		chomp ($annotationline);
		$annotationline = $annotationline . $lastline;
		}

	    if ($inline =~ /^\s*Score.*$/ ){
		$expect = "$&";
		$expect =~ tr/Score =/ /;
		$expect =~ tr/bits/ /;
		$expect =~ s/\n//g ;
			@ekatoka = split(/Exp/, $expect);
			$eka = pop @ekatoka;
			$toka = pop @ekatoka;

	    }

	    if ($inline =~ /^\s*Identities.*$/ ){

	if ($eka =~ /-\d*/ ){
	@eksponentti = split(/\-/, $eka);
	$eksponentti = pop @eksponentti;
	$eksponentti .= "\t";
		
	}
	else{
	$eksponentti = 05;
	}

### IGNORING HERE ###
## does ignore most ests, libraries and other rubbish
                if ($annotationline=~ /chromosome|genomic clone|RIKEN full|expressed sequence tag|Normalized rat|cDNA,
RIKEN|cDNA,RIKEN|subtracted library|cDNA Library|cDNA clone|patent|enriched library|cDNA, clone|DRAFT|RIKEN full-length
microsatellite sequence|Xdirected cDNA|fis, clone|genomic clone|EST clone|partial sequence|UI-R-|SEQUENCING|BAC library|RAGE library/i){
                }
                elsif ($annotationline=~ /LOW-PASS|clone MGC|cDNA FLJ|BAC (Library|clone)/){
                }
		else{
		  if ($eksponentti=~ /\d\t/){
		
#nyt delattu			$annotationline = $firstline . $lastline;		
			$firstline =~ s/\n//g ;
			$firstline =~ s/\s+$// ;
			$lastline =~ s/\n//g ;
#			$lastline =~ s/^\s+//;
#			$lastline = split(/Length/, $lastline);
			chomp ($annotationline);
			$annotationline =~ tr/\t*/ / ;
			$annotationline =~ s/\t*//g ;
			$annotationline =~ s/\n//g ;


			if ($numberofhits == $hitnumber){
		#JOO			print (OUTFILE "$queryname\n");
			}

			$numberofhits = $numberofhits -1;	
				$firstline =~ s/Mus musculus/Mouse/;
				$firstline =~ s/>\w\w\d{5,7}//;
				$annotationline =~ s/          //;

#VOISI OTTAA ACCESSNUMERON ERILLEEN
				$otetaanaccessnro = $annotationline;
					@otetaanaccessnro = split(/ /, $otetaanaccessnro);

#JA SITTEN SE VIELÄ POISTETAAN ANNOTATIONLINESTÄ
				$annotationline =~ s/@otetaanaccessnro[0]//;
				@otetaanaccessnro[0] =~ s/>//;

					@removeLength = split(/Length =/, $annotationline);
				$alku = @removeLength[0];
				$alku =~ s/Rattus norvegicus/Rat/i;
				$alku =~ s/Mus musculus/Mouse/i;
				$alku =~ s/M.musculus/Mouse/i;
				$alku =~ s/Homo Sapiens/Human/i;

				push (@parsed_eksponentti, $eksponentti);

$blah = @otetaanaccessnro[0];
			if ($foundannotations == 0){
				print (OUTFILE "\n$queryname\t");

			$foundannotations = $foundannotations +1;
				}
			if (length($blah) != 0){
				$alku=~ s/^([0-9A-Za-z]{4-9})//;
				$alku=~ s/^\s*[0-9A-Za-z][0-9A-Za-z]*.1//;

				print (OUTFILE "$alku\t@otetaanaccessnro[0]\t-$eksponentti\t");

				#@tamanhetkinen = ($alku,otetaanaccessnro[0],$eksponentti);
				}



			if ($numberofhits == 5){
			}
		   }	
		}
	    }
	}
}

#### END OF IGNOROIVA SORTTAUS ####







sub NOCLONES_SORTTAUS
{
my $DATE = `/bin/date`;
chomp( $DATE );

$thisisbeginning = 1;
foreach $inline (@inlines)
{

	if ($inline =~ /^\s*Query=.*$/ )
	{
		$queryname = "$&";
		$queryname =~ tr/Query=/ /;
		$queryname =~ s/UI(.*?)$//;
                @otetaanquerynamevaikeasti = split(/\|/, $queryname);
                $queryname = @otetaanquerynamevaikeasti[4];
#		$queryname =~ s/^*[w]\|/ /gi;
#		$queryname =~ s/^*(.*?)\|//gi; #just do not ask..
		$numberofhits = $hitnumber +1;
		$foundannotations = 0;
	}

	if ($numberofhits>1)
	{
	    
	    if ($inline =~ /^\s*>.*$/ ){
		$firstline = "$&";
		chomp $firstline;
		$firstline =~ s/\t*//g ;
		$indexnumber = $indexnumber = 2;
		$annotationline = $firstline;
	    }

	   elsif ($indexnumber == 2)
		{
		$lastline = $inline;
		chomp ($lastline);
		$indexnumber = 1;
		chomp ($annotationline);
;
		$annotationline = $annotationline . $lastline;
		}

	    if ($inline =~ /^\s*Score.*$/ ){
		$expect = "$&";
		$expect =~ tr/Score =/ /;
		$expect =~ tr/bits/ /;
		$expect =~ s/\n//g ;
			@ekatoka = split(/Exp/, $expect);
			$eka = pop @ekatoka;
			$toka = pop @ekatoka;

	    }

	    if ($inline =~ /^\s*Identities.*$/ ){

	if ($eka =~ /-\d*/ ){
	@eksponentti = split(/\-/, $eka);
	$eksponentti = pop @eksponentti;
	$eksponentti .= "\t";
		
	}
	else{
	$eksponentti = 05;
	}


		if ($annotationline=~ /chromosome|genomic clone|RIKEN full|expressed sequence tag|Normalized rat|cDNA,
RIKEN|cDNA,RIKEN|subtracted library|cDNA Library|cDNA clone|patent|enriched library|cDNA, clone|DRAFT|RIKEN full-length
microsatellite sequence|Xdirected cDNA|fis, clone|genomic clone|EST clone|partial sequence|UI-R-|SEQUENCING|BAC library/i){
		}
		elsif ($annotationline=~ /days embryo|adult male|heart cDNA|mRNA, clone|fertilized egg|genomic clone|Kaestner|days
neonate|soares mouse|-day embryo|RAGE library/i){
		}
		elsif ($annotationline=~ /LOW-PASS|clone MGC|cDNA FLJ|day embryo cDNA|BAC (Library|clone)/){
		}
		elsif ($annotationline=~ /adult male testis|DRG Library|in vitro fertilized|retina lambd|adult male tongue|10-day 
embryo|18-day embryo|17-day embryo|16-day embryo|15-day embryo|RIKEN cDNA|clone IMAGE|16-cell embryo|adult male urinary|Rat clone RP|NIA
Mouse Hematopoietic|-cell embryo|month neonate|dpc blastocyst cDNA|0 day neonate/i){
		}


		

		else{
		  if ($eksponentti=~ /\d\t/){
		
#nyt delattu			$annotationline = $firstline . $lastline;		
			$firstline =~ s/\n//g ;
			$firstline =~ s/\s+$// ;
			$lastline =~ s/\n//g ;
#			$lastline =~ s/^\s+//;
#			$lastline = split(/Length/, $lastline);
			chomp ($annotationline);
			$annotationline =~ tr/\t*/ / ;
			$annotationline =~ s/\t*//g ;
			$annotationline =~ s/\n//g ;
			chop ($annotationline);
			
			
#			if ($expect =~ /^\s*Exp=.*$/ ){
#			}

#			$identities = "$&\n";
#			$identities =~ s/\n//g ;
#			$identities =~ /^Identities(.+)$/;


			if ($numberofhits == $hitnumber){
	#			print "\n\n$queryname blasted:";
		#JOO			print (OUTFILE "$queryname\n");
			}

			$numberofhits = $numberofhits -1;

				$firstline =~ s/Mus musculus/Mouse/;
				$firstline =~ s/>\w\w\d{5,7}//;
				$annotationline =~ s/          //;

#VOISI OTTAA ACCESSNUMERON ERILLEEN
				$otetaanaccessnro = $annotationline;
					@otetaanaccessnro = split(/ /, $otetaanaccessnro);

#JA SITTEN SE VIELÄ POISTETAAN ANNOTATIONLINESTÄ
				$annotationline =~ s/@otetaanaccessnro[0]//;
				@otetaanaccessnro[0] =~ s/>//;
#				print (OUTFILE "aaa$annotationlineaaa\t");
#				$blah = @otetaanaccessnro[0];

					@removeLength = split(/Length =/, $annotationline);
				$alku = @removeLength[0];
				$alku =~ s/Rattus norvegicus/Rat/i;
				$alku =~ s/Mus musculus/Mouse/i;
				$alku =~ s/M.musculus/Mouse/i;
				$alku =~ s/Homo Sapiens/Human/i;

#				push (@parsed_query, $queryname);
#				push (@parsed_annotation, $annotationline);
				push (@parsed_eksponentti, $eksponentti);
#				print "$alku";
#				print "<BR>";
#				print"@otetaanaccessnro[0]";

$blah = @otetaanaccessnro[0];
			if ($foundannotations == 0){
				print (OUTFILE "\n$queryname\t");
			$foundannotations = $foundannotations +1;
				}
			if (length($blah) != 0){
				print (OUTFILE "$alku\t@otetaanaccessnro[0]\t-$eksponentti\t");

				#@tamanhetkinen = ($alku,otetaanaccessnro[0],$eksponentti);
				}

			if ($numberofhits == 5){
	
#			print "$foundannotations";
			}
		   }	
		}
	    }
	}
}
}



sub IGNOROIMATON_SORTTAUS
{
my $DATE = `/bin/date`;
chomp( $DATE );

$thisisbeginning = 1;
foreach $inline (@inlines)
{
	if ($inline =~ /^\s*Query=.*$/ )
	{
		$queryname = "$&";
		$queryname =~ tr/Query=/ /;
		$queryname =~ s/UI(.*?)$//;
                @otetaanquerynamevaikeasti = split(/\|/, $queryname);
                $queryname = @otetaanquerynamevaikeasti[4];
#		$queryname =~ s/^*[w]\|/ /gi;
#		$queryname =~ s/^*(.*?)\|//gi; #just do not ask..
		$numberofhits = $hitnumber +1;
		$foundannotations = 0;
	}

	if ($numberofhits>1)
	{
	    
	    if ($inline =~ /^\s*>.*$/ ){
		$firstline = "$&";
		chomp $firstline;
		$firstline =~ s/\t*//g ;
		$indexnumber = $indexnumber = 2;
		$annotationline = $firstline;
	    }

	   elsif ($indexnumber == 2)
		{
		$lastline = $inline;
		chomp ($lastline);
		$indexnumber = 1;
		chomp ($annotationline);
;
		$annotationline = $annotationline . $lastline;
		}

	    if ($inline =~ /^\s*Score.*$/ ){
		$expect = "$&";
		$expect =~ tr/Score =/ /;
		$expect =~ tr/bits/ /;
		$expect =~ s/\n//g ;
			@ekatoka = split(/Exp/, $expect);
			$eka = pop @ekatoka;
			$toka = pop @ekatoka;

	    }

	    if ($inline =~ /^\s*Identities.*$/ ){

	if ($eka =~ /-\d*/ ){
	@eksponentti = split(/\-/, $eka);
	$eksponentti = pop @eksponentti;
	$eksponentti .= "\t";
		
	}
	else{
	$eksponentti = 05;
	}



		  if ($eksponentti=~ /\d\t/){
		
#nyt delattu			$annotationline = $firstline . $lastline;		
			$firstline =~ s/\n//g ;
			$firstline =~ s/\s+$// ;
			$lastline =~ s/\n//g ;
			chomp ($annotationline);
			$annotationline =~ tr/\t*/ / ;
			$annotationline =~ s/\t*//g ;
			$annotationline =~ s/\n//g ;
			chop ($annotationline);
			
			
#			if ($expect =~ /^\s*Exp=.*$/ ){
#			}

#			$identities = "$&\n";
#			$identities =~ s/\n//g ;
#			$identities =~ /^Identities(.+)$/;


			if ($numberofhits == $hitnumber){
			}

			$numberofhits = $numberofhits -1;

	
				$firstline =~ s/Mus musculus/Mouse/;
				$firstline =~ s/>\w\w\d{5,7}//;
				$annotationline =~ s/          //;

#VOISI OTTAA ACCESSNUMERON ERILLEEN
				$otetaanaccessnro = $annotationline;
					@otetaanaccessnro = split(/ /, $otetaanaccessnro);

#JA SITTEN SE VIELÄ POISTETAAN ANNOTATIONLINESTÄ
				$annotationline =~ s/@otetaanaccessnro[0]//;
				@otetaanaccessnro[0] =~ s/>//;
#				print (OUTFILE "aaa$annotationlineaaa\t");
#				$blah = @otetaanaccessnro[0];

					@removeLength = split(/Length =/, $annotationline);
				$alku = @removeLength[0];
				$alku =~ s/Rattus norvegicus/Rat/i;
				$alku =~ s/Mus musculus/Mouse/i;
				$alku =~ s/M.musculus/Mouse/i;
				$alku =~ s/Homo Sapiens/Human/i;

#				push (@parsed_query, $queryname);
#				push (@parsed_annotation, $annotationline);
				push (@parsed_eksponentti, $eksponentti);


$blah = @otetaanaccessnro[0];
			if ($foundannotations == 0){
				print (OUTFILE "\n$queryname\t");
			$foundannotations = $foundannotations +1;
				}
			if (length($blah) != 0){
				print (OUTFILE "$alku\t@otetaanaccessnro[0]\t-$eksponentti\t");

				#@tamanhetkinen = ($alku,otetaanaccessnro[0],$eksponentti);
				}



			if ($numberofhits == 5){
#			print "</tr>";
	
		

#			print "$foundannotations";
			}
		   }	
		
	    }
	}
}
}
}
