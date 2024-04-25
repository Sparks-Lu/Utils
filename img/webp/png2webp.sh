#!/bin/sh
files=`ls $1/*.png`
echo "Files to be processed: $files"
cnt=1
for file in $files; do
    dirname=$(dirname $file)
    basename=$(basename $file)
    base="${dirname}/${basename%.*}.webp"
    # base="${dirname}/${cnt}.png"
    echo "Converting $file to $base"
    convert $file $base
    cnt=$(($cnt + 1))
done
