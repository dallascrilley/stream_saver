#!/bin/bash

file=$1

# Check if a download process is still active for this file
pgrep -f "wget.*$file" > /dev/null && exit 0

# Ensure the file exists and is not empty
if [ ! -s "$file" ]; then
    echo "Empty or missing raw MP3 file: $file"
    rm -f "$file"
    exit 1
fi

# Validate raw MP3 file
if ! ffprobe -i "$file" -show_streams -select_streams a:0 &>/dev/null; then
    echo "Invalid raw MP3 file: $file"
    rm -f "$file"
    exit 1
fi

# Repack raw MP3 to standard MP3 with 128 kbps bitrate
ffmpeg -i "$file" -movflags +faststart -codec:a libmp3lame -b:a 128k output.mp3 \
    "${file%.rawmp3}.mp3" || { echo "Failed to repack $file"; exit 1; }

echo "Repacked raw MP3 to MP3, removing $file"
rm -f "$file"