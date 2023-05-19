#!/bin/sh
files=`ls $1/*.png`
echo "Files to be processed: $files"
# cnt=1
cwebp -h || sudo apt install webp
for fn_input in $files; do
    dirname=$(dirname $fn_input)
    basename=$(basename $fn_input)
    fn_output="${dirname}/${basename%.*}.webp"
    # fn_output="${dirname}/${cnt}.png"
    echo "Converting $fn_input to $fn_output"
    cwebp $fn_input -o $fn_output
    # cnt=$(($cnt + 1))
done
