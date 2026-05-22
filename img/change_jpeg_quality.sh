#!/bin/bash
# Recursively change JPEG image quality in a directory using ImageMagick.
# Usage: ./change_jpeg_quality.sh {image_folder} {quality}

if [ $# -lt 2 ]; then
    echo "Usage: $0 {image_folder} {quality}"
    echo "  image_folder  Directory to search recursively for JPEG files"
    echo "  quality       Integer from 1 (worst) to 100 (best)"
    echo ""
    echo "Example:"
    echo "  $0 ./photos 80"
    exit 1
fi

path=$1
quality=$2

if [ ! -d "$path" ]; then
    echo "Error: '$path' is not a valid directory"
    exit 1
fi

if ! [[ "$quality" =~ ^[0-9]+$ ]] || [ "$quality" -lt 1 ] || [ "$quality" -gt 100 ]; then
    echo "Error: quality must be an integer between 1 and 100"
    exit 1
fi

count=0
while IFS= read -r -d '' fn_in; do
    echo "Adjusting quality for $fn_in to ${quality}..."
    mogrify -quality "$quality" "$fn_in"
    count=$((count + 1))
done < <(find "$path" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.jpe" -o -iname "*.jfif" \) -print0)

echo "Done. $count JPEG file(s) processed."
