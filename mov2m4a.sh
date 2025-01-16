#!/bin/bash

file=$1

ffmpeg -i $file -movflags +faststart -codec: copy ${file%.mov}.m4a || exit 1
echo Removing $file
rm -f $file
