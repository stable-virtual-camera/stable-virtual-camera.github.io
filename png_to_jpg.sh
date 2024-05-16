#!/bin/bash

# Check if folder/file argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <folder_path/file_path>"
    exit 1
fi




# Check for available conversion tools
if command -v sips &> /dev/null; then
    CONVERTER="sips"
elif command -v ffmpeg &> /dev/null; then
    CONVERTER="ffmpeg"
elif command -v convert &> /dev/null; then
    CONVERTER="convert"
else
    echo "Error: No suitable conversion tool found. Please install either:"
    echo "- sips (comes pre-installed on macOS)"
    echo "- ffmpeg"
    echo "- ImageMagick"
    exit 1
fi

# Initialize a counter for converted files
count=0

file_list=()

# Check if the argument is a file
if [ -f "$1" ]; then
    file_list+=("$1")
else
    # Add debugging to see exactly what we're getting
    echo "Searching in directory: $1"
    while IFS= read -r -d '' file; do
        echo "Found file: '$file'"  # Debug line to show exact file path
        # Sanitize the path by removing any potential problematic characters
        clean_file=$(echo "$file" | tr -cd '[:print:]/')
        file_list+=("$clean_file")
    done < <(find "$1" -type f -name "*.png" -print0)
fi

# Find all PNG files recursively in the specified folder and convert them to JPG
while IFS= read -r -d '' file; do
    # Verify file exists before processing
    if [ ! -f "$file" ]; then
        echo "Warning: File not found: $file"
        continue
    fi

    # Get filename without extension
    filename="${file%.*}"
    
    # Convert PNG to JPG using the available tool
    case $CONVERTER in
        "sips")
            # sips doesn't need background specification - it uses white by default
            sips -s format jpeg "$file" --out "${filename}.jpg" &> /dev/null
            ;;
        "ffmpeg")
            ffmpeg -i "$file" -f image2 -vf "format=rgb24" "${filename}.jpg" -y 2> /dev/null
            ;;
        "convert")
            convert "$file" -background white -flatten "${filename}.jpg"
            ;;
    esac
    
    # Only attempt to remove the original file if both conversion succeeded and file exists
    if [ -f "${filename}.jpg" ] && [ -f "$file" ]; then
        echo "Converted: $file -> ${filename}.jpg"
        rm "$file"
        ((count++))
    else
        echo "Warning: Conversion failed for $file"
    fi
    
done < <(printf '%s\0' "${file_list[@]}")

if [ $count -eq 0 ]; then
    echo "No PNG files found."
else
    echo "Conversion complete! Converted $count files."
fi
