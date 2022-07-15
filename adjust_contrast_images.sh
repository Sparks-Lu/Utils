#!/bin/sh
if [ $# -lt 3 ]; then
    echo "Usage: ./adjust_contrast_images.sh {image_folder} {delta_brightness} {delta_contrast}"
    return -1
fi
files=`ls $1/*.webp`
echo "Files to be processed: $files"
for fn_in in $files; do
    # dirname=$(dirname $fn_in)
    # basename=$(basename $fn_in)
    # base="${dirname}/${basename%.*}.png"
    # bowl1 obj360
    delta_brightness=$2
    delta_contrast=$3
    # fn_out="${dirname}/b${delta_brightness}_c${delta_contrast}_${basename}"
    fn_out=${fn_in}
    echo "Adjusting brightness and contrast to $fn_in (brightness: $delta_brightness, contrast: $delta_contrast): $fn_out..."
    convert -brightness-contrast ${delta_brightness}x${delta_contrast} $fn_in $fn_out
done
