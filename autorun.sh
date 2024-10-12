#!/bin/bash

# Function to pause the script for 2 seconds
pause() {
    sleep 2
}

echo
echo "=== Arch Linux Install Script ==="
echo "=== by Mountain Interval v1.0 ==="
echo
pause

# Prompt the user for connection type
echo
echo "Choose your connection type"
echo "1. Wired"
echo "2. Wireless"
echo
read -p "Option: " connection_type
pause

# Handle wired or wireless connection
if [ "$connection_type" == "1" ]; then
    echo
    echo "You have chosen a wired connection. Skipping Wi-Fi setup..."
    echo
    pause
elif [ "$connection_type" == "2" ]; then
    echo
    echo "You have chosen a wireless connection. Starting Wi-Fi setup..."
    echo
    pause

    # Prompt for SSID and connect using iwctl
    echo
    echo "Connecting to Wi-Fi"
    echo
    read -p "Please enter your Wi-Fi SSID: " ssid
    read -sp "Please enter the Wi-Fi password: " wifi_password
    echo
    iwctl station wlan0 connect "$ssid" --passphrase "$wifi_password"
    if [ $? -eq 0 ]; then
        echo
        echo "Connected to Wi-Fi successfully."
        echo
    else
        echo
        echo "Failed to connect to Wi-Fi. Please check the SSID and try again."
        echo
        exit 1
    fi
    pause
else
    echo
    echo "Invalid option. Please run the script again and select 1 or 2."
    echo
    exit 1
fi

# Confirm internet connection
check_internet() {
    echo
    echo "Checking internet connection..."
    echo
    for site in archlinux.org google.com; do
        if ping -c 1 "$site" &> /dev/null; then
            echo
            echo "Internet connection confirmed."
            echo
            return 0
        fi
    done
    return 1
}

if ! check_internet; then
    echo
    echo "No internet connection detected."
    echo
    while true; do
        echo
        read -p "Would you like to retry or halt? (r for Retry, h for Halt): " retry_option
        case $retry_option in
            r|R)
                echo
                echo "Retrying connection setup..."
                echo
                exec "$0"  # Restart the script from the beginning
                ;;
            h|H)
                echo
                echo "Halting the process."
                echo
                exit 1
                ;;
            *)
                echo
                echo "Please enter 'r' to retry or 'h' to halt."
                echo
                ;;
        esac
    done
fi
pause

# Ensure necessary packages are installed
echo
echo "=== Package Installation ==="
echo "Checking if system packages need an update..."
echo
pacman -Sy --noconfirm

echo
echo "Installing wget and iwctl if not installed..."
echo
pacman -S --noconfirm wget iwctl
pause

# Download the pre-install script
echo
read -p "Proceed with downloading pre-install script from GitHub? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo
    echo "Download aborted by user."
    echo
    exit 1
fi

echo
echo "Downloading the pre-install script..."
echo
wget https://raw.githubusercontent.com/mtn-interval/arch-install-scripts/main/pre-install.sh
if [ $? -eq 0 ]; then
    echo
    echo "Download successful."
    echo
else
    echo
    echo "Failed to download the pre-install script."
    echo
    exit 1
fi
pause

# Make the script executable and run it
echo
echo "Making the pre-install script executable..."
echo
chmod +x pre-install.sh

if [[ -f pre-install.sh ]]; then
    echo
    echo "Running pre-install.sh..."
    echo
    ./pre-install.sh
else
    echo
    echo "pre-install.sh not found. Exiting."
    echo
    exit 1
fi
pause

# End of script
echo
echo "Install script executed. Exiting..."
echo
pause