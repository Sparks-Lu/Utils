#!/bin/sh
if [ $# -lt 2 ]; then
    echo './gif2video.sh {input_filename} {output_filename} {fps}'
    exit
fi

fn_input=$1
fn_output=$2
fps=$3
dirname='/tmp/gif2video'
rm -rf $dirname
mkdir $dirname
convert -coalesce $fn_input "$dirname/%05d.png"
ffmpeg -r $fps -i "$dirname/%05d.png" $fn_output
