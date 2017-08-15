#!/usr/bin/perl

# a program to parse blast output and generate oligos based on uniqueness, secondary structure, sequence complexity, Tm, and distance from 3' end of transcript

# for more information about the input and output please refer to the accompanying readme file

# define parameters

# blast bit score threshold

    $threshold = 50;

# number of oligos to initially select for each transcript

    $number = 6;

# total number of oligos to select

    $t_number = 1;

# length of oligo

    $length = 70;

# minimum length of oligo - oligos are progressively shortened if none are found in the specified Tm range on first pass through the transcript

    $molength = 60;

# maximum distance from 3' end

    $distance_m = 1000;

# define distance to move after an oligo has been selected before examining a new potential oligo

    $jump = 40;

# tm range 

    $h_tm = 83.5;
    $l_tm = 72.5;

# max lzw score for sequence complexity

    $mlz = .50;

# max secondary structure score

    $mrna = 20;

# calculate lzw parameters for the system
# the two system calls compute the offset (in characters) for compressing a space using gzip (which operates using lz77 compression). This is stored in the $diff variable

    system("echo  | wc -c > wcout");
    system("echo  | gzip | wc -c >> wcout");
    open(WC, "wcout");
    $_ = <WC>;
    chomp $_;
    $wcs = $_;
    $_ = <WC>;
    chomp $_;
    $gzs = $_;
    $diff = $gzs - $wcs;
    close(WC);

# also calculate the lz score for a string of n A's, n = {molength, molength + 1, .. length} This gives the maximum score for a sequence of length n. Store the scores in array @lz_length
 
   @lz_length = ();
   for $i ($molength .. $length){
       $seq = "";
       for $j(1..$i){
	   $seq = $seq."A";
       }
       $lz_length[$i]=lzw($seq);
    }

# begin

# file input. <> is a tab delimited file list of concatenated sequence files, extracted blast files, and file labels of the form 
#            concatenated sequence file\textracted blast file\tlabel for base of output files

# the extracted blast files should be in the format given by the program extract.pl which accompanies this script

# make an array of the file list, @flist

while(<>){
    
    chomp $_;
    @cnc_xtr = split/\t/,$_;
    push @flist, [@cnc_xtr]

}

# now operate on each of the files in @flist

