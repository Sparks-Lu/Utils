#!/bin/sh
sudo apt-get install -y libheif-examples
files=`ls $1/*.heic`
echo "Files to be processed: $files"
cnt=1
for file in $files; do
    dirname=$(dirname $file)
    basename=$(basename $file)
    base="${dirname}/${basename%.*}.png"
    # base="${dirname}/${cnt}.png"
    echo "Converting $file to $base"
    heif-convert $file $base
    cnt=$(($cnt + 1))
done
