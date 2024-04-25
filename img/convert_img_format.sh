#!/bin/sh
echo "Enter src image file extension:"
read input_ext
echo "Enter target image file extension:"
read output_ext
files=`ls $1/*.${input_ext}`
echo "Files to be processed: $files"
for file in $files; do
    dirname=$(dirname $file)
    basename=$(basename $file)
    base="${dirname}/${basename%.*}.${output_ext}"
    echo "Converting $file to $base"
    convert $file $base
done
