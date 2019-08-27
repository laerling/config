#!/usr/bin/perl
use strict;
use warnings;

while(<>){
	if($_ =~ /^#own configuration/){
		print;
		print "xrandr --auto --output VGA-1 --primary --above LVDS-1\n"; # external screen (e. g. a projector), if available, over regular screen
		print "externalscreen=\$(xrandr | grep 'VGA-1 connected')\n";
		print "if [ -n \"\$externalscreen\" ]; then feh --bg-fill --xinerama-index 0 /home/laerling/.wallpaper; fi\n"; # show wallpaper on external screen only
	}else{
		# print the rest
		print
	}
}