foreach $file (@flist){
    @best = ();
    @oligo = ();
    @regions = ();
# the first step is to extract all non-self alignments of each query sequence in $file->[1] (the extracted blast file) that are over the blast threshold set above. The current code is written for dealing with alignments against a blast database of unigene transcripts. Here, a crucial step is storing the cluster to which each query belongs. There are a few assumptions in the current code. First, the transcriptome is assumed to be complete. In this case, the first blast alignment listed will be the alignment of the query with itself. Thus information from this first alignment is used to parse out any further self alignments (for instance with its reverse complement.) The way that this works is by extracting the unigene cluster of the first subject and excluding all alignments of the query with any sequence in this cluster. If, the transcriptome consists only of individual transcripts with no degeneracy - then the gi or gb number for the first subject can be used in place of the cluster. It is assumed that the transcriptome is complete.

    open(XTR, $file->[1]);

# the whole extracted blast file is read into the array @xtr. Thus @xtr must be sufficiently small to be read into the memory of the system. If memory is an issue, lines can be read in one at a time using a while(<XTR>){} loop.

    @xtr = <XTR>;
    @bracket = ();

# $print_flag keeps track of whether or not anything has been printed for this particular query id.

    $print_flag = 0;
    chomp $xtr[0];
    @line = split/\t/, $xtr[0];

# the subroutines parse_cluster, parse_qid and parse_sid are written for unigene identifiers in which the gi, gb and unigene clusters are in the fasta descriptor line. If the fasta deflines are in a more traditional genbank format these subroutines can be altered to gather the desired information. Really only one identifier is necessary to keep track of the query ids - but this version keeps track of gi, gb and unigene cluster indentifiers.

# the initialization for $xtr[0] sets the array @old_qid which is then compared with the subsequent ids in @xtr to determine when a new id is found and thus when the self alignment cluster should be updated and when to check if anything has been printed for the old_qid.

    $cluster = parse_cluster($line[2]);
    @old_qid = parse_qid($line[0]);
    $q_length = $line[1];
    @sid = parse_sid($line[2]);
    
# we'll print the condensed alignments out to a file label.cnd

    $cnd = "$file->[2]".".cnd";
    open(CND, ">$cnd");

# now that we have initialized @old_qid we can begin a for loop.

    for $i(1..$#xtr){
	
	chomp $xtr[$i];
	@line = split/\t/,$xtr[$i];
	@qid = parse_qid($line[0]);
	@sid = parse_sid($line[2]);
	
 # check whether @qid is a new id. If it is condense and print out the information from the @old_qid
 
	if($qid[0] eq "$old_qid[0]"){
	}
	else{
	    
	    if($print_flag == 0){
		
		@condensed = ("1","$q_length"); # if $print_flag == 0, there were no alignments over the threshold with transcripts outside of the query's cluster. Therefore the region available for choosing oligos is the entire transcript. 
		
		foreach $term (@condensed){
		
		    print CND "$term\t"; # print the alignent information to the file label.cnd
		
		}
		
		print CND "\n";
		@choose = ([@old_qid], $q_length, [@condensed]); # @choose contains the query id, @old_qid, its length, and the regions available to choose oligos from 
		push @regions, [@choose]; # make the array @choose part of an element of the array @regions which contains an @choose array for each query

	    }
	    else{
		
		@condensed = condense(@bracket); # the subroutine condense checks all alignments in the array @bracket to see if they overlap and constructs a non-overlapping set of alignments which is place in @condensed

		foreach $term (@condensed){
		    print CND "$term\t"; # again print out the elements of @condensed to the file label.cnd
		}
		print CND "\n";
		unshift @condensed, 1; # to change @condensed from an array of aligned regions of the form (start1, stop1, start2, stop2) to and array non-aligned regions of the form (non-aligned start1, non-aligned stop1, non-aligned start2 .....) add a 1 to the begnning of the array @condensed and the final position in the query to the end of @condensed
		push @condensed, $q_length;
		@choose = ([@old_qid], $q_length, [@condensed]); # make an array
		push @regions, [@choose];
			
	    }
	    # since we have printed out the information about the last query update the cluster and length information, and reset @bracket and $print_flag 
	    $cluster = parse_cluster($line[2]);
	    $q_length = $line[1];
	    @bracket = ();
	    $print_flag = 0;
	}
	
# examine the alignments

	if(!($cluster eq "$sid[2]")){ # if the subject and query come from different clusters
 
	    if($line[4]>$threshold){ # and if the blast bit score is above $threshold
		
		@align = ($line[9], $line[10]); # put the alignment information into the array @align
		push @bracket, [@align]; # add this alignment to the array @bracket
		$print_flag = 1; # since this alignment was with a subject from a different cluster than the query and the score was above $threshold make $print_flag = 1
	    }
	}
	
    @old_qid = @qid; # before going to the top of the for loop and reading in the next alignment make @old_qid = @qid so that we can compare the next @qid with the current one
	
    }
    # repeat the examination of $print_flag, construction of @condense and @choose for the last query (for which the test $old_qid[0] ne $qid[0] will never be true
    
    if($print_flag == 0){
		
	@condensed = ("1","$q_length"); 
		
	foreach $term (@condensed){
		    
	    print CND "$term\t"; 
		    
	}
		
	print CND "\n";
	@choose = ([@old_qid], $q_length, [@condensed]); 
	push @regions, [@choose];
    }
    else{

	@condensed = condense(@bracket);
	foreach $term (@condensed){
	    
	    print CND "$term\t";
    
	}
	
	print CND "\n";
	push @condensed, $q_length;
	unshift @condensed, 1;
    
	@choose = ([@old_qid], $q_length, [@condensed]);
	push @regions, [@choose];
    }
    
    close(XTR);
    @xtr =  ();    
    close(CND);
    
    
# print out the information from @regions to the file label.rgn

    $rgn = "$file->[2]".".rgn";
    open(RGN,">$rgn");
    for $j (0..$#regions){
    
	print RGN "$regions[$j]->[0]->[0]|$regions[$j]->[0]->[1]|$regions[$j]->[0]->[2]\t";
	$k=0;
	while(!($regions[$j]->[2]->[$k] eq "")){
	    
	    print RGN "$regions[$j]->[2]->[$k]\t";
	    $k++;
	    
	}
	
	print RGN "\n";
	
    }

    close(RGN);

# now read in the sequences and make a hash of ids and sequences

    open(CNC, "$file->[0]");
    %seq = ();
    @cnc = <CNC>;
	
    foreach $fsa (@cnc){
	
	chomp $fsa;
	@line = split/\t/,$fsa;
	$cncid = parse_cncid($line[0]); # this subroutine will parse the ids from the concatenated sequence files. $cncid will be compared with one of the ids that was placed in @choose[0]

	$seq{$cncid}=$line[1]; # we make a hash that relates the id and its sequence
	
    }
    
    close(CNC);
    @cnc = ();

    
# now choose oligos
  


  TRANSCRIPT: for $j (0..$#regions){ # the outer loop moves through the elements of @regions each of which has the alignment information for a particular transcript
      

      @positions = (); # keeps track of the positions of the oligos for this transcript;
      $olength = $length; # $olength will control the length of the oligos. it is initialized at $length and progressively decreased until $number oligos have been selected or $olength < $molength.
      
      if(exists $seq{$regions[$j]->[0]->[0]}){ # check to see if the sequence for the current id exists in the hash %seq
	
	  $transcript = $seq{$regions[$j]->[0]->[0]}; # get the transcript
	  $number_flag=0; # $number_flag keeps track of the number of oligos selected. initialize it to zero
	 

	  
	LENGTH: while($olength > $molength){ # the loop that controls the length of the oligos
	    

	    $k=-2; # we begin looking at regions started at the second element from the end of the alignment array
	    
	    while(!($regions[$j]->[2]->[$k] eq "")){ 
		
		$start_r = $regions[$j]->[2]->[$k]; # get the start and end of the region and compute its length
		$end_r = $regions[$j]->[2]->[$k+1];
		$length_r = $end_r - $start_r + 1;
		
		
		if($length_r > $olength){ # check to see if the region is long enough to choose any oligos from
		    
		    $sub_seq = substr($transcript,($start_r-1),$length_r); # $sub_seq is the sequence information from the current region

		    
		  OLIGO: for ($m=0;$m<($length_r - $olength);$m++){ # this loop moves through the current region and examines potential oligos beginning at the 3' most end of the region
		      
		      if(($regions[$j]->[1]-$end_r-$m+1)>$distance_m){ # if the end of the region is farther than $distance_m from the 3' end of the transcript decrease $olength and go back to the LENGTH loop
		    
			  $olength--;
			  next LENGTH;
		    
		      }
		

		      $oligo = substr($sub_seq,-($m+$olength),$olength); # get the current oligo
		      $tm = tm($oligo); # calculate its tm
		      
			if($oligo=~/[atcgN]/){ # if any of the sequence is uncertain or has been masked move on to the next potential oligo
			 
			    next OLIGO;

			}
			
			if(($l_tm<$tm) && ($h_tm>$tm)){ # check to see if the oligo lies in the proper tm range
			    $c_flag = 0;
			    for $c (0..$#positions){
				if((-$jump<(($end_r-$m)-$positions[$c]))&((($end_r-$m)-$positions[$c])<$jump)){ 

				    $c_flag = 1; # this step checks the position of this oligo against the positions of the other oligos selected to make sure that they are far enough apart
				}
			    }
			    if($c_flag==0){
				@info = ($regions[$j]->[0], $olength, $regions[$j]->[1], ($end_r-$m), ($regions[$j]->[1]-$end_r+$m+1), $tm, $oligo); # make an array @info of the form (@id, oligo length, transcript length, 5' position, 3' position, tm, sequence) 			    @info = ($regions[$j]->[0], $olength, $regions[$j]->[1], ($end_r-$m), ($regions[$j]->[1]-$end_r+$m+1), $tm, $oligo); # make an array @info of the form (@id, oligo length, transcript length, 5' position, 3' position, tm, sequence) 
				push @oligo, [@info]; # add this oligo to the array @oligo
				push @positions, ($end_r-$m); # add this posito\ion to the position list
				$number_flag++; # record that another oligo has been selected. 
				$m = $m + $jump; # increase m by jump

				if($number_flag>=$number){ 
				
				    next TRANSCRIPT;
				}
			    }
			    next OLIGO;
			}
		    
		    }
		}
		
		$k = $k-2;
	
	    }
	
	    $olength--;
	}
      }
  }

    %seq = ();

# print out the initial oligo information to the file label.oligo

    $oligof = "$file->[2]".".oligo";
    open(OLIGOF, ">$oligof");
    for $j(o..$#oligo){

	print OLIGOF "$oligo[$j]->[0]->[0]|$oligo[$j]->[0]->[1]|$oligo[$j]->[0]->[2]\t$oligo[$j]->[1]\t$oligo[$j]->[2]\t$oligo[$j]->[3]\t$oligo[$j]->[4]\t";
	printf OLIGOF "%1.2f\t",$oligo[$j]->[5];
	print OLIGOF "$oligo[$j]->[6]\n";

    }
    close(OLIGOF);

   
# compute secondary structure and lz compression scores for the oligos and choose the best $t_number of them. output each oligo sequence to the file oligo_seq and then compute the secondary structure of all of the oligos in this file simultaneously

    open(OUT, ">oligo_seq");
    for $i (1..$#oligo){
	
	print OUT "$oligo[$i]->[6]\n";
	
    }
    close(OUT);

    system("perl /home/mwright/rnafold/Perl/RNAfold.pl oligo_seq > oligo_seq.rnafold"); # compute the secondary structures using the perl script supplied with the Vienna group RNAfold program (see README) - the argument to perl in quotes must point to the proper location of RNAfold.pl on the system!!! 

# now read through the secondary structure file, get the delta G scores, compute lz compression scores put these in a hash associated with the id and sequence position of the oligo and update the oligo array

    
    open(IN, "oligo_seq.rnafold");
    
    %seq_rf = ();
    while(<IN>){
	
	chomp $_;
	$rna_seq = $_; # get the sequence from the rnafold output file
	$_ = <IN>;
	$_ =~ /-(\d+\.\d+)\)/; # get the score from the rnafold output file
	$score = $1;
	$lzlen = length($rna_seq); # we must pass the length of the oligo to the lzw subroutine 
	$lzw = lzw($rna_seq,$lzlen); # compute the lz compression score 
	push @{$seq_rf{$rna_seq}},$score, $lzw; # put this information in a hash that associates sequences with their scores

    }

    close(IN);

