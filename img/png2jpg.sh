#!/bin/sh
files=`ls $1/*.png`
echo "Files to be processed: $files"
for file in $files; do
    dirname=$(dirname $file)
    basename=$(basename $file)
    base="${dirname}/${basename%.*}.JPG"
    echo "Converting $file to $base"
    convert -quality 90 $file $base
done
