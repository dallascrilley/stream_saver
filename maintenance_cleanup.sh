#!/usr/bin/env bash

# Where recordings live
RECDIR="/mnt/newdrive/Recordings"

# Where logs are stored
LOG_DIR="/home/stream/bin/logs"

# Disk usage threshold percentage (adjust as needed)
THRESHOLD=80

echo "=== Maintenance Cleanup Script Starting: $(date) ==="

########################################
# 1) CHECK DISK USAGE & AGGRESSIVELY PURGE IF ABOVE THRESHOLD
########################################
usage=$(df -P "$RECDIR" | tail -1 | awk '{print $5}' | sed 's/%//')
echo "Current usage on $RECDIR is $usage%."

if [ "$usage" -gt "$THRESHOLD" ]; then
  echo "Usage is above $THRESHOLD%. Removing oldest files until below threshold..."

  # Find oldest files first; remove them one by one until usage < THRESHOLD
  # Adjust the find path if needed. Sort by modification time ascending (oldest first).
  while [ "$usage" -gt "$THRESHOLD" ]; do
    oldest_file=$(find "$RECDIR" -type f -printf '%T+ %p\n' \
      | sort | head -n1 | cut -d' ' -f2-)

    if [ -z "$oldest_file" ]; then
      echo "No more files found to delete, but still above threshold. Exiting."
      break
    fi

    echo "Removing $oldest_file to free space..."
    rm -f "$oldest_file"

    # Re-check usage
    usage=$(df -P "$RECDIR" | tail -1 | awk '{print $5}' | sed 's/%//')
  done
fi

########################################
# 2) STANDARD HOUSEKEEPING (OLD FILES, EMPTY FILES, ETC.)
########################################

# Remove empty files
find "$RECDIR" -type f -empty -delete

# Remove files older than 2 days (adjust +2 as you prefer)
find "$RECDIR" -type f -mtime +2 -delete

# Remove empty directories
find "$RECDIR" -type d -empty -delete

########################################
# 3) PROCESS AAC & RAWMP3 FILES
########################################

# Safely repack .aac -> .m4a
find "$RECDIR" -name "*.aac" -exec /home/stream/bin/repack_aac.sh {} \;

# Safely repack .rawmp3 -> .mp3
find "$RECDIR" -name "*.rawmp3" -exec /home/stream/bin/repack_rawmp3.sh {} \;

########################################
# 4) LOG CLEANUP
########################################

# Example: If a single log file exceeds 20MB, remove it
max_size=20000000
for file in "$LOG_DIR"/*.log; do
  [ -f "$file" ] || continue
  if [ "$(stat -c%s "$file")" -gt "$max_size" ]; then
    echo "Removing large log file: $file"
    rm -f "$file"
  fi
done

########################################
# 5) OPTIONAL: TRIM OLD LOGS (E.G. > 7 DAYS)
########################################
# find "$LOG_DIR" -type f -name "*.log" -mtime +7 -exec rm -f {} \;

########################################
# 6) GENERATE A FOOTER OR SUMMARY
########################################
footer="$RECDIR/.footer.html"
{
  echo "<h3>US Central Time</h3>"
  echo "<pre>"
  df -h "$RECDIR"
  echo "</pre>"
} > "$footer"

echo "=== Maintenance Cleanup Script Finished: $(date) ==="