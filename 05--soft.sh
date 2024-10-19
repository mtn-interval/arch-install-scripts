#!/bin/bash

# Automation script by Mountain Interval

# CC_TEXT codes for output
CC_HEADER='\033[1;35;44m'   # Bold Magenta on Blue background - To mark sections or major steps in the script.
CC_TEXT='\033[1;34;40m'     # Bold Blue on Black background - For general text, prompts, and success messages.
CC_RESET='\033[0m'          # Reset CC_TEXT - To reset color coding.




# Function to pause the script
pause() {
    sleep 0.2
}




# Define text separator style
separator() {
    echo -e "${CC_TEXT}│${CC_RESET}"
    pause
    echo -e "${CC_TEXT}│${CC_RESET}"
    pause
    echo -e "${CC_TEXT}│${CC_RESET}"
    pause
}




# Script header
echo -e "${CC_HEADER}────── Deploy software  v0.01 ──────${CC_RESET}"
echo
sleep 1




# Define a color variable for echo messages
COLOR="\033[1;34m"  # Blue
RESET="\033[0m"      # Reset to default




# Install Qtile window manager
echo -e "${CC_TEXT}Installing Qtile window manager...${CC_RESET}"
pacman -S --noconfirm qtile
separator




# Install Xorg server, xinit, and xorg-apps
echo -e "${CC_TEXT}Installing Xorg server, xinit, and xorg apps...${CC_RESET}"
pacman -S --noconfirm xorg-server xorg-xinit xorg-apps
separator




# Install terminal emulator, compositor, wallpaper manager, and other utilities
echo -e "${CC_TEXT}Installing Alacritty, Picom, Nitrogen, and Unclutter...${CC_RESET}"
pacman -S --noconfirm alacritty picom nitrogen unclutter
separator




# Configure .xinitrc for Qtile and utilities
echo -e "${CC_TEXT}Configuring .xinitrc for Qtile, keyboard layout, and utilities...${CC_RESET}"

# Create or overwrite the .xinitrc file
cat <<EOL > ~/.xinitrc
# Set keyboard (in X) to Portuguese layout
setxkbmap -layout pt

# Start tile window manager (Qtile)
qtile start
EOL

echo -e "${CC_TEXT}.xinitrc configured successfully.${CC_RESET}"
separator

# # Create or overwrite the .xinitrc file
# cat <<EOL > ~/.xinitrc
# # Disable beep
# xset -b

# # Set keyboard (in X) to Portuguese layout
# setxkbmap -layout pt

# # Start compositor for fancy visuals
# picom &

# # Unclutter - hide the mouse cursor
# unclutter --jitter 10 --ignore-scrolling --start-hidden --fork

# # Nitrogen for wallpaper
# nitrogen --set-zoom-fill ~/images/wallpaper.jpg &

# # Start tile window manager (Qtile)
# qtile start
# EOL

# echo -e "${CC_TEXT}.xinitrc configured successfully.${CC_RESET}"
# separator




# Create ~/images directory if it doesn't exist
echo -e "${CC_TEXT}Creating ~/images directory...${CC_RESET}"
mkdir -p ~/images

# Download wallpaper
echo -e "${CC_TEXT}Downloading wallpaper to ~/images...${CC_RESET}"
sleep 1
wget -P ~/images https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/wallpaper.jpg

# Confirm the wallpaper download
if [ -f ~/images/wallpaper.jpg ]; then
    echo -e "${CC_TEXT}Wallpaper downloaded successfully!${CC_RESET}"
else
    echo -e "${CC_TEXT}Failed to download wallpaper.${CC_RESET}"
fi
echo
exit