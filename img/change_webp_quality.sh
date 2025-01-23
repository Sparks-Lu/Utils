#!/bin/bash
if [ $# -lt 2 ]; then
    echo "Usage: ./change_webp_quality.sh {image_folder} {new_quality}"
    exit
fi
files=`ls $1/*.webp`
# 80 is alright
quality=$2

for fn_in in $files; do
    fn_out=${fn_in}
    echo "Adjusting quality for $fn_in, output: $fn_out..."
    convert $fn_in -define webp:lossless=false -quality $quality $fn_out
done
