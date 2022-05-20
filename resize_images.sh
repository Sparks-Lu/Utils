#!/bin/sh
files=`ls $1/*.jpg`
echo "Files to be processed: $files"
cnt=1
for fn_in in $files; do
    # dirname=$(dirname $fn_in)
    # basename=$(basename $fn_in)
    # base="${dirname}/${basename%.*}.png"
    # fn_out="${dirname}/${cnt}.jpg"
    fn_out=${fn_in}
    width=1500
    height=1300
    echo "Resizing $fn_in to $width*$height: $fn_out..."
    convert -resize ${width}x${height} $fn_in $fn_out
    cnt=$(($cnt + 1))
done
