#!/usr/bin/perl

use strict;
use warnings;

# constants
my $HASH_BIN = "xxhsum";

# initialize
my $loc = shift || "."; # location to traverse
my $rename = shift || ""; # make hash value the new name of the file
my $keepExt = shift || ""; # whether to keep file extension when renaming

# check location
die "Error: $loc is not a directory" unless -d $loc;

# check safety
if($rename) {
    print "WARNING: Renaming files in '$loc'. Continue? (y/N) ";
    my $ok = <>; # ask for user input
    if($ok ne "y\n"){
        print "Exiting.\n";
        exit;
    }
}

# start traversing
hashes($loc, $rename, $keepExt);

# recursively hash files inside a directory
sub hashes {

    # initialize
    my $loc = shift || "."; # location to traverse
    my $rename = shift || ""; # make hash value the new name of the file
    my $keepExt = shift || ""; # whether to keep file extension when renaming

    # read dir
    opendir(my $dir, $loc);
    while(my $item = readdir $dir){

        # exclude ., .., and .git
        next if $item =~ /^(\.|\.\.)$|\.git/;

        # canonize $loc and build path
        $loc = $loc . "/" unless substr($loc, -1) eq '/';
        my $itempath = "$loc$item";

        # traverse or hash
        if(-d $itempath){

            # traverse directory
            hashes($itempath, $rename, $keepExt);
        } else {

            # make sanitized itempath
            my $itempathSan = $itempath;
            $itempathSan =~ s/"/\\"/;

            # calculate hash
            `$HASH_BIN "$itempathSan"` =~ /(^[\S]+)/;
            die "$HASH_BIN output could not be parsed for '$itempath'" if not defined $1;
            my $hash = $1;

            # print hash
            print "$hash '$itempath'\n";

            # maybe rename file
            if($rename){

                # maybe keep extension
                my $ext = "";
                if($keepExt){
                    if($itempath =~ /\.([^.\/]+)$/){
                        $ext = "." . $1
                    }
                }

                # rename
		if("$itempath" ne "$loc$hash$ext"){
		    die if system("mv", "-f", "$itempath", "$loc$hash$ext");
		}
            }
        }
    }
}
