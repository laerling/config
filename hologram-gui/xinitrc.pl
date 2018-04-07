#!/usr/bin/perl
use strict;
use warnings;

while(<>){
    if($_ =~ /^twm/){
	print "#own configuration"; #keep this for other holograms!
	# Monitor config belongs in holodecks, since it's machine-dependent
	print "\n[[ -f /etc/X11/xinit/Xresources ]] && xrdb -merge /etc/X11/xinit/Xresources"; #load global Xresources provided by this hologram
	print "\nnitrogen --restore";
	print "\nexec i3";
	exit;
    }else{
	print
    }
}
