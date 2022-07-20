#!/bin/sh
files=`ls $1/*.wav`
echo "Files to be processed: $files"
for file in $files; do
    dirname=$(dirname $file)
    basename=$(basename $file)
    output="${dirname}/${basename}.mp3"
    echo "Converting $file to $output"
    ffmpeg -i $file -acodec mp3 $output
done
