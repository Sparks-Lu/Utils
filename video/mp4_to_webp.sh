#!/bin/sh
ffmpeg -i input.mp4 -vf "select='not(mod(n\,5))',setpts='N/(5*TBR)'" /tmp/frames/output_%04d.png
for file in /tmp/frames/output_*.png; do
    cwebp -q 80 "$file" -o "${file%.png}.webp" && rm "$file"
done
rm -rf /tmp/frames
