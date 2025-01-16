#!/bin/bash

for file in $(find "$(pwd)" -type f -name "*.m4a")
do 
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        continue
    fi

    time=$(echo "$file" | cut -d'/' -f6,7 | sed 's/\//-/g' | awk -F'-' '{print $3$1$2$4}')
    echo "Setting time $time for $file"
    touch -a -m -t "$time" "$file"
done