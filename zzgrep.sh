#!/bin/bash

zzgrep () {
 filename="$1"
 search_pattern="$2"

 #Check that file is exist
if [ ! -f "$filename" ]; then
	echo "Failed: '$filename' doesn't exist"
	exit 1
fi

#Creating temp directory
script_dir="$(dirname "$0")"
temp_dir="$script_dir"/temp
mkdir -p "$script_dir"/temp

#Unzip archive to temp	
tar -xzf "$filename" -C "$temp_dir"

#-R search with pattern
grep -R "$search_pattern" "$temp_dir"
#Deleting temp directory
rm -rf "$temp_dir"

}
