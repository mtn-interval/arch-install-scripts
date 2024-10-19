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
echo -e "${CC_HEADER}────── Post-installation setup  v0.01──────${CC_RESET}"
echo
sleep 1




echo -e "${CC_TEXT}Starting post-installation setup...${CC_RESET}"


# Enable and start NetworkManager service
echo -e "${CC_TEXT}Enabling and starting NetworkManager service...${CC_RESET}"

systemctl enable NetworkManager
systemctl start NetworkManager

# Prompt the user for Wi-Fi SSID and password
echo -e "${CC_TEXT}Please enter your Wi-Fi SSID:${CC_RESET}"

read ssid

echo -e "${CC_TEXT}Please enter your Wi-Fi password:${CC_RESET}"

read -s password  # '-s' hides input for security

# Connect to the Wi-Fi network using the provided SSID and password
echo -e "${CC_TEXT}Connecting to Wi-Fi network...${CC_RESET}"

nmcli device wifi connect "$ssid" password "$password"



# Set nano as the default editor
echo -e "${CC_TEXT}Setting nano as the default editor...${CC_RESET}"
export EDITOR=nano

# Install networking and utility tools
echo -e "${CC_TEXT}Installing git, wget, zip, unzip, net-tools...${CC_RESET}"

sudo pacman -S --noconfirm git wget zip unzip net-tools

# # Install and configure TLP for power management
# echo -e "${CC_TEXT}Installing and configuring TLP...${CC_RESET}"

# pacman -S --noconfirm tlp
# systemctl enable tlp
# systemctl start tlp

# # Install and configure tp_smapi and smartmontools for ThinkPad power management
# echo -e "${CC_TEXT}Installing tp_smapi and smartmontools...${CC_RESET}"

# pacman -S --noconfirm tp_smapi smartmontools
# modprobe tp_smapi
# echo "tp_smapi" > /etc/modules-load.d/tp_smapi.conf
# systemctl enable smartd
# systemctl start smartd

# # Install and configure UFW firewall
# echo -e "${CC_TEXT}Installing and configuring UFW...${CC_RESET}"

# pacman -S --noconfirm ufw
# systemctl enable ufw
# systemctl start ufw
# ufw enable

# # Install Glances for system monitoring
# echo -e "${CC_TEXT}Installing Glances...${CC_RESET}"

# pacman -S --noconfirm glances

# Install bash-completion
echo -e "${CC_TEXT}Installing bash-completion...${CC_RESET}"

sudo pacman -S --noconfirm bash-completion

# Add bash-completion configuration to .bashrc
echo -e "${CC_TEXT}Configuring bash-completion in .bashrc...${CC_RESET}"

if ! grep -q "bash-completion" ~/.bashrc; then
    echo "[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion" >> ~/.bashrc
    echo -e "${CC_TEXT}bash-completion added to .bashrc.${CC_RESET}"
else
    echo -e "${CC_TEXT}bash-completion is already configured in .bashrc.${CC_RESET}"
fi

# Reload .bashrc to apply changes
echo -e "${CC_TEXT}Reloading .bashrc to apply changes...${CC_RESET}"

source ~/.bashrc

# List enabled services
echo -e "${CC_TEXT}Listing enabled services...${CC_RESET}"

systemctl list-unit-files --state=enabled

# Prompt the user for services to disable
echo -e "${CC_TEXT}Please enter the names of the services you wish to disable, separated by spaces (or press Enter to skip):${CC_RESET}"

read -a services_to_disable

# Disable the services entered by the user
if [ -n "${services_to_disable[*]}" ]; then
    for service in "${services_to_disable[@]}"; do
        echo -e "${CC_TEXT}Disabling $service...${CC_RESET}"
        systemctl disable "$service"
    done
else
    echo -e "${CC_TEXT}No services were disabled.${CC_RESET}"
fi

echo -e "${CC_TEXT}Installing yay (AUR helper)...${CC_RESET}"

# Step 1: Install Git (if not already installed)
sudo pacman -Syu --needed --noconfirm git base-devel

# Step 2: Clone the yay repository from the AUR
git clone https://aur.archlinux.org/yay.git

# Step 3: Build and install yay
cd yay
makepkg -si --noconfirm

# Step 4: Clean up by removing the yay directory
cd ..
rm -rf yay

echo -e "${CC_TEXT}yay installation complete.${CC_RESET}"

# Update the system
echo -e "${CC_TEXT}Updating the system...${CC_RESET}"

yay -Syu --noconfirm

# Prompt to clean up the script files
echo -e "${CC_TEXT}Do you want to delete the installation scripts (install.sh, post-install.sh, and chroot-install.sh)? [y/N]${CC_RESET}"

read -r delete_choice

# If the user chooses 'y' or 'Y', delete the scripts
if [[ "$delete_choice" == "y" || "$delete_choice" == "Y" ]]; then
    echo -e "${CC_TEXT}Deleting install.sh, post-install.sh, chroot-install.sh, and windowmanager.sh ...${CC_RESET}"
    rm -f /root/install.sh /root/post-install.sh /root/chroot-install.sh /root/windowmanager.sh
    echo -e "${CC_TEXT}Scripts deleted.${CC_RESET}"
else
    echo -e "${CC_TEXT}Scripts were not deleted.${CC_RESET}"
fi


echo -e "${CC_TEXT}Post-installation setup complete!${CC_RESET}"