# finally we go through the array @oligo and choose the best $t_number for eachquery 

    $bestf = "$file->[2]".".list"; 
    open(BESTF, ">$bestf"); # we'll print the output to the file label.list
    @best = ();
    $old_qid = $oligo[0]->[0]->[0]; # initialize the old query id $old_qid
    
    for $j (1..$#oligo){
	
	@temp = ($oligo[$j]->[0],$oligo[$j]->[1],$oligo[$j]->[2],$oligo[$j]->[3],$oligo[$j]->[4],$oligo[$j]->[5],$seq_rf{$oligo[$j]->[6]}[0],$seq_rf{$oligo[$j]->[6]}[1],$oligo[$j]->[6]); # temp includes all of the information in @oligo as well as the associated rnafold and lz score information

	if($temp[0]->[0] eq "$old_qid"){ # still the same query, continue to update the array @best
	    
	    if(($temp[6]<$mrna) && ($temp[7]<$mlz)){ # check to make sure that the rnafold and lz scores are below the the proper thresholds

		if($#best<($t_number-1)){ # add @temp to @best until there are $t_number total elements
		
		    push @best, [@temp];
		    @nbest = sort by_score @best; # after each new @temp is added sort the array by rnafold score
		    @best = @nbest;

		}
		elsif($temp[6]<$best[$#best]->[6]){ # if @best is full ($t_number total elements) then check to see if the rnafold score of @temp is better than the worst score in @best
		    
		    $best[$#best] = [@temp]; # replace the last element of @best with @temp
		    @nbest = sort by_score @best; # sort again
		    @best = @nbest;
		}
	    }
	}
	else{ # new query
	    for $j(0..$#best){ # we now have a new query so print out the information for the last query
		
	    	print BESTF "$best[$j]->[0]->[0]|$best[$j]->[0]->[1]|$best[$j]->[0]->[2]\t$best[$j]->[1]\t$best[$j]->[2]\t$best[$j]->[3]\t$best[$j]->[4]\t";
		printf BESTF "%1.2f\t", $best[$j]->[5];
printf BESTF "%1.2f\t", $best[$j]->[6];
		print BESTF "$best[$j]->[7]\t$best[$j]->[8]\n";

	    }
	    @best = (); # reinitialize best for the new query
	    
	    if(($temp[6]<$mrna) && ($temp[7]<$mlz)){ # check to see if the first @temp of the new query passes lz and rnafold thresholds
		
		push @best, [@temp]; # if so add it to @best
	    
	    }
	}

	$old_qid = $temp[0]->[0]; # update old qid before going back to the head of the for loop

    }
    
}

sub parse_cluster{

# extracts the cluster from a unigene identifier
    
    my($psid,@psid,@sid,$sgi,$sgb,$sugc); 
    $psid = $_[0];
    $psid =~/(ug)(=)(.*?)\s+/;
    $sugc = $3;
    return $sugc;

}
   
sub parse_qid{

# gets the gi, gb and ug cluster identifiers from a unigene identifier
    
    my($psid,@psid,@sid,$sgi,$sgb,$sugc); 
    $psid = $_[0];
    $psid =~/gb=(.*?)\s+/;
    $sgb = $1;
    $psid =~/(gi)=(.*?)\s+/;
    $sgi = $2;
    $psid =~/(ug)(=)(.*?)\s+/;
    $sugc = $3;
    @sid = ("$sgi","$sgb","$sugc");
    return @sid;
    
    
}

sub parse_sid{

# gets the gi, gb and ug cluster identifiers from a unigene identifier

    my($psid,@psid,@sid,$sgi,$sgb,$sugc); 
    $psid = $_[0];
    $psid =~/gb=(.*?)\s+/;
    $sgb = $1;
    $psid =~/(gi)=(.*?)\s+/;
    $sgi = $2;
    $psid =~/(ug)(=)(.*?)\s+/;
    $sugc = $3;
    @sid = ("$sgi","$sgb","$sugc");
    return @sid;
    
}

sub parse_cncid{

# returns the gi number obtained from a unigene identifier

    my($psid,@psid,@sid,$sgi,$sgb,$sugc); 
    $psid = $_[0];
    $psid =~/gb=(.*?)\s+/;
    $sgb = $1;
    $psid =~/(gi)=(.*?)\s+/;
    $sgi = $2;
    $psid =~/(ug)(=)(.*?)\s+/;
    $sugc = $3;
    @sid = ("$sgi","$sgb","$sugc");
    return $sid[0];
   
} 
sub condense{

# condenses overlapping alignments

    my(@condensed,@sorted,@align,$elem,$item,$current,@bracket);
    @bracket = @_; # we passed @bracket to the subroutine
    @sorted = sort by_start @bracket; # sort @bracket first by starting position, then by ending position. Note that each element of @bracket has references elemnt->[0] = start, element->[1] = end

    $current = $sorted[0]; # we are going to compare each alignment in the sorted list with the next alignment
    
    for $i(1..$#sorted){
	
	$item = $sorted[$i];
	
	if($item->[0]>$current->[1]){ # if they don't overlap add $current to @condensed
	
	    push @condensed, $current->[0], $current->[1];
	    $current = $item;
	}
	
	if($item->[1]>$current->[1]){ # they overlap, change the stop position of @current to that of @item
	
	    $current->[1] = $item->[1];
	
	}

    }
    
    push @condensed, $current->[0], $current->[1];
    return(@condensed);

}

sub tm{

#computes tm

    my($oligo,$l,$count,$tm);
    $oligo = $_[0];
    $count = 0;
    chomp $oligo;
    $l = length($oligo);
    if ($l == 0){
	return;
    }
    $_ = $oligo;  
    $count = s/G/G/g;
    $count += s/C/C/gi;
    $tm = 64.9 + $count/($l)*41 - 500/($l); 
    return($tm);
}

sub lzw{

# computes lz score. see README for more information

    my($seq, $wco, $gzo, $lz, $length);
    $seq = $_[0];
    $length = $_[1];
    if($length eq ""||$length == 0){return}
    system("echo $seq| wc -c > wcout");
    system("echo $seq| gzip | wc -c >> wcout");
    open(WC, "wcout");
    $_ = <WC>;
    chomp $_;
    $wco = $_;
    $_ = <WC>;
    chomp $_;
    $gzo = $_;
    $lz = $wco + $diff - $gzo;
    $lz = $lz/$length;
    close(WC);
    return($lz);

}

sub by_start{

    ($a->[0] <=> $b->[0] || $a->[1] <=> $b->[1])

    }

sub by_score{

    ($a->[6] <=> $b->[6])

    }


















































