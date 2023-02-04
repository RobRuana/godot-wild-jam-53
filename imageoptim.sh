#!/usr/bin/env bash

imageoptim=/Applications/ImageOptim.app/Contents/MacOS/ImageOptim

if [[ $# -ge 1 ]]; then
    FILES=("$@")
else
    # All *.png files
    # FILES=`find . -type f -name "*.png"`

    # Only changed *.png files
    FILES=(`git status --porcelain --untracked-files=all --no-renames | grep --invert-match '^\s\?D' | awk '{ print $2 }' | grep '\.png$'`)
fi

# Print image files
printf '%s\n' "${FILES[@]}"

# Asynchronous with UI
printf '%s\0' "${FILES[@]}" | xargs -0 open -a ImageOptim

# Synchronous (blocking) from command line
# printf '%s\0' "${FILES[@]}" | xargs -0 $imageoptim
