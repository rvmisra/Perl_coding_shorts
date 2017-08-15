#!/usr/bin/perl
# script started...needs alot more work to get it done... but the gist of the loop is done
# just fill round to get files in and search between them...
#WORK IN PROGRESS
	
use warnings;
use strict;

my $string_to_find;
my $work_file;
my @raw_data;
my $raw_data;

for(my $i=0; $i<=$#list1; $i++){
  foreach my $element (@excludes){
    if ($list1[$i] =~ m/$element/i){
      delete $links[$i];
    }
  }
}