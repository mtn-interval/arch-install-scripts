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
echo -e "${CC_HEADER}────── Post-installation setup  v1.00 ──────${CC_RESET}"
echo
sleep 1




# Set nano as the default editor
echo -e "${CC_TEXT}Setting nano as the default editor...${CC_RESET}"
export EDITOR=nano
separator




# Enable and start NetworkManager service
echo -e "${CC_TEXT}Enabling and starting NetworkManager service...${CC_RESET}"
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager
separator




# Prompt the user for Wi-Fi SSID and password
echo -e "${CC_TEXT}Please enter your Wi-Fi SSID:${CC_RESET}"
read ssid
echo -e "${CC_TEXT}Please enter your Wi-Fi password:${CC_RESET}"
read -s password  # '-s' hides input for security
echo

# Connect to the Wi-Fi network using the provided SSID and password
echo -e "${CC_TEXT}Connecting to Wi-Fi network...${CC_RESET}"
nmcli device wifi connect "$ssid" password "$password"
separator




# Enable and start NetworkManager service
echo -e "${CC_TEXT}Synchronizing all packages and upgrading system...${CC_RESET}"
sudo pacman -Syu --noconfirm
separator




# Install networking and utility tools
echo -e "${CC_TEXT}Deploying core tools:\n\
- wget\n\
- zip\n\
- unzip\n\
- net-tools\n\
- bash-completion\n\
- git\n\
- base-devel\n\
- ufw${CC_RESET}"
echo
sudo pacman -S --noconfirm wget zip unzip net-tools bash-completion git base-devel ufw
separator




# Install yay
echo -e "${CC_TEXT}Installing yay (AUR helper)...${CC_RESET}"
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay
echo
echo -e "${CC_TEXT}yay installation complete.${CC_RESET}"
separator




# Install and configure Thinkpad tools
echo -e "${CC_TEXT}Deploying Thinkpad tools:${CC_RESET}\n\
- tlp\n\
- smartmontools${CC_RESET}"
echo
sudo pacman -S --noconfirm tlp smartmontools

# Configure tools
echo -e "${CC_TEXT}Configuring TLP...${CC_RESET}"
sudo systemctl enable tlp
sudo systemctl start tlp
echo -e "${CC_TEXT}Configuring storage device health monitoring...${CC_RESET}"
sudo systemctl enable smartd
sudo systemctl start smartd
separator




# Add bash-completion configuration to .bashrc
echo -e "${CC_TEXT}Configuring bash-completion in .bashrc...${CC_RESET}"
if ! grep -q "bash-completion" ~/.bashrc; then
    echo "[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion" >> ~/.bashrc
    echo -e "${CC_TEXT}bash-completion added to .bashrc.${CC_RESET}"
else
    echo -e "${CC_TEXT}bash-completion is already configured in .bashrc.${CC_RESET}"
fi

# Reload .bashrc to apply changes
echo
echo -e "${CC_TEXT}Reloading .bashrc to apply changes...${CC_RESET}"
source ~/.bashrc
separator




# Configure UFW firewall
echo -e "${CC_TEXT}Configuring UFW...${CC_RESET}"
sudo systemctl enable ufw
sudo systemctl start ufw
sudo ufw enable
separator




# List enabled services
echo -e "${CC_TEXT}Listing enabled services:${CC_RESET}"
sudo systemctl list-unit-files --state=enabled

# Prompt the user for services to disable
echo
echo -e "${CC_TEXT}Please enter the names of the services you wish to disable, separated by spaces (or press Enter to skip):${CC_RESET}"
read -a services_to_disable

# Disable the services entered by the user
if [ -n "${services_to_disable[*]}" ]; then
    for service in "${services_to_disable[@]}"; do
        echo -e "${CC_TEXT}Disabling $service...${CC_RESET}"
        sudo systemctl disable "$service"
    done
else
    echo -e "${CC_TEXT}No services were disabled.${CC_RESET}"
fi
separator




# Prompt to clean up the script files
echo -e "${CC_TEXT}Do you want to delete the installation scripts? (y/n)${CC_RESET}"
read -r delete_choice

# If the user chooses 'y' delete the scripts
if [[ "$delete_choice" == "y" ]]; then
    echo -e "${CC_TEXT}Deleting...${CC_RESET}"
    sudo rm -f /root/*--*.sh
    sudo rm -f ~/*--*.sh
    echo -e "${CC_TEXT}Scripts deleted.${CC_RESET}"
else
    echo -e "${CC_TEXT}Scripts were not deleted.${CC_RESET}"
fi
separator




# Remove the lines added to .bash_profile after running
echo -e "${CC_TEXT}Cleaning up.${CC_RESET}"
sed -i '/# Check if 04--post.sh has already run/,/fi/d' ~/.bash_profile

# Remove the marker file too (if you don't need it anymore)
rm ~/.post_install_done
separator




# Run software installation script
if [[ -f 05--soft.sh ]]; then

    # Prompt for user to press Enter to continue or exit
    echo -e "${CC_TEXT}Core system installation complete!${CC_RESET}"
    
    read -p "$(echo -e "${CC_TEXT}Do you wish to continue with the software install script (y/n)? ${CC_RESET}")" choice

    if [[ "$choice" == "y" ]]; then
        echo
        echo -e "${CC_TEXT}Running 05--soft.sh...${CC_RESET}"
        separator
        ./05--soft.sh
    else
        echo
        echo -e "${CC_TEXT}Exiting.${CC_RESET}"
        echo
        exit 0
    fi

else
    echo
    echo -e "${CC_TEXT}File 05--soft.sh not found. Exiting.${CC_RESET}"
    echo
    exit 1
fi