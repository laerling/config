#!/usr/bin/perl

use strict;
use warnings;

# initialize variables
my $loc = shift || "."; # location to traverse

# check location
die "Error: $loc is not a directory" unless -d $loc;

# check user sanity
print "WARNING: Flattening directory '$loc'.\n";
print "This will delete ALL .git directories in the tree!\n";
print "This operation cannot be undone. Continue? (y/N) ";
my $ok = <>; # ask for user input
if($ok ne "y\n"){
    print "Exiting.\n";
    exit;
}

# start traversing recursively. Don't call flatten with a second argument, else
# all files will be moved into the parent directory of $loc.
flatten($loc);

# recurses depth-first into the given directory and moves every file one
# directory up until all files are at the upmost directory. Directories whose
# contents must not be moved upwards (e. g. .git) are removed entirely.
sub flatten {

    # initialize
    my $loc = shift || ".";
    my $migrate = shift || "";

    # Recurse into directories
    opendir(my $dir, $loc);
    while(my $item = readdir $dir){

        # canonize $loc and build path
        $loc .= "/" unless substr($loc, -1) eq '/';
        my $itempath = "$loc$item";

        # skip non-directories
        next unless(-d $itempath);

        # skip . and ..
        next if $item =~ /^(\.|\.\.)$/;

        # remove .git recursively
        if($item eq ".git") {
            print("rm -rf '$itempath'\n");
            die if system("rm", "-rf", $itempath);
            next;
        }

        # recurse into directory. The second argument says to move files upwards
        flatten($itempath, 1);

        # remove now empty directory
        die if system("rmdir", "$itempath");
    }
    closedir($dir);

    # Move files upwards
    if($migrate) {
        opendir($dir, $loc);
        while(my $item = readdir $dir){

            # canonize $loc and build path
            $loc = $loc . "/" unless substr($loc, -1) eq '/';
            my $itempath = "$loc$item";

            # skip . and ..
            next if $item =~ /^(\.|\.\.)$/;

            # rename if an already existing file would be overwritten
            while(-e "$loc../$item"){
                $item .= "_";
            }

            # migrate files up
            print("mv '$itempath' '$loc../$item'\n");
            die if system("mv", "$itempath", "$loc../$item")
        }
    }
}
