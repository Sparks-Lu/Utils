#!/bin/sh
files=`ls $1/*.jpg`
echo "Files to be processed: $files"
for fn_in in $files; do
    # dirname=$(dirname $fn_in)
    # basename=$(basename $fn_in)
    # base="${dirname}/${basename%.*}.png"
    # bowl1 obj360
    xoffset=2000
    yoffset=1000
    width=3000
    height=3000
    delta_brightness=0
    delta_contrast=60
    # fn_out="${dirname}/b${delta_brightness}_c${delta_contrast}_${basename}"
    fn_out=${fn_in}
    echo "Adjusting brightness and contrast to $fn_in (brightness: $delta_brightness, contrast: $delta_contrast): $fn_out..."
    convert -brightness-contrast ${delta_brightness}x${delta_contrast} $fn_in $fn_out
done
