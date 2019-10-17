#!/usr/bin/bash

# We need DHCP and DNS
systemctl start dhcpcd
systemctl start systemd-resolved

# Even if make is already installed we want to make sure it is declared as a dependency
# because it will be included in a hologram
yes | pacman -Sy --asdeps make
make all
