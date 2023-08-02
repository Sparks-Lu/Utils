#!/bin/sh
files=`ls $1/*.JPG`
ratio=$2
echo "Scale ratio: $ratio, Files to be processed: $files"
cnt=1
for fn_in in $files; do
    # dirname=$(dirname $fn_in)
    # basename=$(basename $fn_in)
    # base="${dirname}/${basename%.*}.png"
    # fn_out="${dirname}/${cnt}.jpg"
    fn_out=${fn_in}
    wh=`identify -format '%w %h' ${fn_in}`
    echo "wh: $wh"
    width_old=$(echo $wh | cut -d' ' -f1)
    height_old=$(echo $wh | cut -d' ' -f2)
    echo "old width: $width_old, old height: $height_old"
    width=$(echo "$width_old*$ratio" | bc)
    height=$(echo "$height_old*$ratio" | bc)
    echo "width: $width, height: $height"
    echo "Resizing $fn_in to $width*$height: $fn_out..."
    convert -resize ${width}x${height} $fn_in $fn_out
    cnt=$(($cnt + 1))
done
