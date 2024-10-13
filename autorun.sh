#!/bin/bash

# Color Codes for Output
CC_HEADER='\033[1;31;45m'   # Bold Red on Magenta background - To mark sections or major steps in the script.
CC_TEXT='\033[1;31;45m'     # Bold Red on Black background - For general text, prompts, and success messages.
CC_RESET='\033[0m'          # Reset Color - To reset color coding.

# Function to pause the script
pause() {
    sleep 3
}

# Define text separator style
separator() {
	echo -e "${CC_HEADER}|${CC_RESET}"
}

clear

# Script Header
echo -e "${CC_HEADER}----- Moutain Interval -----${CC_RESET}"
echo -e "${CC_HEADER}--- Install Script  v1.1 ---${CC_RESET}"
pause

# Load keyboard layout
echo -e "${CC_TEXT}Loading Portuguese keyboard layout.${CC_RESET}"
loadkeys pt-latin1
separator
pause

# Prompt the user for connection type until a valid option is selected
separator
while true; do
    echo -e "${CC_TEXT}1. Wired${CC_RESET}"
    echo -e "${CC_TEXT}2. Wireless${CC_RESET}"
    read -p "$(echo -e "${CC_TEXT}Choose your connection type: ${CC_RESET}")" connection_type

    if [[ "$connection_type" == "1" ]]; then
        echo -e "${CC_TEXT}You have chosen a wired connection. Skipping Wi-Fi setup...${CC_RESET}"
        break
    elif [[ "$connection_type" == "2" ]]; then
        echo -e "${CC_TEXT}You have chosen a wireless connection. Starting Wi-Fi setup...${CC_RESET}"

        # Prompt for SSID and connect using iwctl
        echo -e "${CC_TEXT}Connecting to Wi-Fi.${CC_RESET}"
        read -p "$(echo -e "${CC_TEXT}Please enter your Wi-Fi SSID: ${CC_RESET}")" ssid
        read -sp "$(echo -e "${CC_TEXT}Please enter the Wi-Fi password: ${CC_RESET}")" wifi_password
        iwctl station wlan0 connect "$ssid" --passphrase "$wifi_password"
        if [ $? -eq 0 ]; then
            echo -e "${CC_TEXT}Connected to Wi-Fi successfully.${CC_RESET}"
            break
        else
            echo -e "${CC_TEXT}Failed to connect to Wi-Fi. Please check the SSID and try again.${CC_RESET}"
        fi
    else
        echo -e "${CC_TEXT}Invalid option. Please select 1 for Wired or 2 for Wireless.${CC_RESET}"
    fi
done
separator
pause

# Confirm internet connection
check_internet() {
    separator
    echo -e "${CC_TEXT}Checking internet connection...${CC_RESET}"
    for site in archlinux.org google.com; do
        if ping -c 1 "$site" &> /dev/null; then
            echo -e "${CC_TEXT}Internet connection confirmed.${CC_RESET}"
            return 0
        fi
    done
    return 1
}

if ! check_internet; then
    echo -e "${CC_TEXT}No internet connection detected.${CC_RESET}"
    while true; do
        read -p "$(echo -e "${CC_TEXT}Would you like to retry? (y/n): ${CC_RESET}")" retry_option
        case $retry_option in
            y|Y)
                echo -e "${CC_TEXT}Retrying connection setup...${CC_RESET}"
                exec "$0"  # Restart the script
                ;;
            n|N)
                echo -e "${CC_TEXT}Halting the process.${CC_RESET}"
                exit 1
                ;;
            *)
                echo -e "${CC_TEXT}Please enter 'y' to retry or 'n' to halt.${CC_RESET}"
                ;;
        esac
    done
fi
separator
pause

# Ensure necessary packages are installed
separator
echo -e "${CC_HEADER}--- Package Installation ---${CC_RESET}"
echo -e "${CC_TEXT}Checking if system packages need an update...${CC_RESET}"
pacman -Sy --noconfirm

echo -e "${CC_TEXT}Installing wget if not installed...${CC_RESET}"
pacman -S --noconfirm wget
separator
pause

# Download the pre-install script
separator
echo -e "${CC_TEXT}Downloading the pre-install script...${CC_RESET}"
wget --no-cache https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/pre-install.sh
if [ $? -eq 0 ]; then
    echo -e "${CC_TEXT}Download successful.${CC_RESET}"
else
    echo -e "${CC_TEXT}Failed to download the pre-install script.${CC_RESET}"
    exit 1
fi
separator
pause

# Make the script executable and run it
separator
echo -e "${CC_TEXT}Making the pre-install script executable...${CC_RESET}"
chmod +x pre-install.sh

if [[ -f pre-install.sh ]]; then
    echo -e "${CC_TEXT}The system is ready to proceed.${CC_RESET}"
    read -p "$(echo -e "${CC_TEXT}Do you wish to continue with running pre-install.sh? (y/n): ${CC_RESET}")" continue_pre_install
    if [[ "$continue_pre_install" != "y" ]]; then
        echo -e "${CC_TEXT}Pre-installation process aborted by user.${CC_RESET}"
        exit 1
    fi

    echo -e "${CC_TEXT}Running pre-install.sh...${CC_RESET}"
    separator
    pause
    ./pre-install.sh
else
    echo -e "${CC_TEXT}pre-install.sh not found. Exiting.${CC_RESET}"
    exit 1
fi
