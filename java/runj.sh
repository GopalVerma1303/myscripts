#!/bin/zsh

if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <filename>"
	exit 1
fi

filename="$1"
output_file="${filename%.*}"

javac "$filename" && java "$output_file"

if [ $? -eq 0 ]; then
	echo "\nSuccessful!❤️"
else
	echo "\nFailed!💩"
fi
