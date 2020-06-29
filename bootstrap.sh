#!/usr/bin/bash

# We need DHCP and DNS
systemctl start dhcpcd
systemctl start systemd-resolved

# make it
pacman -Sy --needed make
make all
