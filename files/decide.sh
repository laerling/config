#!/bin/bash

# Decide whether a file belongs in one directory or another. At the time being I
# only use this script for sorting pictures and videos, that's why this script
# uses mpv for displaying the file.

script=$(basename "$0")
scriptpath=$(realpath "$script")

# check arguments
if [ $# -lt 3 ]; then
    echo "Error: Not enough arguments."
    echo "Usage: $script <first dir> <second dir> <files to decide on...>"
    exit 1
fi

# resolve and check dirs
arg1="$1"
arg2="$2"
choice1=$(realpath "$arg1")
choice2=$(realpath "$arg2")

# Complain if the choices aren't directories
if [ ! -d "$choice1" ]; then
    echo "Error: $1 is not a directory"
    exit 1
fi
if [ ! -d "$choice2" ]; then
    echo "Error: $2 is not a directory"
    exit 1
fi

# I don't know why anyone would do this, but I don't see how it's an error
if [ "$choice1" = "$choice2" ]; then
    echo "Warning: The directories are the same"
fi
shift 2

# start decision loop
for filename in "$@"; do
    file=$(realpath "$filename")

    # skip this script and the two directories
    if [ "$file" = "$scriptpath" ] || [ "$file" = "$choice1" ] || [ "$file" = "$choice2" ]; then
        continue
    fi

    # open file asynchronously, ignoring output
    (mpv --loop "$filename" &> /dev/null) & child_pid="$!"

    # decide!
    echo "(1) $arg1"
    echo "(2) $arg2"
    read -rp "Where to move $filename? " choice
    case "$choice" in
        [1]* ) mv "$filename" "$choice1/";;
        [2]* ) mv "$filename" "$choice2/";;
        * ) echo "Skipping $filename";;
    esac

    # close file
    kill "$child_pid"
done
