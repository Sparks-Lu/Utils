#!/bin/bash
parent_folder=/mnt/d/Projects/PotteryMuseum/obj360/
folders=(1 2 3 4 5 6 7 8 9 10)
for folder in ${folders[@]}
do
    path=${parent_folder}/${folder}/webp
    echo $path
    ./generate_animated_webp.sh $path 200
done
