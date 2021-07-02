#!/usr/bin/bash

# This program is part of the hologram-base-arch package

if grep '^\[multilib\]$' /etc/pacman.conf >/dev/null; then
	echo "Multilib seems to be enabled already"
	exit
fi

entry="
### hologram-base-arch ###
[multilib]
Include = /etc/pacman.d/mirrorlist
"
echo "$entry" >> /etc/pacman.conf
