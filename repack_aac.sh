#!/bin/bash

file=$1

pgrep -f "wget.*$file" > /dev/null && exit 0
ffmpeg -i $file -movflags +faststart -bsf:a aac_adtstoasc -codec: copy ${file%.aac}.m4a || exit 1
echo Repacked, removing $file
rm -f $file
