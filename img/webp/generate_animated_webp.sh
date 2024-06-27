#!/bin/bash

echo "Input source image path: (filenames must follow frame_xxx.webp)"
read input_dir
if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory does not exist."
    exit 1
fi
echo "Input pause time (ms) between frames: "
read pause_ms

output_file=$input_dir/output.webp
webpmux_cmd="webpmux"
for i in {000..007}; do
    frame_file="${input_dir}/frame_${i}.webp"
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
