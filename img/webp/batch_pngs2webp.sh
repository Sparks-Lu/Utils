#!/bin/bash
folders=(5 6 7 8 9 10)
for folder in ${folders[@]}
do
    dir=/mnt/d/Projects/PotteryMuseum/obj360/${folder}/matting/
    echo $dir
    ./pngs2webp.sh $dir
done
