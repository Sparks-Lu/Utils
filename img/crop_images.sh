#!/bin/sh
files=`ls $1/*.jpg`
echo "Files to be processed: $files"
if [ $# -lt 5 ]; then
    echo "Usage: ./crop_images.sh {image_folder} {xoffset} {yoffset} {width} {height}"
    return -1
fi
# cnt=1
dirname=$1
output_dir=${dirname}/output
mkdir -p $output_dir
for fn_in in $files; do
    dirname=$(dirname $fn_in)
    basename=$(basename $fn_in)
    fn_out="${output_dir}/${basename}"
    # fn_out="${output_dir}/${cnt}.jpg"
    xoffset=$2
    yoffset=$3
    width=$4
    height=$5
    echo "Croping $fn_in to $width*$height from ($xoffset, $yoffset): $fn_out..."
    convert -crop ${width}x${height}+${xoffset}+${yoffset} $fn_in $fn_out
    # fn_in_lower=$(echo $fn_in | tr -s '[:upper:]' '[:lower:]')
    # fn_out_lower=$(echo $fn_out | tr -s '[:upper:]' '[:lower:]')
    # rm -f $fn_in
    # cnt=$(($cnt + 1))
done
