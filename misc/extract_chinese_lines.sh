#!/bin/bash

# Define the folder to process
FOLDER_PATH="$1"

# Check if folder path is provided
if [ -z "$FOLDER_PATH" ]; then
  echo "Usage: $0 <folder_path>"
  exit 1
fi

# Check if the provided path is a valid directory
if [ ! -d "$FOLDER_PATH" ]; then
  echo "Error: '$FOLDER_PATH' is not a valid directory."
  exit 1
fi

# Function to process each file
process_file() {
  local file="$1"
  
  # Use grep to find lines with Chinese characters (Unicode range for CJK characters)
  # Exclude lines that are comments or contain "console.log()"
  grep -Pn "\p{Han}" "$file" | \
    grep -v -E "^\s*\/\/" | \
    grep -v -E "^\s*\/\*" | \
    grep -v -E "^\s*\*" | \
    grep -v -E "console\.log"
}

# Recursively go through all files in the folder
find "$FOLDER_PATH" -type f | while read -r file; do
  echo "Processing file: $file"
  process_file "$file"
done
