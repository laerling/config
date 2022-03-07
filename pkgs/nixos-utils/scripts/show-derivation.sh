#!/usr/bin/env bash

function usage {
    echo "Usage:"
    echo "$0 <pattern>"
    echo "PATTERN can be anything from a hash to a whole path."
    echo "PATTERN can be both, a derivation or its out path."
}

# find matches
pattern="$1"
result=$(find /nix/store/ -mindepth 1 -maxdepth 1 -path "*${pattern}*")

# check if we have one or several
if [ $(wc -l <<< $result) -gt 1 ]; then
    echo "More than one match found. Choose one of:"
    echo "$result"
    exit 0
fi

# if result does not end in .drv, search for the derivation that produced it
if ! (grep -q '\.drv$' <<< $result); then
    echo "$result is not a derivation."
    echo "Searching for derivation that produced it."
    # TODO Is there any good argument to just grep by hash instead of
    # the whole outPath?
    outpath=$result
    result=$(grep -Fl $outpath /nix/store/*.drv)
    if [ $(wc -l <<< $result) -gt 1 ]; then
	echo "More than one derivations match the outPath $outpath"
	echo "Choose one of:"
	echo "$result"
	exit 0
    fi
fi

# now we have a derivation file for sure.
# Use -S on less because lines might be very long, especially for
# in-line builder scripts etc.
nix show-derivation $result | jq -C | less -SR
