#!usr/bin/perl -w
#
# FASTApar version 0.1   k.james at bangor.ac.uk
# My 2nd Perl script
#
# Parses FASTA files into tab-delimited files.
# The output file is of the format:
#   SEQNAME tab SEQDESCRIPTION tab SEQUENCE
#

( $seq_source, $seq_dest ) = @ARGV;

$usage = "perl fastapar.pl source_file destination_file";
unless ( $seq_source && $seq_dest )
{ die "\nUsage: $usage\n" };

open( SOURCE, "$seq_source" ) or die 
"Couldn't find the source file $seq_source!\n";

LINE:	while( $line = <SOURCE> ){
		chomp( $line );

SWITCH: {

if ( !$reading_seq && $line =~ /^>/ ) {
		# found the start of a sequence, so get the header
		# and shift off the > character

		$reading_seq = 1;
		@header = split /\s+/, $line;
		shift @header;
		last SWITCH;
		};

if ( $reading_seq && $line !~ /^>/ ) {
		# already reading a sequence and no new header on
		# this line, so remove whitespace and add the line
		# to the currently read sequence

		$line =~ s/\s+//g;
		push @sequence, $line;
		last SWITCH;
		};

if ( $reading_seq && $line =~ /^>/ ) {
		# already reading a sequence but there is a header
		# on this line, so stop reading, make an entry in
		# the output list, clear the sequence list and redo
		# that line

		$reading_seq = 0;
		@entry = (
				shift @header,
				( join ( " ", @header ) ),
				( join ( "", @sequence ) )
				);
		push @output, join ( "\t", @entry );
		undef @sequence;
		redo LINE;
		};
	}
}

	# add the last sequence to the output list when
	# we have run out of lines in the source file as
	# this is the only one whose end is not delimited
	# by the start of a new sequence

	@entry = (
			shift @header,
			( join ( " ", @header ) ),
			( join ( "", @sequence ) )
			);
	push @output, join ( "\t", @entry );


print ("Found " . @output . " FASTA files in $seq_source\n");

open ( DESTINATION, ">$seq_dest" ) or die
"Couldn't create the destination file $seq_dest!\n";

select ( DESTINATION );
foreach $entry ( @output ) {
	print $entry . "\n";
}

close ( DESTINATION );