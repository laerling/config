#!/bin/bash

# check .emacs.d
if [ -e ~/.emacs.d ] && [ ! -L ~/.emacs.d ]; then
	echo "$HOME/.emacs.d is not a symbolic link";
	exit;
fi


## list distros

if [ -z "$1" ]; then

	# get current distro
	if [ -L ~/.emacs.d ]; then
		curdist=$(readlink ~/.emacs.d | grep -o '.emacs.d-.\+' | cut -d'-' -f 2-);
	fi

	# list
	for f in ~/.emacs.d-*; do
		distname=$(echo "$f" | grep -o '.emacs.d-.\+' | cut -d'-' -f 2-);
		# The following check is a hack. When there is no directory matching ~/.emacs.d-* the string "~/.emacs.d-*" is taken.
		# TODO: Check if bash has a parameter to prevent this.
		if [ "$distname" != "*" ]; then
			if [ "$curdist" = "$distname" ]; then
				echo -n "* ";
			else
				echo -n "  ";
			fi;
			echo "$distname";
		fi;
	done;

	exit;
fi


## choose distro

# check distro
distro=~/.emacs.d-$1;
if [ ! -d "$distro" ]; then
	echo "No such distro: $distro"
	exit;
fi

# emacs running?
if (ps -C "emacs" &>/dev/null); then
	read -r -p "All emacs processes will be killed. Continue? [y/N] " cont
	case "$cont" in
		"y")
			# do nothing and wait for esac
			;;
		*)
			exit;
			;;
	esac
fi

# remove old
killall emacs &>/dev/null
rm ~/.emacs.d &>/dev/null

# create new
ln -s "$distro" ~/.emacs.d
