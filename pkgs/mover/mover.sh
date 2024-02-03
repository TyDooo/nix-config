#!/bin/sh

# This script is used to move files from the cache drive(s) to the main
# drive pool.

if [ $# != 3 ]; then
  echo "usage: $0 <cache-fs> <backing-pool> <days-old>"
  exit 1
fi

# Check if cache drive is mounted.
if ! mountpoint -q "${1}"; then
  echo "cache drive not mounted"
  exit 1
fi

# Check if backing pool is mounted.
if ! mountpoint -q "${2}"; then
  echo "backing pool not mounted"
  exit 1
fi

# Check if mover is already running.
if [ -f /var/run/mover.pid ]; then
  echo "mover already running"
  exit 0
fi

CACHE="${1}"
BACKING="${2}"
N=${3}

echo $$ >/var/run/mover.pid
echo "mover started"

find "${CACHE}" -type f -atime +"${N}" -printf '%P\n' | \
  rsync --files-from=- -axqHAXWES --preallocate --remove-source-files "${CACHE}/" "${BACKING}/"

rm /var/run/mover.pid
echo "mover finished"