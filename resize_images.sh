#!/bin/sh
files=`ls $1/*.JPG`
echo "Files to be processed: $files"
cnt=1
for fn_in in $files; do
    dirname=$(dirname $fn_in)
    basename=$(basename $fn_in)
    # base="${dirname}/${basename%.*}.png"
    fn_out="${dirname}/${cnt}.jpg"
    width=2048
    height=1365
    echo "Resizing $fn_in to $width*$height: $fn_out..."
    convert -resize ${width}x${height} $fn_in $fn_out
    cnt=$(($cnt + 1))
done
