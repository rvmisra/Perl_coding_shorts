#!/usr/bin/perl -w

# Script for combining descriptions in a tab delimited file
#	with fasta files
#
# Also extracts descriptions in fasta files to tab delimited
#	files.
#
# Martin VanWinkle marty@arl.arizona.edu
# Needs perl.

use strict;
use Bio::SeqIO;
use Bio::Seq;
use Bio::PrimarySeq;
use Getopt::Long;


my ($old_fasta_file_name, $new_fasta_file_name, $descriptions_file_name, $merge, $tag);
my ($replace,$append, $strip);
my ($extract_descriptions, $descriptions_output_file_name);
my $help;
my %descriptions;
my $ok = GetOptions(
			'strip' => \$strip,
			'replace' => \$replace,
			'append' => \$append,
			'e' => \$extract_descriptions,
			'm' => \$merge,
			'oldfasta=s' => \$old_fasta_file_name,
			'newfasta=s' => \$new_fasta_file_name,
			'tag=s'=>\$tag,
			'd=s' => \$descriptions_file_name,
			'do=s' => \$descriptions_output_file_name,
			'help' => \$help
			);

if ($help)
{
	display_usage();
	exit;
}

# print "Fasta file name: $fasta_file_name\n" if defined $fasta_file_name;
# print "Description file name: $descriptions_file_name\n" if defined $descriptions_file_name;
# print "Extract Descriptions: $extract_descriptions\n" if defined $extract_descriptions;
# print "Descriptions output file name: $descriptions_output_file_name\n" if defined $descriptions_output_file_name;

if (!defined($tag))
{
	$tag="UA";
}

if (!$old_fasta_file_name)
{
	print "\nERROR:  Old fasta file was not provided.\n";
	display_usage();
	exit;
}

if (! (-e $old_fasta_file_name) )
{
	print "\nERROR:  Old fasta file does not exist.\n\n";
	exit;
}

if ($merge || $strip)
{
	if ( ! ($replace xor $append xor $strip) )
	{
		printf "\nERROR:  You must either replace, append or strip.\n";
		exit;
	}
	
	if (defined $descriptions_file_name && !$strip)
	{
		if (!-e $descriptions_file_name)
		{
			printf "\nERROR:  Description file does not exist.\n";
			exit;
		}
	}
	
	if (!$new_fasta_file_name)
	{
		printf "\nERROR:  New fasta file name was not privided.\n";
		exit;
	}
	merge_descriptions();
}

if ($extract_descriptions)
{
	extract_descriptions();
}

exit;
sub display_usage
{
print <<HERE

Usage:\n$0 -oldfasta <original fasta file name>
	[ -m 
		-newfasta <new fasta file name>
		-d <description file name>
		-r[eplace]
		-a[ppend]
		[-tag <tag>]
	]
	[-s[trip]]
	[ -e [ -do <descriptions output file name> ] ]
	-h[elp]
  -m  Merge description file into fasta file
	-d	Description file to merge into new fasta file
	-r	Replace the descriptions
	-a	Append the descriptions
	-tag	The tag that will surround the newly merged comments
  -s  Strips the descriptions from the sequences
  -e  Extracts descriptions in tab delimited format
  -do File to output extracted descriptions to; defaults to stdout
  -h[elp] Display this message

The old fasta file is mandatory.

HERE
}

sub extract_descriptions
{
	my $where=0;
	if ($descriptions_output_file_name)
	{
		open OUT_FILE, ">$descriptions_output_file_name" or die("Can't open description output file\n");
		$where=1;
	}
	
	my $extract_fasta;
	if (-e $new_fasta_file_name)
	{
		$extract_fasta=$new_fasta_file_name;
	}
	else
	{
		$extract_fasta=$old_fasta_file_name;
	}
	my $fasta_file = Bio::SeqIO->new(
		-file => $extract_fasta,
		'-format' => 'Fasta'
		);

	while ( my $seq = $fasta_file->next_seq())
	{
		print $seq->id,"\t", $seq->desc(), "\n" if (!$where);
		if ($descriptions_output_file_name)
		{
			print OUT_FILE $seq->id,"\t", $seq->desc(), "\n";
		}
		
	}

	$fasta_file->close();
}

sub load_descriptions
{
	print "Loading descriptions... ";
	my $line;
	my @parts;
	open DESCRIPTION_FILE, "<$descriptions_file_name" ||
		die("\nERROR: Can't open description file: $!\n");

	my $count=0;
	while (<DESCRIPTION_FILE>)
	{
		$line = $_;
		chomp($line);
		# print $line,"\n";
		@parts=split(/\t/,$line);
		$count++ if ($parts[1]);
		$descriptions{ucase($parts[0])}=$parts[1];
	}
	close DESCRIPTION_FILE;
	print "Done.\n";
	
	if ($count==0)
	{
		print "\nERROR: No descriptions found in description file.\n";
		exit;
	}
	
	print "Number of descriptions read: $count\n";
	
	#foreach my $key (keys %descriptions)
	#{
	#	print "Sequence: ", $key, " Description: ", $descriptions{$key}, "\n";
	#}
}

sub merge_descriptions
{
	load_descriptions() if (defined $descriptions_file_name);

	print "\nMerging descriptions: \n";
	open NEW_FASTA, ">$new_fasta_file_name" ||
		die (print "\nERROR: Can't create new fasta file: $!\n");

	close(NEW_FASTA);
	
	print "\tOpening old fasta file... ";
	my $fasta_file = Bio::SeqIO->new(
		-file => $old_fasta_file_name,
		'-format' => 'Fasta'
		);
	print "Done.\n";
	
	my $out_fasta_file = Bio::SeqIO->new(
		-file => ">$new_fasta_file_name",
		'-format' => 'Fasta'
		);

	print "\tMerge loop...\n";	
	my ($seq, $modified);
	$modified=0;
	while ($seq = $fasta_file->next_seq())
	{
		if (defined $descriptions{ucase($seq->id)} && !$strip)
		{
			$modified++;
			if ($append)
			{
				$seq->desc($seq->desc() . " $tag:".$descriptions{$seq->id}.":$tag ");
			}
			else
			{
				$seq->desc(" UA:".$descriptions{$seq->id}.":UA ");
			}
			# print $seq->id,"\t", $seq->desc(), "\n";
		}
		else
		{
			$seq->desc("");
			$modified++;
		}
		$out_fasta_file->write_seq($seq);
	}
	$fasta_file->close();
	$out_fasta_file->close();
	print "Done.\n";
	print $modified, " entr",($modified==1?"y":"ies"),
		($strip?" stripped":" changed"),".\n";
}

sub ucase
{
	my $ch=$_[0];
	
	$ch=~tr/[az]/[AZ]/;
	return $ch;
}
