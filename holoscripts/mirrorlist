#!/usr/bin/bash

url='https://archlinux.org/mirrorlist/?country=DE&protocol=https&ip_version=4&use_mirror_status=on'

echo "# Mirrorlist for Germany downloaded from:"
echo "# $url"
echo

curl "$url" | sed 's/^#Server/Server/'
