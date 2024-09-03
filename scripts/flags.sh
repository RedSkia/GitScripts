#!/bin/bash

# Initialize flags
flag_i=false
flag_u=false
flag_r=false
flag_o=false
path_d=""

# Read user input
echo "Enter flags (e.g., -i -d \"/path with spaces\" -u -o or -d path/path/path):"
read -r input

# Convert the input string into an array using eval and read
eval set -- $input

# Parse flags and options manually
while [[ $# -gt 0 ]]; do
  case "$1" in
    -i) flag_i=true ;;
    -u) flag_u=true ;;
    -r) flag_r=true ;;
    -o) flag_o=true ;;
    -d) 
      shift 
      path_d="$1"
      ;;
    *) echo "Invalid option: $1" ;;
  esac
  shift
done

# Output the values
echo "Flag -i: $flag_i"
echo "Flag -u: $flag_u"
echo "Flag -r: $flag_r"
echo "Flag -o: $flag_o"
echo "Flag -d: $path_d"