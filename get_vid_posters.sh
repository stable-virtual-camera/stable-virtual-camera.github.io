#!/bin/bash

# Ensure an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Iterate over all sample.mp4 files in assets/trajectory/*
for vid in $(find "$1" -name *.mp4); do
    # Get the folder of this video
    folder=$(dirname "$vid")
    # Get the name of this video
    vid_name=$(basename "$vid")
    # Get the name of the poster image
    poster_name="${vid_name%.*}.jpg"
    # Get the path of the poster image
    poster_path="$folder/$poster_name"
    # Check if the poster image already exists
    if [ -f "$poster_path" ]; then
        continue
    fi
    # Get the path of the first frame of this video
    first_frame_path="$folder/first_frame.jpg"
    # Extract the first frame as a temporary file
    ffmpeg -i "$vid" -vf "select=eq(n\,0)" -q:v 3 "$first_frame_path"
    # Rename the first frame as the poster image
    mv "$first_frame_path" "$poster_path"
done

# Iterate over all .mp4 files in the given directory
# for vid in "$1"/*.mp4; do
#     # Skip if no .mp4 files exist
#     [ -e "$vid" ] || continue
#     # Get the folder of this video
#     folder=$(dirname "$vid")
#     # Get the name of this video
#     vid_name=$(basename "$vid")
#     # Define the name and path of the poster image
#     poster_name="${vid_name%.*}.jpg"
#     poster_path="$folder/$poster_name"
#     # Check if the poster image already exists
#     if [ -f "$poster_path" ]; then
#         continue
#     fi
#     # Extract the first frame and rename it as the poster image
#     first_frame_path="$folder/first_frame.jpg"
#     ffmpeg -i "$vid" -vf "select=eq(n\,0)" -q:v 3 "$first_frame_path"
#     mv "$first_frame_path" "$poster_path"
# done