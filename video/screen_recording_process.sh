#!/bin/bash

resize_and_padding() {
    # resize and padding to leave top 0~200/2340 in video SNS app and bottom 1880~2340/2340
    local top_margin=$1
    local bottom_margin=$2

    # 0~400 <- 1680 -> 2080~2340
    # resize
    # result=$(echo "scale=2; 5.5 + 3.2" | bc)
    ratio=$(echo "scale=4; ($screen_height - $top_margin - $bottom_margin) * 1.0/$screen_height" | bc)
    resize_height=$(echo "$crop_height*$ratio/1" | bc)
    if (( $resize_height % 2 != 0 )); then
        resize_height=$(($resize_height + 1))
    fi
    resize_width=$(echo "$crop_width*$ratio/1" | bc)
    if (( $resize_width % 2 != 0 )); then
        resize_width=$(($resize_width + 1))
    fi
    echo "resizing video, new width: $resize_width, new height: $resize_height ..."
    resize_output_path="/tmp/resized-$(date +%s).mp4"
    ffmpeg -loglevel warning -i $crop_output_path -s ${resize_width}x${resize_height} -c:a copy $resize_output_path
    echo "Resized video: $resize_output_path"

    # padding with black
    left_pad=$((($video_width - $resize_width)/2))
    top_pad=$(($top_margin*$video_height/$screen_height))
    echo "padding video, left pad: $left_pad, top pad: $top_pad ..."
    pad_output_path="/tmp/pad-$(date +%s).mp4"
    ffmpeg -loglevel warning -i $resize_output_path -vf "pad=width=$video_width:height=$video_height:x=$left_pad:y=$top_pad:color=black" $pad_output_path
    echo "Output video: $pad_output_path"
}

crop() {
    local input_path=$1
    # recorded video resolution: 580x1280
    video_width=580
    video_height=1280

    # crop to remove top status bar on the screen in screen recording video
    # read -p "Enter crop x: " crop_x
    # read -p "Enter crop y: " crop_y
    # read -p "Enter crop width: " crop_width
    # read -p "Enter crop height: " crop_height
    crop_x=0
    crop_y=50
    crop_width=$video_width
    crop_height=$((1280 - $crop_y))
    echo "cropping x: $crop_x, y: $crop_y, w: $crop_width, h: $crop_height ..."
    crop_output_path="/tmp/cropped-$(date +%s).mp4"
    ffmpeg -loglevel warning -i $input_path -vf "crop=$crop_width:$crop_height:$crop_x:$crop_y" $crop_output_path
    echo "Cropped video: $crop_output_path"
}

input_path=$1
crop $input_path

if [ "$#" -gt 1 ]; then
    top_margin=$2
else
    top_margin=300
fi
if [ "$#" -gt 2 ]; then
    bottom_margin=$3
else
    bottom_y=2080
    bottom_margin=$(($screen_height - $bottom_y))
fi
# resize_and_padding $top_margin $bottom_margin
