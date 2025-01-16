#!/bin/bash

RECDIR=/home/stream/Recordings

find $RECDIR -type f -empty -delete

find $RECDIR -type f -mtime +2 -delete
find $RECDIR -type d -empty -delete

footer=$RECDIR/.footer.html
echo "<h2>Attention! This is an old recordings with UTC timestamps!</h2>" > $footer
echo "<pre>" >> $footer
df -h $RECDIR >> $footer
echo "</pre>" >> $footer
