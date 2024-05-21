#!/bin/bash  
  
folder_path=$1
output_file="output.txt"
  
find "$folder_path" -type f -exec stat -c "%n %s" {} + > $output_file
  
echo "Files and sizes have been dumped to $output_file"
