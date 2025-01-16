#!/bin/bash

file=$1

pgrep -f "wget.*$file" > /dev/null && exit 0
ffmpeg -i $file -movflags +faststart -codec: copy ${file%.mov}.mp3 || exit 1
