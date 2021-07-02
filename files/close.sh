#!/bin/bash

map="$1"
if [ -z "$map" ]; then
	echo "No mapping name given" >/dev/stderr
	exit 1
fi

if ! [ -e /dev/mapper/"$map" ]; then
	echo "/dev/mapper/$map does not exist" >/dev/stderr
	exit 1
fi

sudo cryptsetup close "$map"
