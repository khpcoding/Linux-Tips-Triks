#!/bin/bash

# Check if 'iostat' is installed
if ! command -v iostat >/dev/null; then
    echo "'iostat' command not found. Please install 'sysstat' package."
    exit 1
fi

echo "Monitoring disk IOPS every second. Press [CTRL+C] to exit."

# Infinite loop to get disk IOPS every second
while true; do
    clear
    echo "Timestamp: $(date)"
    echo "Disk IOPS:"
    # iostat with -dx option for extended stats without restarting counters
    iostat -dx 1 1 | awk 'NR > 6 {print $1, "IOPS:  Read:" $4, " Write:" $5}' | column -t
    sleep 1
done

