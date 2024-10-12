#!/bin/bash

# Define a color variable for echo messages
COLOR="\033[1;34m"  # Blue
RESET="\033[0m"      # Reset to default

# Install Qtile window manager
echo -e "\n${COLOR}Installing Qtile window manager...${RESET}\n"
sleep 1
pacman -S --noconfirm qtile

# Install Xorg server, xinit, and xorg-apps
echo -e "\n${COLOR}Installing Xorg server, xinit, and xorg apps...${RESET}\n"
sleep 1
pacman -S --noconfirm xorg-server xorg-xinit xorg-apps

# Install terminal emulator, compositor, wallpaper manager, and other utilities
echo -e "\n${COLOR}Installing Alacritty, Picom, Nitrogen, and Unclutter...${RESET}\n"
sleep 1
pacman -S --noconfirm alacritty picom nitrogen unclutter

# Configure .xinitrc for Qtile and utilities
echo -e "\n${COLOR}Configuring .xinitrc for Qtile, keyboard layout, and utilities...${RESET}\n"
sleep 1

# Create or overwrite the .xinitrc file
cat <<EOL > ~/.xinitrc
# Disable beep
xset -b

# Set keyboard (in X) to Portuguese layout
setxkbmap -layout pt

# Start compositor for fancy visuals
picom &

# Unclutter - hide the mouse cursor
unclutter --jitter 10 --ignore-scrolling --start-hidden --fork

# Nitrogen for wallpaper
nitrogen --set-zoom-fill ~/images/wallpaper.jpg &

# Start tile window manager (Qtile)
qtile start
EOL

echo -e "\n${COLOR}.xinitrc configured successfully.${RESET}\n"
sleep 1

# Create ~/images directory if it doesn't exist
echo -e "\n${COLOR}Creating ~/images directory...${RESET}\n"
sleep 1
mkdir -p ~/images

# Download wallpaper
echo -e "\n${COLOR}Downloading wallpaper to ~/images...${RESET}\n"
sleep 1
wget -P ~/images https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/wallpaper.jpg

# Confirm the wallpaper download
if [ -f ~/images/wallpaper.jpg ]; then
    echo -e "\n${COLOR}Wallpaper downloaded successfully!${RESET}\n"
else
    echo -e "\n${COLOR}Failed to download wallpaper.${RESET}\n"
fi
