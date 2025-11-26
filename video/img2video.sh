#!/bin/bash

# Check parameters
if [ $# -lt 2 ]; then
  echo "Usage: $0 <input_image> <duration_seconds> [output_video] [--fps <fps>] [--resolution <width>x<height>] [--audio <audio_file>]"
  echo "Examples:"
  echo "  $0 image.jpg 10"
  echo "  $0 image.png 5 output.mp4 --fps 30"
  echo "  $0 image.jpg 15 video.mp4 --resolution 1920x1080 --audio background.mp3"
  exit 1
fi

INPUT_IMAGE="$1"
DURATION="$2"
OUTPUT_VIDEO="${3:-output.mp4}"

# Default values
FPS=25
RESOLUTION=""
AUDIO_FILE=""

# Parse optional parameters
shift 3
while [ $# -gt 0 ]; do
  case $1 in
  --fps)
    FPS="$2"
    shift 2
    ;;
  --resolution)
    RESOLUTION="$2"
    shift 2
    ;;
  --audio)
    AUDIO_FILE="$2"
    shift 2
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

# Check if input image exists
if [ ! -f "$INPUT_IMAGE" ]; then
  echo "Error: Input image '$INPUT_IMAGE' not found!"
  exit 1
fi

# Validate duration
if ! [[ "$DURATION" =~ ^[0-9]+([.][0-9]+)?$ ]] || (($(echo "$DURATION <= 0" | bc -l 2>/dev/null || echo "1"))); then
  echo "Error: Duration must be a positive number!"
  exit 1
fi

# Validate FPS
if ! [[ "$FPS" =~ ^[0-9]+([.][0-9]+)?$ ]] || (($(echo "$FPS <= 0" | bc -l 2>/dev/null || echo "1"))); then
  echo "Error: FPS must be a positive number!"
  exit 1
fi

# Check if audio file exists (if provided)
if [ -n "$AUDIO_FILE" ] && [ ! -f "$AUDIO_FILE" ]; then
  echo "Error: Audio file '$AUDIO_FILE' not found!"
  exit 1
fi

echo "Creating video from '$INPUT_IMAGE'"
echo "Duration: ${DURATION} seconds"
echo "FPS: $FPS"
[ -n "$RESOLUTION" ] && echo "Resolution: $RESOLUTION"
[ -n "$AUDIO_FILE" ] && echo "Audio: $AUDIO_FILE"
echo "Output: $OUTPUT_VIDEO"

# Build FFmpeg command
FFMPEG_CMD="ffmpeg -loop 1 -i \"$INPUT_IMAGE\""

# Add audio if provided
if [ -n "$AUDIO_FILE" ]; then
  FFMPEG_CMD="$FFMPEG_CMD -i \"$AUDIO_FILE\" -shortest"
fi

# Add resolution scaling if specified
SCALE_FILTER=""
if [ -n "$RESOLUTION" ]; then
  SCALE_FILTER=",scale=$RESOLUTION:flags=lanczos"
fi

# Complete the command
FFMPEG_CMD="$FFMPEG_CMD -t $DURATION -r $FPS -c:v libx264 -pix_fmt yuv420p -vf \"format=yuv420p${SCALE_FILTER}\" -y \"$OUTPUT_VIDEO\""

# Execute command
eval $FFMPEG_CMD

if [ $? -eq 0 ]; then
  echo "Success! Video created: $OUTPUT_VIDEO"
else
  echo "Error: FFmpeg command failed!"
  exit 1
fi
