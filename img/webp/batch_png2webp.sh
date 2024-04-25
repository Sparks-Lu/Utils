#!/bin/bash

dir=/mnt/d/Projects/PotteryMuseum/images/photosUsed
subdirs=(33 35 42 72 74 85 88 93 601 603 607)
for subdir in "${subdirs[@]}"; do
    full_path="${dir}/${subdir}"
    echo "Processing $full_path..."
    ./png2webp.sh "$full_path"
done
