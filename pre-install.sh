#!/bin/bash

# Define a color variable for echo messages
COLOR="\033[1;34m"  # Blue
RESET="\033[0m"      # Reset to default

# Load Portuguese keyboard layout
echo -e "\n${COLOR}Loading Portuguese keyboard layout...${RESET}\n"
sleep 1
loadkeys pt-latin1

# Connect to Wi-Fi using iwctl and prompt for SSID
echo -e "\n${COLOR}Starting iwctl to connect to Wi-Fi...${RESET}\n"
sleep 1
echo -e "\n${COLOR}Please enter your Wi-Fi SSID:${RESET}\n"
read ssid
iwctl station wlan0 connect "$ssid"

# Update package database and install wget
echo -e "\n${COLOR}Synchronizing package database and installing wget...${RESET}\n"
sleep 1
pacman -Sy --noconfirm wget

# Download installation scripts from GitHub
echo -e "\n${COLOR}Downloading installation scripts...${RESET}\n"
sleep 1
wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/install.sh
wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/chroot-install.sh
wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/post-install.sh
wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/windowmanager.sh

# Make the downloaded scripts executable
echo -e "\n${COLOR}Making the scripts executable...${RESET}\n"
sleep 1
chmod +x install.sh chroot-install.sh post-install.sh windowmanager.sh

# Run install.sh
echo -e "\n${COLOR}Running the installation script (install.sh)...${RESET}\n"
sleep 1
./install.sh
