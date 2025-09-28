#!/bin/bash
# XYPACK animated banner script

# Color definitions from XYPACK template
COLOR_LIGHT_BLUE="\033[94m"
COLOR_CYAN="\033[96m"
COLOR_MAGENTA="\033[95m"
COLOR_PURPLE="\033[35m"
COLOR_GREEN="\033[32m"
COLOR_LIGHT_GRAY="\033[37m"
COLOR_RESET="\033[0m"

# Read XYPACK banner from xy_pack.txt
BANNER=$(cat xy_pack.txt)

# Function to clear screen and print banner with specified color
print_banner() {
    local color="$1"
    clear
    printf "${color}%s${COLOR_RESET}\n" "$BANNER"
}

# Function to handle cleanup on exit
cleanup() {
    printf "${COLOR_RESET}"
    clear
    echo "XYPACK banner stopped."
    exit 0
}

# Set up signal handlers for clean exit
trap cleanup SIGINT SIGTERM

# Main animation loop
echo "XYPACK animated banner started. Press Ctrl+C to exit."
echo

# Color cycle array
colors=("$COLOR_LIGHT_BLUE" "$COLOR_GREEN" "$COLOR_PURPLE" "$COLOR_CYAN" "$COLOR_MAGENTA" "$COLOR_LIGHT_GRAY")
color_index=0

while true; do
    print_banner "${colors[$color_index]}"
    sleep 1.0

    # Cycle to next color
    color_index=$(((color_index + 1) % ${#colors[@]}))
done