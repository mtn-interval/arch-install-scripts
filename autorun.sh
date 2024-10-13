#!/bin/bash

# Color codes for uutput
CC_HEADER='\033[1;31;45m'   # Bold Red on Magenta background - To mark sections or major steps in the script.
CC_TEXT='\033[1;31;40m'     # Bold Red on Black background - For general text, prompts, and success messages.
CC_RESET='\033[0m'          # Reset Color - To reset color coding.



# Function to pause the script
pause() {
    sleep 0.3
}



# Define text separator style
separator() {
	echo -e "${CC_TEXT}┌───${CC_RESET}"
	pause
	echo -e "${CC_TEXT}│${CC_RESET}"
	pause
	echo -e "${CC_TEXT}│${CC_RESET}"
	pause
	echo -e "${CC_TEXT}│${CC_RESET}"
	pause
	echo -e "${CC_TEXT}¦${CC_RESET}"
	pause
}



# Clear screen
clear



# Script header
echo -e "${CC_HEADER}────── Arch Linux Install Script  v0.05 ──────${CC_RESET}"
echo
sleep 1



# Load keyboard layout
echo -e "${CC_TEXT}Loading portuguese keyboard layout.${CC_RESET}"
loadkeys pt-latin1
separator



# Function to configure network
configure_network() {
    while true; do
        echo -e "${CC_TEXT}1. Wired${CC_RESET}"
        echo -e "${CC_TEXT}2. Wireless${CC_RESET}"
        read -p "$(echo -e "${CC_TEXT}Choose your connection type: ${CC_RESET}")" connection_type

        if [[ "$connection_type" == "1" ]]; then
            echo -e "${CC_TEXT}You have chosen a wired connection. Skipping wi-fi setup...${CC_RESET}"
            break
        elif [[ "$connection_type" == "2" ]]; then
            echo -e "${CC_TEXT}You have chosen a wireless connection. Starting wi-fi setup...${CC_RESET}"

            # Prompt for SSID and connect using iwctl
            echo
            echo -e "${CC_TEXT}Connecting to wi-fi.${CC_RESET}"
            read -p "$(echo -e "${CC_TEXT}Please enter your wi-fi SSID: ${CC_RESET}")" ssid
            read -sp "$(echo -e "${CC_TEXT}Please enter the wi-fi password: ${CC_RESET}")" wifi_password
            iwctl station wlan0 connect "$ssid" --passphrase "$wifi_password"
            if [ $? -eq 0 ]; then
            	echo
                echo -e "${CC_TEXT}Connected to wi-fi successfully.${CC_RESET}"
                break
            else
                echo -e "${CC_TEXT}Failed to connect to wi-fi. Please check the SSID and try again.${CC_RESET}"
                echo
            fi
        else
            echo -e "${CC_TEXT}Invalid option.${CC_RESET}"
            echo
        fi
    done
    separator
}

# Call network configuration
configure_network



# Confirm internet connection
check_internet() {
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
        read -p "$(echo -e "${CC_TEXT}No connection detected. Would you like to reconfigure the network? (y/n): ${CC_RESET}")" retry_option
        case $retry_option in
            y|Y)
                echo
                echo -e "${CC_TEXT}Reconfiguring network...${CC_RESET}"
                echo
                configure_network
                ;;
            n|N)
                echo
                echo -e "${CC_TEXT}Exiting...${CC_RESET}"
                echo
                exit 1
                ;;
            *)
                echo
                echo -e "${CC_TEXT}Please enter 'y' or 'n'.${CC_RESET}"
                echo
                ;;
        esac
        # Re-check internet connection after reconfiguration
        if check_internet; then
            break
        fi
    done
fi
separator



# Ensure packages are up to date
echo -e "${CC_TEXT}Checking if system packages need an update...${CC_RESET}"
pacman -Sy --noconfirm
separator



# Install necessary packages
echo -e "${CC_TEXT}Installing wget if not installed...${CC_RESET}"
pacman -S --noconfirm wget
separator



# Download the pre-install script
echo -e "${CC_TEXT}Downloading the pre-install script...${CC_RESET}"
while true; do
    wget --no-cache https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/pre-install.sh
    if [ $? -eq 0 ]; then
        echo -e "${CC_TEXT}Download successful.${CC_RESET}"
        break  # Break the loop if the download is successful
    else
        echo -e "${CC_TEXT}Failed to download the pre-install script.${CC_RESET}"
        while true; do
            read -p "$(echo -e "${CC_TEXT}Would you like to try downloading again? (y/n): ${CC_RESET}")" retry_option
            case $retry_option in
                y|Y)
                    echo
                    echo -e "${CC_TEXT}Retrying download...${CC_RESET}"
                    break  # Break the inner loop to retry the download
                    ;;
                n|N)
                    echo
                    echo -e "${CC_TEXT}Exiting...${CC_RESET}"
                    echo
                    exit 1
                    ;;
                *)
                    echo
                    echo -e "${CC_TEXT}Please enter 'y' or 'n'.${CC_RESET}"
                    ;;
            esac
        done
    fi
done
separator



# Make the script executable
echo -e "${CC_TEXT}Making the pre-install script executable...${CC_RESET}"
chmod +x pre-install.sh
separator


# Run pre-install
if [[ -f pre-install.sh ]]; then

    # Prompt for user to press Enter to continue
    echo -e "${CC_TEXT}The system is ready to proceed.${CC_RESET}"
    read -p "$(echo -e "${CC_TEXT}Press Enter to continue with running pre-install.sh...${CC_RESET}")"
    
    echo
    echo -e "${CC_TEXT}Running pre-install.sh...${CC_RESET}"
    separator
    ./pre-install.sh
else
	echo
    echo -e "${CC_TEXT}pre-install.sh not found. Exiting...${CC_RESET}"
    echo
    exit 1
fi