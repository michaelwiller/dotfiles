#!/bin/bash

# Define source and destination directories
source_dir="$1"
dest_dir="$2"

# Ensure the destination directory exists
mkdir -p "$dest_dir"

# Perform tar operation with current date as part of the name
tar_filename="backup_$(date +%Y-%m-%d).tar.gz"
tar -czf "$dest_dir/$tar_filename" -C "$source_dir" .

# Clean up old tar files, keeping only the latest 7
cd "$dest_dir" || exit
ls -t | grep '^backup_' | tail -n +8 | xargs rm -f

