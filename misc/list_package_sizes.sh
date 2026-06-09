#!/bin/bash

N=20
VENV=""

usage() {
  echo "Usage: $0 [-n NUM] <path_to_virtualenv>"
  echo "  -n NUM   Show top N packages (default: 20, 0 = all)"
  exit 1
}

while getopts "n:h" opt; do
  case $opt in
    n) N="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND - 1))

VENV="${1:?$(usage)}"

if [ ! -d "$VENV" ]; then
  echo "Error: $VENV is not a directory" >&2
  exit 1
fi

SITE_PKGS=$(find "$VENV" -maxdepth 4 -type d \( -name site-packages -o -name dist-packages \) 2>/dev/null | head -1)
if [ -z "$SITE_PKGS" ]; then
  echo "Error: site-packages not found in $VENV" >&2
  exit 1
fi

echo "Packages in: $SITE_PKGS"
echo

ALL=$(du -s "$SITE_PKGS"/* 2>/dev/null \
  | grep -vE '/(__pycache__|[^/]+\.dist-info|[^/]+\.egg-info)$' \
  | sort -nr)

if [ -z "$ALL" ]; then
  echo "No packages found." >&2
  exit 0
fi

TOTAL_COUNT=$(echo "$ALL" | wc -l)
TOTAL_SUM=$(echo "$ALL" | awk '{sum+=$1} END {print sum}')
SITE_TOTAL=$(du -s "$SITE_PKGS" | awk '{print $1}')

if [ "$N" -gt 0 ] && [ "$N" -lt "$TOTAL_COUNT" ]; then
  SHOWN=$(echo "$ALL" | head -n "$N")
else
  SHOWN="$ALL"
fi

SHOWN_COUNT=$(echo "$SHOWN" | wc -l)
SHOWN_SUM=$(echo "$SHOWN" | awk '{sum+=$1} END {print sum}')

fmt_size() {
  awk -v s="$1" 'BEGIN {
    if (s >= 1048576)      printf "%.1fG", s/1048576
    else if (s >= 1024)    printf "%.1fM", s/1024
    else                   printf "%dK", s
  }'
}

echo "$SHOWN" | awk -v prefix="$SITE_PKGS/" '{
  size=$1
  dir=substr($2, length(prefix)+1)
  if (size >= 1048576)       printf "%6.1fG\t%s\n", size/1048576, dir
  else if (size >= 1024)     printf "%6.1fM\t%s\n", size/1024, dir
  else                       printf "%6dK\t%s\n", size, dir
}'

echo "----------------------------------------------------------------------"
printf "Showing top %d of %d packages (%s of %s total)\n" \
  "$SHOWN_COUNT" \
  "$TOTAL_COUNT" \
  "$(fmt_size "$SHOWN_SUM")" \
  "$(fmt_size "$SITE_TOTAL")"
