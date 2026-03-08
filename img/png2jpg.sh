#!/bin/sh
for file in "$1"/*.png; do
  dirname=$(dirname "$file")
  basename=$(basename "$file")
  base="${dirname}/${basename%.*}.JPG"
  echo "Converting $file to $base"
  convert -quality 90 "$file" "$base"
done
