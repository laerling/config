#!/usr/bin/perl
use strict;
use warnings;

# print contents of already existing file
print while(<>);

# append
print "

##gopath
export GOPATH=~/go
export PATH=\"\$GOPATH/bin:\$PATH\";
"
