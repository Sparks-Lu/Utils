#!/bin/bash

set -euo pipefail

VENV_PYTHON="$HOME/system/virtualenvs/py3.12/bin/python3"

usage() {
    echo "Usage: $0 <input.webp|input_directory> [fps] [crf]"
    echo ""
    echo "Convert animated WebP to MP4 video."
    echo ""
    echo "Arguments:"
    echo "  input          A single .webp file or a directory of .webp files"
    echo "  fps            Frame rate (default: 10)"
    echo "  crf            Quality, lower is better, 18-28 range (default: 23)"
    echo ""
    echo "Examples:"
    echo "  $0 animation.webp"
    echo "  $0 animation.webp 15"
    echo "  $0 animation.webp 10 18"
    echo "  $0 ./webp_directory"
    exit 0
}

check_deps() {
    local errors=0
    if ! command -v ffmpeg &>/dev/null; then
        echo "Error: ffmpeg not found. Install it first."
        errors=1
    fi
    if ! "$VENV_PYTHON" -c "import webp" 2>/dev/null; then
        echo "Error: Python 'webp' module not found in $VENV_PYTHON. Run: pip install webp"
        errors=1
    fi
    if [ "$errors" -ne 0 ]; then
        exit 1
    fi
}

extract_frame_count() {
    local input="$1"
    "$VENV_PYTHON" -c "
import webp, sys
frames = webp.load_images('$input')
if len(frames) <= 1:
    sys.exit(1)
" 2>/dev/null
}

webp2mp4() {
    local input="$1"
    local fps="${2:-10}"
    local crf="${3:-23}"
    local base
    base=$(basename "$input" .webp)
    local dir
    dir=$(dirname "$input")
    local output="${dir}/${base}.mp4"

    if [ ! -f "$input" ]; then
        echo "Error: File not found: $input"
        return 1
    fi

    if [[ "$input" != *.webp ]]; then
        echo "Skipping non-webp file: $input"
        return 1
    fi

    if ! extract_frame_count "$input"; then
        echo "Skipping non-animated webp: $input"
        return 1
    fi

    local tmpdir
    tmpdir=$(mktemp -d)
    trap "rm -rf '$tmpdir'" EXIT

    echo "Extracting frames from $input ..."
    "$VENV_PYTHON" -c "
import os, webp
frames = webp.load_images('$input')
for i, f in enumerate(frames):
    f.save(os.path.join('$tmpdir', f'frame_{i:04d}.png'))
" 2>&1

    local frame_count
    frame_count=$(find "$tmpdir" -name "frame_*.png" | wc -l)
    if [ "$frame_count" -eq 0 ]; then
        echo "Error: No frames extracted from $input"
        return 1
    fi

    echo "Encoding ${frame_count} frames at ${fps} fps (crf=${crf}) -> ${output} ..."
    ffmpeg -y -framerate "$fps" -i "${tmpdir}/frame_%04d.png" \
        -c:v libx264 -pix_fmt yuv420p -crf "$crf" -movflags +faststart \
        -v quiet -stats "$output"

    echo "Done: $output"
}

# --- Main ---
if [ $# -lt 1 ]; then
    usage
fi

case "$1" in
    -h|--help) usage ;;
esac

check_deps

fps="${2:-10}"
crf="${3:-23}"

if [ -f "$1" ]; then
    webp2mp4 "$1" "$fps" "$crf"
elif [ -d "$1" ]; then
    shopt -s nullglob
    webp_files=("$1"/*.webp)
    if [ ${#webp_files[@]} -eq 0 ]; then
        echo "No .webp files found in $1"
        exit 1
    fi
    for f in "${webp_files[@]}"; do
        webp2mp4 "$f" "$fps" "$crf"
    done
else
    echo "Error: $1 is not a valid file or directory."
    exit 1
fi
