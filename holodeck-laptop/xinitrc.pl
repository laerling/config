#!/usr/bin/perl
use strict;
use warnings;

while(<>){
	if($_ =~ /^#own configuration/){
		print;
		print "xrandr --auto --output LVDS-1 --below VGA-1\n"; #external screen (e. g. a projector), if available, over regular screen
	}else{
		# print the rest
		print
	}
}
