#!/bin/sh
echo "Enter src image file extension:"
read input_ext
echo "Enter target image file extension:"
read output_ext
quality=""
case "$output_ext" in
    jpg|jpeg|webp)
        echo "Enter quality (1-100, default 85):"
        read quality
        quality=${quality:-85}
        ;;
esac
files=`ls $1/*.${input_ext}`
echo "Files to be processed: $files"
for file in $files; do
    dirname=$(dirname $file)
    basename=$(basename $file)
    base="${dirname}/${basename%.*}.${output_ext}"
    echo "Converting $file to $base"
    if [ -n "$quality" ]; then
        convert $file -quality $quality $base
    else
        convert $file $base
    fi
done
