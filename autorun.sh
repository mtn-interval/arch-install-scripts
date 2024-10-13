#!/bin/bash

# Color Codes for Output
CC_SUCCESS='\033[1;31;40m'  # Bold Red on Black background  - To indicate that an operation was successful.
CC_ERROR='\033[1;31;40m'    # Bold Red on Black background  - To indicate any failure, error, or warning.
CC_NOTE='\033[1;31;40m'     # Bold Red on Black background  - To give general information or highlight something important but not critical.
CC_HEADER='\033[1;31;45m'   # Bold Red on Magenta background- To mark sections or major steps in the script.
CC_PROMPT='\033[1;31;40m'   # Bold Red on Black background  - To ask the user for input or confirmation.
CC_RESET='\033[0m'          # Reset Color - To reset color coding.

# Function to pause the script for 2 seconds
pause() {
    sleep 3
}

clear

echo
echo -e "${CC_HEADER}----- Moutain Interval -----${CC_RESET}"
echo -e "${CC_HEADER}--- Install Script  v1.1 ---${CC_RESET}"
echo
pause

# Load keyboard layout
echo
echo -e "${CC_HEADER}:::${CC_RESET}" 
echo -e "${CC_NOTE}Loading Portuguese keyboard layout.${CC_RESET}"
echo
loadkeys pt-latin1
echo -e "${CC_HEADER}:::${CC_RESET}" 
pause

# Prompt the user for connection type until a valid option is selected
while true; do
    echo
    echo -e "${CC_HEADER}:::${CC_RESET}"
    echo -e "${CC_NOTE}1. Wired${CC_RESET}"
    echo -e "${CC_NOTE}2. Wireless${CC_RESET}"
    read -p "$(echo -e "${CC_PROMPT}Choose your connection type: ${CC_RESET}")" connection_type

    # Handle wired or wireless connection
    if [[ "$connection_type" == "1" ]]; then
        echo
        echo -e "${CC_NOTE}You have chosen a wired connection. Skipping Wi-Fi setup...${CC_RESET}"
        echo
        break
    elif [[ "$connection_type" == "2" ]]; then
        echo
        echo -e "${CC_NOTE}You have chosen a wireless connection. Starting Wi-Fi setup...${CC_RESET}"
        echo

        # Prompt for SSID and connect using iwctl
        echo
        echo -e "${CC_NOTE}Connecting to Wi-Fi.${CC_RESET}"
        echo
        read -p "$(echo -e "${CC_PROMPT}Please enter your Wi-Fi SSID: ${CC_RESET}")" ssid
        read -sp "$(echo -e "${CC_PROMPT}Please enter the Wi-Fi password: ${CC_RESET}")" wifi_password
        echo
        iwctl station wlan0 connect "$ssid" --passphrase "$wifi_password"
        if [ $? -eq 0 ]; then
            echo
            echo -e "${CC_SUCCESS}Connected to Wi-Fi successfully.${CC_RESET}"
            echo
            break
        else
            echo
            echo -e "${CC_ERROR}Failed to connect to Wi-Fi. Please check the SSID and try again.${CC_RESET}"
            echo
            continue  # Loop back if Wi-Fi connection fails
        fi
    else
        echo
        echo -e "${CC_ERROR}Invalid option. Please select 1 for Wired or 2 for Wireless.${CC_RESET}"
        echo
    fi
done
echo -e "${CC_HEADER}:::${CC_RESET}"
pause

# Confirm internet connection
check_internet() {
    echo
    echo -e "${CC_HEADER}:::${CC_RESET}"
    echo -e "${CC_NOTE}Checking internet connection...${CC_RESET}"
    echo
    for site in archlinux.org google.com; do
        if ping -c 1 "$site" &> /dev/null; then
            echo
            echo -e "${CC_SUCCESS}Internet connection confirmed.${CC_RESET}"
            echo
            return 0
        fi
    done
    return 1
}

if ! check_internet; then
    echo
    echo -e "${CC_ERROR}No internet connection detected.${CC_RESET}"
    echo
    while true; do
        echo
        read -p "$(echo -e "${CC_PROMPT}Would you like to retry? (y/n): ${CC_RESET}")" retry_option
        case $retry_option in
            y|R)
                echo
                echo -e "${CC_NOTE}Retrying connection setup...${CC_RESET}"
                echo
                exec "$0"  # Restart the script from the beginning
                ;;
            n|H)
                echo
                echo -e "${CC_ERROR}Halting the process.${CC_RESET}"
                echo
                exit 1
                ;;
            *)
                echo
                echo -e "${CC_ERROR}Please enter 'y' to retry or 'n' to halt.${CC_RESET}"
                echo
                ;;
        esac
    done
fi
echo -e "${CC_HEADER}:::${CC_RESET}"
pause

# Ensure necessary packages are installed
echo
echo -e "${CC_HEADER}:::${CC_RESET}"
echo -e "${CC_HEADER}--- Package Installation ---${CC_RESET}"
echo -e "${CC_NOTE}Checking if system packages need an update...${CC_RESET}"
echo
pacman -Sy --noconfirm

echo
echo -e "${CC_NOTE}Installing wget if not installed...${CC_RESET}"
echo
pacman -S --noconfirm wget
echo -e "${CC_HEADER}:::${CC_RESET}"
pause

# Download the pre-install script
echo
echo -e "${CC_HEADER}:::${CC_RESET}"
echo -e "${CC_NOTE}Downloading the pre-install script...${CC_RESET}"
echo
wget --no-cache https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/pre-install.sh
if [ $? -eq 0 ]; then
    echo
    echo -e "${CC_SUCCESS}Download successful.${CC_RESET}"
    echo
else
    echo
    echo -e "${CC_ERROR}Failed to download the pre-install script.${CC_RESET}"
    echo
    exit 1
fi
echo -e "${CC_HEADER}:::${CC_RESET}"
pause

# Make the script executable and run it
echo
echo -e "${CC_HEADER}:::${CC_RESET}"
echo -e "${CC_NOTE}Making the pre-install script executable...${CC_RESET}"
echo
chmod +x pre-install.sh

if [[ -f pre-install.sh ]]; then
    echo
    echo -e "${CC_NOTE}The system is ready to proceed.${CC_RESET}"
    read -p "$(echo -e "${CC_PROMPT}Do you wish to continue with running pre-install.sh? (y/n): ${CC_RESET}")" continue_pre_install
    if [[ "$continue_pre_install" != "y" ]]; then
        echo
        echo -e "${CC_ERROR}Pre-installation process aborted by user.${CC_RESET}"
        echo
        exit 1
    fi

    echo
    echo -e "${CC_NOTE}Running pre-install.sh...${CC_RESET}"
    echo
    echo -e "${CC_HEADER}:::${CC_RESET}"
    pause
    ./pre-install.sh
else
    echo
    echo -e "${CC_ERROR}pre-install.sh not found. Exiting.${CC_RESET}"
    echo
    exit 1
fi
