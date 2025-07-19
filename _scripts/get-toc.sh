#!/bin/bash

# This is a simple script to output the table of contents from a course's constituent
# .md markdown notes files. By default, the script will parse the current working
# directory inside of which it is located and output file toc.txt. Otherwise, specify
# the path to the course subfolder as the first command line argument (e.g., ../cs-6200)
# and the target output file as the second command line argument (e.g., gios-toc),
# for example:
# $ ./get-toc ../cs-6200 gios-toc

# Get the path from the first command line argument, or use the current directory if no argument is provided
path=${1:-.}

# Get the output filename from the second command line argument, or use toc if no argument is provided
output=${2:-toc}

# Add .txt suffix to the output filename
output+=".txt"

# Initialize the output file
: > "$output"

# Iterate over each markdown file in the specified path
for file in "$path"/*.md
do
    # Skip README.md
    if [[ "$file" == */README.md ]]; then
        continue
    fi

    # Get the prefix of the .md file
    filename=$(basename "$file" .md)
    prefix=${filename%%-*}

    # Include the hyphen in the prefix
    prefix+="-"

    # Use awk to find lines starting with any number of #
    # (ignore anomalous tokens `# ?`, `#include`, `#define`)
    grep -v -e '# ?' -e '#include' -e '#define' "$file" | awk -v prefix="$prefix" '{
        match($0, /^#+/)
        hashes = substr($0, RSTART, RLENGTH)
        if (length(hashes) == 1) {
            print hashes " " prefix substr($0, RSTART + RLENGTH + 1)
        } else {
            print substr($0, RSTART)
        }
    }' | grep -E '^#+' >> "$output"

    # Insert a newline after processing each file
    echo -ne "\n" >> "$output"
done

# Post-process the output file to replace `#`s with preceding spaces
# for hierarchical indentation in output file
awk '{
    match($0, /^#+/)
    hashes = substr($0, RSTART, RLENGTH)
    spaces = (length(hashes) - 1) * 2
    for (i = 0; i < spaces; i++) {
        printf " "
    }
    print substr($0, RSTART + RLENGTH + 1)
}' "$output" > temp.txt && mv temp.txt "$output"
