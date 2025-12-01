#!/bin/bash

# render_mermaid.sh
# Converts a Mermaid (.mmd) file to PNG using mermaid-cli via npx
# Usage: ./render_mermaid.sh input.mmd [output.png] [width] [height]

set -e # Exit on error

# Default values
DEFAULT_WIDTH=1100
DEFAULT_HEIGHT=700
DEFAULT_BG_COLOR="white"

# Help message
show_help() {
  cat <<EOF
Usage: $0 INPUT.mmd [OUTPUT.png] [WIDTH] [HEIGHT]

Converts a Mermaid diagram file to PNG using @mermaid-js/mermaid-cli.

Arguments:
  INPUT.mmd              Path to input Mermaid (.mmd) file (required)
  OUTPUT.png             Output PNG file (optional, defaults to INPUT.png)
  WIDTH                  Image width in pixels (optional, default: $DEFAULT_WIDTH)
  HEIGHT                 Image height in pixels (optional, default: $DEFAULT_HEIGHT)

Example:
  $0 diagram.mmd
  $0 flow.mmd myflow.png 1200 800
EOF
}

# Check if input file is provided
if [[ $# -lt 1 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

INPUT_FILE="$1"

# Validate input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "❌ Error: Input file '$INPUT_FILE' not found."
  exit 1
fi

# Determine output file
if [[ -n "$2" ]]; then
  OUTPUT_FILE="$2"
else
  # Replace .mmd extension with .png
  OUTPUT_FILE="${INPUT_FILE%.*}.png"
fi

# Set dimensions
WIDTH="${3:-$DEFAULT_WIDTH}"
HEIGHT="${4:-$DEFAULT_HEIGHT}"

# Ensure width and height are numbers
if ! [[ "$WIDTH" =~ ^[0-9]+$ ]] || ! [[ "$HEIGHT" =~ ^[0-9]+$ ]]; then
  echo "❌ Error: Width and height must be positive integers."
  exit 1
fi

echo ".Rendering '$INPUT_FILE' → '$OUTPUT_FILE' (${WIDTH}x${HEIGHT})..."

# Run mermaid-cli via npx
npx -p @mermaid-js/mermaid-cli mmdc \
  -i "$INPUT_FILE" \
  -o "$OUTPUT_FILE" \
  --width "$WIDTH" \
  --height "$HEIGHT" \
  --backgroundColor "$DEFAULT_BG_COLOR"

echo "✅ Success! Output saved to: $OUTPUT_FILE"
