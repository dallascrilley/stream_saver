#!/bin/bash

# Directory where the logs are stored
log_dir="/home/stream/bin/logs"

# Max allowed size in bytes (20MB)
max_size=20000000 

# Go through each log file in the directory
for file in $log_dir/*.log; do
    # If file size exceeds max_size
    if [ $(stat -c%s "$file") -gt $max_size ]; then
        # Delete the file
        rm "$file"
    fi
done
