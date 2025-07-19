#!/bin/bash

# This is a simple script to generate/initialize the .md markdown files from a course's constituent
# top-level README.md markdown, with the corresponding Title as the top-level heading(s) in the first
# line of the correspondingly generated file(s). By default, the script will parse the current working
# directory inside of which it is located and output to this as well. Otherwise, specify the path to the
# course subfolder as the first command line argument (e.g., ../cs-7641) and the target output folder as
# the second command line argument (e.g., ../cs-7641), for example:
# $ ./create-markdowns ../cs-6741 ../cs-6741

# Input and output directories default to current directory if not provided
INPUT_DIR="${1:-.}"
OUTPUT_DIR="${2:-.}"
README="$INPUT_DIR/README.md"

# Check that README exists
if [ ! -f "$README" ]; then
    echo "Error: README.md not found in input directory: $INPUT_DIR"
    exit 1
fi

# Parse and generate files
grep '\.md' "$README" | awk -F '|' '
{
    gsub(/^[ \t]+|[ \t]+$/, "", $2)
    gsub(/^[ \t]+|[ \t]+$/, "", $3)

    if (match($2, /\(([^)]+\.md)\)/, m)) {
        filename = m[1]
        topic = $3
        print filename "|" topic
    }
}' | while IFS='|' read -r filename topic; do
    if [[ -z "$filename" ]]; then
        continue
    fi

    filepath="$OUTPUT_DIR/$filename"

    # Only create file if it does not exist or is empty
    if [ ! -s "$filepath" ]; then
        mkdir -p "$(dirname "$filepath")"
        echo "# $topic" > "$filepath"
        echo "Created: $filepath with heading '# $topic'"
    fi
done
