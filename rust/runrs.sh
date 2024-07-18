#!/bin/zsh

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <filename>"
	exit 1
fi

filename="$1"
output_file="${filename%.*}"

rustc "$filename" -o "$output_file" && ./"$output_file"

if [ $? -eq 0 ]; then
	echo "\n\nSuccessful!❤️"
else
	echo "\nFailed!💩"
fi
