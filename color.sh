#!/bin/bash

# Function to display a color with different styles
show_color_combinations() {
    local rows_per_page=10   # Number of rows before pausing
    local counter=0

    for style in 0 1 4; do     # Normal, Bold, Underline
        for fg_color in {30..37}; do  # Foreground colors
            for bg_color in {40..47}; do  # Background colors
                # Display the combination
                echo -ne "\033[${style};${fg_color};${bg_color}m Style: ${style} | FG: ${fg_color} | BG: ${bg_color} \033[0m   "
            done
            echo  # New line after each set of background colors
            counter=$((counter+1))

            # Pause every few rows to avoid overflow
            if (( counter % rows_per_page == 0 )); then
                read -p "Press Enter to see more..."
            fi
        done
    done
}

# Display the color sheet
echo "Displaying Color Sheet with different combinations of styles, foreground, and background colors:"
show_color_combinations

echo -e "\n\033[0mColor Sheet End. Resetting terminal styles."
