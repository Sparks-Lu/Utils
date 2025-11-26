#!/bin/bash

# Check if input files are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <input1> <input2> [output]"
  echo "Examples:"
  echo "  $0 video1.mp4 video2.mp4"
  echo "  $0 video1.mp4 video2.mp4 my_combined_video.mp4"
  exit 1
fi

INPUT1="$1"
INPUT2="$2"

# Set output filename
if [ $# -eq 3 ]; then
  OUTPUT="$3"
else
  # Generate output name based on input names
  BASE1=$(basename "$INPUT1" | cut -d. -f1)
  BASE2=$(basename "$INPUT2" | cut -d. -f1)
  OUTPUT="${BASE1}_${BASE2}_combined.mp4"
fi

# Check if input files exist
if [ ! -f "$INPUT1" ]; then
  echo "Error: Input file '$INPUT1' not found!"
  exit 1
fi

if [ ! -f "$INPUT2" ]; then
  echo "Error: Input file '$INPUT2' not found!"
  exit 1
fi

# Check if output file already exists
if [ -f "$OUTPUT" ]; then
  read -p "Output file '$OUTPUT' already exists. Overwrite? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
  fi
fi

# Function to check if video has audio
has_audio() {
  local video="$1"
  ffprobe -loglevel error -select_streams a -show_entries stream=codec_type -of csv=p=0 "$video" | grep -q "audio"
  return $?
}

# Check which inputs have audio
HAS_AUDIO1=$(has_audio "$INPUT1" && echo "true" || echo "false")
HAS_AUDIO2=$(has_audio "$INPUT2" && echo "true" || echo "false")

echo "Combining videos..."
echo "Input 1: $INPUT1 (Audio: $HAS_AUDIO1)"
echo "Input 2: $INPUT2 (Audio: $HAS_AUDIO2)"
echo "Output: $OUTPUT"

# Build FFmpeg command based on audio availability
if [ "$HAS_AUDIO1" = "true" ]; then
  # Use audio from first video
  FILTER_COMPLEX="[0:v]scale=540:720:force_original_aspect_ratio=decrease[v0];[1:v]scale=540:720:force_original_aspect_ratio=decrease[v1];[v0]pad=640:720:(640-iw)/2:(720-ih)/2[v0padded];[v1]pad=640:720:(640-iw)/2:(720-ih)/2[v1padded];[v0padded][v1padded]hstack=2[v]"
  AUDIO_MAP="-map 0:a -c:a copy"
elif [ "$HAS_AUDIO2" = "true" ]; then
  # Use audio from second video (if first has no audio)
  FILTER_COMPLEX="[0:v]scale=540:720:force_original_aspect_ratio=decrease[v0];[1:v]scale=540:720:force_original_aspect_ratio=decrease[v1];[v0]pad=640:720:(640-iw)/2:(720-ih)/2[v0padded];[v1]pad=640:720:(640-iw)/2:(720-ih)/2[v1padded];[v0padded][v1padded]hstack=2[v]"
  AUDIO_MAP="-map 1:a -c:a copy"
else
  # No audio in either video
  FILTER_COMPLEX="[0:v]scale=540:720:force_original_aspect_ratio=decrease[v0];[1:v]scale=540:720:force_original_aspect_ratio=decrease[v1];[v0]pad=640:720:(640-iw)/2:(720-ih)/2[v0padded];[v1]pad=640:720:(640-iw)/2:(720-ih)/2[v1padded];[v0padded][v1padded]hstack=2[v]"
  AUDIO_MAP="-an"
fi

# Run ffmpeg command
ffmpeg -i "$INPUT1" -i "$INPUT2" -filter_complex "$FILTER_COMPLEX" -map "[v]" $AUDIO_MAP "$OUTPUT"

# Check if successful
if [ $? -eq 0 ]; then
  echo "Success! Combined video created: $OUTPUT"
else
  echo "Error: FFmpeg command failed!"
  exit 1
fi
