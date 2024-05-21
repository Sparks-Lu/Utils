#!/bin/bash
target_dir="$1"
if [ -z "$target_dir" ]; then
    echo "Usage: $0 <target_directory>"
    exit 1
fi

tmp_dir=$(mktemp -d)

for entry in "$target_dir"/*; do
    if [[ -d "$entry" ]]; then
        echo "Sub-folder: $entry"
        rm -f $tmp_dir/files_with_numbers.txt
        find "$entry" -type f -name "*part*.mp4" | while read -r file; do
            num=$(basename "$file" | sed 's/*part\([0-9]*\)\.mp4/\1/')
            echo "$file $num" >> "$tmp_dir/files_with_numbers.txt"
        done
        sort -k 2n "$tmp_dir/files_with_numbers.txt" > "$tmp_dir/sorted_files.txt"

        output_file="$entry/voice_txt.mp4"
        rm -f "$output_file"
        rm -f $tmp_dir/concat_list.txt
        while IFS=' ' read -r file num; do
            if [ -f "$file" ]; then
                if [ ! -f "$tmp_dir/concat_list.txt" ]; then
                    echo "file '$file'" > "$tmp_dir/concat_list.txt"
                else
                    echo "file '$file'" >> "$tmp_dir/concat_list.txt"
                fi
            fi
        done < "$tmp_dir/sorted_files.txt"

        ffmpeg -loglevel error -f concat -safe 0 -i "$tmp_dir/concat_list.txt" -c copy "$output_file"
    fi
done

# rm -rf "$tmp_dir"
echo "Video files have been merged into $OUTPUT_FILE"
