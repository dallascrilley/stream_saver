
RECDIR=/mnt/newdrive/Recordings

# Force date to Central Time (CST/CDT) depending on daylight savings
CURRENT_HOUR=$(TZ=America/Chicago date +%H)

# Only run if it's between 4am (hour=04) and 11pm (hour=23) CST
if [ "$CURRENT_HOUR" -ge 4 ] && [ "$CURRENT_HOUR" -le 23 ]; then
    echo "Within 4am-11pm CST window. Starting capture..."

    # Clean up empty files
    find "$RECDIR" -type f -empty -delete

    cd "$(dirname "$0")"
    for f in urls/*
    do
        EXT=aac
        # Get URL from configfile
        source "$f"
        NAME=$(basename "$f")

        PIDFILE="pid/$NAME.pid"
        LOGFILE="logs/$NAME-wget.log"

        if [ -f "$PIDFILE" ]; then
            PID=$(cat "$PIDFILE")
            if kill -0 "$PID" 2>/dev/null; then
                echo "Stopping previous process for $NAME (PID: $PID)"
                kill "$PID"
                sleep 1
            fi
        fi

        folder="$RECDIR/$NAME/$(date +%m-%d-%Y/%H00/)"
        filename="${folder}${NAME}-$(date +%m%d%y-%H%M%S).$EXT"

        mkdir -p "$folder"
        wget --retry-connrefused --waitretry=50 --read-timeout=50 --timeout=60 \
            --background -O "$filename" -c -t 0 -a "$LOGFILE" "$URL"

        WGET_PID=$!
        echo "$WGET_PID" > "$PIDFILE"
    done

    # Clean up old files and directories
    find "$RECDIR" -type f -mtime +2 -delete
    find "$RECDIR" -type d -empty -delete

    # Process AAC and RAWMP3 files
    find "$RECDIR" -name "*.aac" -exec /home/stream/bin/repack_aac.sh {} \;
    find "$RECDIR" -name "*.rawmp3" -exec /home/stream/bin/repack_rawmp3.sh {} \;

    # Footer HTML
    footer="$RECDIR/.footer.html"
    echo "<h3>US Central Time</h3>" > "$footer"
    echo "<pre>" >> "$footer"
    df -h "$RECDIR" >> "$footer"
    echo "</pre>" >> "$footer"

else
    echo "Outside scheduled recording hours (4am - 11pm CST). Skipping stream capture..."
fi