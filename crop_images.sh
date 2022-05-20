#!/bin/sh
files=`ls $1/*.JPG`
echo "Files to be processed: $files"
cnt=1
for fn_in in $files; do
    dirname=$(dirname $fn_in)
    basename=$(basename $fn_in)
    # base="${dirname}/${basename%.*}.png"
    fn_out="${dirname}/${cnt}.jpg"
    xoffset=2000
    yoffset=400
    width=3000
    height=3800
    echo "Croping $fn_in to $width*$height from ($xoffset, $yoffset): $fn_out..."
    convert -crop ${width}x${height}+${xoffset}+${yoffset} $fn_in $fn_out
    cnt=$(($cnt + 1))
done
