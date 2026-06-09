#!/bin/bash

N=10
INCLUDE_HIDDEN=false
SHOW_APPARENT=true
STAY_FILESYSTEM=false
FOLLOW_SYMLINKS=false

usage() {
  echo "Usage: $0 [-n NUM] [-a] [-d] [-x] [-L] [-h] <directory>"
  echo "  -n NUM  Show top N biggest files (default: 10)"
  echo "  -a      Include hidden files (dotfiles)"
  echo "  -d      Show disk usage instead of apparent size"
  echo "  -x      Stay on same filesystem (don't cross mount points)"
  echo "  -L      Follow symlinks"
  echo "  -h      Show this help"
  exit 1
}

while getopts "n:adxLh" opt; do
  case $opt in
    n) N="$OPTARG" ;;
    a) INCLUDE_HIDDEN=true ;;
    d) SHOW_APPARENT=false ;;
    x) STAY_FILESYSTEM=true ;;
    L) FOLLOW_SYMLINKS=true ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

DIR="${1:?$(usage)}"

if [ ! -d "$DIR" ]; then
  echo "Error: $DIR is not a directory" >&2
  exit 1
fi

if ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -eq 0 ]; then
  echo "Error: -n must be a positive integer" >&2
  exit 1
fi

FIND_OPTS=()
FIND_OPTS+=("$DIR" -type f)

if ! $INCLUDE_HIDDEN; then
  FIND_OPTS+=(! -name '.*')
fi

if $STAY_FILESYSTEM; then
  FIND_OPTS+=(-xdev)
fi

if $FOLLOW_SYMLINKS; then
  FIND_OPTS=(-L "${FIND_OPTS[@]}")
fi

PRINTF_FMT='%s\t%p\0'

if $SHOW_APPARENT; then
  FIND_OPTS+=(-printf "$PRINTF_FMT")
else
  FIND_OPTS+=(-printf '%k\t%p\0')
fi

if ! OUTPUT=$(find "${FIND_OPTS[@]}" 2>/dev/null | sort -z -nr | head -z -n "$N" | tr '\0' '\n'); then
  echo "Error: failed to scan directory" >&2
  exit 1
fi

if [ -z "$OUTPUT" ]; then
  echo "No files found in $DIR"
  exit 0
fi

TOTAL_COUNT=$(find "$DIR" -type f ! -name '.*' 2>/dev/null | wc -l)

fmt_size() {
  awk -v s="$1" -v disk="$2" 'BEGIN {
    m = (disk == "true") ? 1024 : 1
    v = s * m
    if (v >= 1099511627776)       printf "%5.1fT", v/1099511627776
    else if (v >= 1073741824)     printf "%5.1fG", v/1073741824
    else if (v >= 1048576)        printf "%5.1fM", v/1048576
    else if (v >= 1024)           printf "%5.1fK", v/1024
    else                          printf "%5dB", v
  }'
}

echo "$OUTPUT" | while IFS=$'\t' read -r size path; do
  HR=$(fmt_size "$size" "$( $SHOW_APPARENT && echo false || echo true )")
  echo "$HR  $path"
done

