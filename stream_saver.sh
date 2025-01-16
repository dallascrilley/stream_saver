#!/bin/bash

RECDIR=/mnt/newdrive/Recordings

find $RECDIR -type f -empty -delete

cd `dirname $0`
for f in urls/*
do
    EXT=aac
    # Get URL from configfile
    source $f
    NAME=`basename $f`

    PIDFILE=pid/$NAME.pid
    LOGFILE=logs/$NAME-wget.log

    kill `cat $PIDFILE`

    folder=$RECDIR/$NAME/`date +%m-%d-%Y/%H00/`
    filename=${folder}`date +$NAME-%m%d%y-%H%M%S.$EXT`

    mkdir -p $folder
    PID=$( wget --retry-connrefused --waitretry=50 --read-timeout=50 --timeout=60 --background -O $filename -c -t 0 -a $LOGFILE "$URL" | sed 's/[^0-9]//g' )
    unset http_proxy
    echo $PID > $PIDFILE
done

find $RECDIR -type f -mtime +2 -delete
find $RECDIR -type d -empty -delete

find $RECDIR -name "*.aac" -exec /home/stream/bin/repack_aac.sh {} \;
find $RECDIR -name "*.rawmp3" -exec /home/stream/bin/repack_rawmp3.sh {} \;

footer=$RECDIR/.footer.html
echo "<h3>US Central Time</h3>" > $footer
echo "<pre>" >> $footer
df -h $RECDIR >> $footer
echo "</pre>" >> $footer
