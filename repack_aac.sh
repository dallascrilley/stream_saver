#!/bin/bash

file=$1

# Check if a download process is still active for this file
pgrep -f "wget.*$file" > /dev/null && exit 0

# Ensure the file exists and is not empty
if [ ! -s "$file" ]; then
    echo "Empty or missing AAC file: $file"
    rm -f "$file"
    exit 1
fi

# Validate AAC file
if ! ffprobe -i "$file" -show_streams -select_streams a:0 &>/dev/null; then
    echo "Invalid AAC file: $file"
    rm -f "$file"
    exit 1
fi

# Repack AAC to M4A
ffmpeg -i "$file" -movflags +faststart -bsf:a aac_adtstoasc -codec:copy \
    "${file%.aac}.m4a" || { echo "Failed to repack $file"; exit 1; }

echo "Repacked AAC to M4A, removing $file"
rm -f "$file"