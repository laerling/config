#!/bin/bash

dev="$1"
mountpoint="$2"
if [ -z "$dev" ]; then
	echo "No device name given" >/dev/stderr
	exit 1
fi

if ! [ -e /dev/"$dev" ]; then
	echo "/dev/$dev does not exist" >/dev/stderr
	exit 1
fi

if ! [ -d "$mountpoint" ]; then
	echo "Mount point does not exist or is not a directory: $mountpoint" >/dev/stderr
	exit 1
fi

sudo cryptsetup open /dev/"$dev" "$dev"
sudo mount /dev/mapper/"$dev" "$mountpoint"
