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

# Define colors
COLOR_RESET="\033[0m"
COLOR_ENTITIES="\033[31m"  # Red
COLOR_FEATURES="\033[32m"  # Green
COLOR_SHARED="\033[33m"    # Yellow
COLOR_PAGES="\033[34m"     # Blue
COLOR_WIDGETS="\033[35m"   # Magenta
COLOR_PROCESSES="\033[36m" # Cyan

# Find all FSD directories and their subdirectories, ignoring node_modules
fsd_directories=($(find "$base_search_path" -type d \( -name "node_modules" -prune \) -o -type d \( -path "*/entities*" -o -path "*/features*" -o -path "*/shared*" -o -path "*/pages*" -o -path "*/widgets*" -o -path "*/processes*" \) -print))

# Check if any directories were found
if [ ${#fsd_directories[@]} -eq 0 ]; then
  echo "No FSD directories found in $base_search_path."
  exit 1
fi

# Colorize directory names
colorize_directory() {
  local dir_name=$1
  case $dir_name in
    *entities*) echo -e "${COLOR_ENTITIES}$dir_name${COLOR_RESET}" ;;
    *features*) echo -e "${COLOR_FEATURES}$dir_name${COLOR_RESET}" ;;
    *shared*) echo -e "${COLOR_SHARED}$dir_name${COLOR_RESET}" ;;
    *pages*) echo -e "${COLOR_PAGES}$dir_name${COLOR_RESET}" ;;
    *widgets*) echo -e "${COLOR_WIDGETS}$dir_name${COLOR_RESET}" ;;
    *processes*) echo -e "${COLOR_PROCESSES}$dir_name${COLOR_RESET}" ;;
    *) echo "$dir_name" ;;
  esac
}

# Use fzf to choose a directory
echo "Choose a directory to add the slice to:"
selected_dir=$(printf "%s\n" "${fsd_directories[@]}" | while read dir; do colorize_directory "$dir"; done | fzf --ansi --height 20 --border --prompt="Select directory: ")

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

  # Colorize the base directory for the output message
  local colored_base_dir=$(colorize_directory "$base_dir")
  echo -e "Slice '$slice_name' created in $colored_base_dir"
}

# Create the slice in the selected directory
create_slice "$selected_dir" "$slice_name"