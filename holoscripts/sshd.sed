#!/usr/bin/sed -f

/^#\?Port /s/^.\+$/Port 69/
/^#\?PermitRootLogin/s/^.\+$/PermitRootLogin no/
/^#\?PasswordAuthentication/s/^.\+$/PasswordAuthentication no/
