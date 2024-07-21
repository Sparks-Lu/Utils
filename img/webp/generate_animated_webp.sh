#!/bin/bash

if [ $# -ge 1 ]; then
    input_dir=$1
else
    echo "Input source image path: (filenames must follow frame_xxx.webp)"
    read input_dir
fi
if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory does not exist."
    exit 1
fi

if [ $# -ge 2 ]; then
    pause_ms=$2
else
    echo "Input pause time (ms) between frames: "
    read pause_ms
fi

output_file=$input_dir/output.webp
webpmux_cmd="webpmux"
max_wh=400
echo "Generating animated webp from webp files in $input_dir ..."
for i in {001..048}; do
    input_file="${input_dir}/matting_${i}.webp"
    frame_file="${input_dir}/frame_${i}.webp"
    # resize
    convert ${input_file} -resize ${max_wh}^x${max_wh}^ ${frame_file}
    # turn transparent pixels into white to avoid overlap
    convert ${frame_file} -background white -flatten ${frame_file}
    webpmux_cmd="${webpmux_cmd} -frame $frame_file +$pause_ms"
done
webpmux_cmd="${webpmux_cmd} -o $output_file"
echo "Command: $webpmux_cmd"
eval "$webpmux_cmd"

if [ $? -eq 0 ]; then
    echo "Created output animated webp image: $output_file"
else
    echo "Error creating animated webp image."
fi
