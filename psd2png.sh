#!/bin/sh
files=`ls $1/*.psd`
echo "Files to be processed: $files"
# cnt=1
# using psd-cli
psd --version || sudo cnpm i -g psd-cli
for fn_input in $files; do
    dirname=$(dirname $fn_input)
    basename=$(basename $fn_input)
    fn_output="${dirname}/${basename%.*}.webp"
    # fn_output="${dirname}/${cnt}.png"
    echo "Converting $fn_input to $fn_output"
    # convert a.psd to a.png
    psd $fn_input -c
    # cnt=$(($cnt + 1))
done
