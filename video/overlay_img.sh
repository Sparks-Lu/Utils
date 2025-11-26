#!/bin/bash

if [ $# -lt 2 ]; then
  echo "Usage: $0 <input_video> <overlay_image> [output_video] [options]"
  echo "Options:"
  echo "  --position <x,y>          Custom position (e.g., 100,200)"
  echo "  --center                  Center position (default)"
  echo "  --top-left                Top left corner"
  echo "  --top-right               Top right corner"
  echo "  --bottom-left             Bottom left corner"
  echo "  --bottom-right            Bottom right corner"
  echo "  --scale <width>x<height>  Scale overlay image"
  echo "  --opacity <0.0-1.0>       Set overlay opacity"
  echo "  --fade                    Fade in effect"
  echo "  --fade-start <seconds>    Fade start time"
  echo "  --fade-duration <seconds> Fade duration"
  exit 1
fi

INPUT_VIDEO="$1"
OVERLAY_IMAGE="$2"
OUTPUT_VIDEO="output_with_overlay.mp4"

# Default values
POSITION="center"
SCALE=""
OPACITY="1.0"
FADE=false
FADE_START=0
FADE_DURATION=1

# Check if third argument is output file or option
if [ $# -ge 3 ] && [[ ! "$3" == --* ]]; then
  OUTPUT_VIDEO="$3"
  shift 3
else
  shift 2
fi

# Parse optional parameters
while [ $# -gt 0 ]; do
  case $1 in
  --position)
    POSITION="custom,$2"
    shift 2
    ;;
  --center)
    POSITION="center"
    shift
    ;;
  --top-left)
    POSITION="top-left"
    shift
    ;;
  --top-right)
    POSITION="top-right"
    shift
    ;;
  --bottom-left)
    POSITION="bottom-left"
    shift
    ;;
  --bottom-right)
    POSITION="bottom-right"
    shift
    ;;
  --scale)
    SCALE="$2"
    shift 2
    ;;
  --opacity)
    OPACITY="$2"
    shift 2
    ;;
  --fade)
    FADE=true
    shift
    ;;
  --fade-start)
    FADE_START="$2"
    shift 2
    ;;
  --fade-duration)
    FADE_DURATION="$2"
    shift 2
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

# Check if input files exist
if [ ! -f "$INPUT_VIDEO" ]; then
  echo "Error: Input video '$INPUT_VIDEO' not found!"
  exit 1
fi

if [ ! -f "$OVERLAY_IMAGE" ]; then
  echo "Error: Overlay image '$OVERLAY_IMAGE' not found!"
  exit 1
fi

echo "Overlaying image onto video..."
echo "Input video: $INPUT_VIDEO"
echo "Overlay image: $OVERLAY_IMAGE"
echo "Output: $OUTPUT_VIDEO"
echo "Position: $POSITION"
[ -n "$SCALE" ] && echo "Scale: $SCALE"
echo "Opacity: $OPACITY"
[ "$FADE" = true ] && echo "Fade: Start at ${FADE_START}s, Duration: ${FADE_DURATION}s"

# Calculate position coordinates
case $POSITION in
"center")
  OVERLAY_POS="(main_w-overlay_w)/2:(main_h-overlay_h)/2"
  ;;
"top-left")
  OVERLAY_POS="0:0"
  ;;
"top-right")
  OVERLAY_POS="main_w-overlay_w:0"
  ;;
"bottom-left")
  OVERLAY_POS="0:main_h-overlay_h"
  ;;
"bottom-right")
  OVERLAY_POS="main_w-overlay_w:main_h-overlay_h"
  ;;
custom,*)
  CUSTOM_POS=${POSITION#custom,}
  OVERLAY_POS="$CUSTOM_POS"
  ;;
esac

# Build filter complex
FILTER_COMPLEX="[1:v]format=rgba"

# Add scaling if specified
if [ -n "$SCALE" ]; then
  FILTER_COMPLEX="$FILTER_COMPLEX,scale=$SCALE[overlay_scaled]"
  OVERLAY_INPUT="[overlay_scaled]"
else
  FILTER_COMPLEX="$FILTER_COMPLEX[overlay_base]"
  OVERLAY_INPUT="[overlay_base]"
fi

# Add fade effect if enabled
if [ "$FADE" = true ]; then
  FILTER_COMPLEX="$FILTER_COMPLEX;$OVERLAY_INPUT fade=in:st=${FADE_START}:d=${FADE_DURATION}:alpha=1[overlay_final]"
  OVERLAY_INPUT="[overlay_final]"
elif [ "$OPACITY" != "1.0" ]; then
  FILTER_COMPLEX="$FILTER_COMPLEX;$OVERLAY_INPUT colorchannelmixer=aa=$OPACITY[overlay_final]"
  OVERLAY_INPUT="[overlay_final]"
fi

# Add overlay
FILTER_COMPLEX="$FILTER_COMPLEX;[0:v]$OVERLAY_INPUT overlay=$OVERLAY_POS"

# Run ffmpeg command
echo "Running FFmpeg command..."
ffmpeg -i "$INPUT_VIDEO" -i "$OVERLAY_IMAGE" -filter_complex "$FILTER_COMPLEX" -c:a copy "$OUTPUT_VIDEO"

if [ $? -eq 0 ]; then
  echo "Success! Video with overlay created: $OUTPUT_VIDEO"
else
  echo "Error: FFmpeg command failed!"
  exit 1
fi
