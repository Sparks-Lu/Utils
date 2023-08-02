ffmpeg -i input.mp4 -filter:v "setpts=0.5*PTS" output1.mp4
ffmpeg -i output1.mp4 -s 480x270 -c:a copy output2.mp4
ffmpeg -i output2.mp4 -f gif output.gif
