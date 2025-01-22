#!/bin/bash

# This script adds a new slice to a selected FSD directory using fzf for interactive selection.
# It checks for fzf installation and installs it if not present.

echo "Enter the name of the new slice:"
read slice_name

# Use the current directory as the base search path
base_search_path=$(pwd)

# Check if fzf is installed, and install it if not
if ! command -v fzf &> /dev/null; then
  echo "fzf is not installed. Installing fzf..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update && sudo apt-get install -y fzf
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install fzf
  else
    echo "Unsupported OS. Please install fzf manually."
    exit 1
  fi
fi

# Find all FSD directories in the current directory, ignoring node_modules
fsd_directories=($(find "$base_search_path" -maxdepth 15 -type d  \( -name "node_modules" -prune \)  -o -type d  \( -type d -name "entities" -o -name "features" -o -name "shared" -o -name "pages" -o -name "widgets" -o -name "processes" \) -print))

# Check if any directories were found
if [ ${#fsd_directories[@]} -eq 0 ]; then
  echo "No FSD directories found in $base_search_path."
  exit 1
fi

# Use fzf to choose a directory
echo "Choose a directory to add the slice to:"
selected_dir=$(printf "%s\n" "${fsd_directories[@]}" | fzf --height 10 --border --prompt="Select directory: ")

# Check if a directory was selected
if [ -z "$selected_dir" ]; then
  echo "No directory selected. Exiting."
  exit 1
fi

# Function to create the slice structure
create_slice() {
  local base_dir=$1
  local slice_name=$2

  mkdir -p "$base_dir/$slice_name/ui"
  mkdir -p "$base_dir/$slice_name/api"
  mkdir -p "$base_dir/$slice_name/model"
  
  touch "$base_dir/$slice_name/index.ts"

  touch "$base_dir/$slice_name/ui/index.ts"
  touch "$base_dir/$slice_name/api/index.ts"
  touch "$base_dir/$slice_name/model/slice.ts"
  touch "$base_dir/$slice_name/model/index.ts"

  echo "Slice '$slice_name' created in $base_dir"
}

# Create the slice in the selected directory
create_slice "$selected_dir" "$slice_name"