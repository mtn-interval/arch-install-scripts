#!/bin/bash

# Define a color variable for echo messages
COLOR="\033[1;34m"  # Blue
RESET="\033[0m"      # Reset to default

echo -e "\n${COLOR}Starting post-installation setup...${RESET}\n"
sleep 1

# Enable and start NetworkManager service
echo -e "\n${COLOR}Enabling and starting NetworkManager service...${RESET}\n"
sleep 1
systemctl enable NetworkManager
systemctl start NetworkManager

# Prompt the user for Wi-Fi SSID and password
echo -e "\n${COLOR}Please enter your Wi-Fi SSID:${RESET}\n"
sleep 1
read ssid

echo -e "\n${COLOR}Please enter your Wi-Fi password:${RESET}\n"
sleep 1
read -s password  # '-s' hides input for security

# Connect to the Wi-Fi network using the provided SSID and password
echo -e "\n${COLOR}Connecting to Wi-Fi network...${RESET}\n"
sleep 1
nmcli device wifi connect "$ssid" password "$password"

# Prompt the user for a new username
echo -e "\n${COLOR}Please enter the username for the new user:${RESET}\n"
sleep 1
read username

# Create the new user and prompt for password
echo -e "\n${COLOR}Creating user $username...${RESET}\n"
sleep 1
useradd -m -G wheel -s /bin/bash "$username"

echo -e "\n${COLOR}Setting password for $username...${RESET}\n"
sleep 1
passwd "$username"

# Set nano as the default editor
echo -e "\n${COLOR}Setting nano as the default editor...${RESET}\n"
export EDITOR=nano

# Install sudo
echo -e "\n${COLOR}Installing sudo...${RESET}\n"
sleep 1
pacman -S --noconfirm sudo

# Grant sudo privileges to the wheel group
echo -e "\n${COLOR}Configuring sudoers file to allow wheel group...${RESET}\n"
sleep 1
sed -i 's/^#\s*%wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Install networking and utility tools
echo -e "\n${COLOR}Installing git, wget, zip, unzip, net-tools...${RESET}\n"
sleep 1
pacman -S --noconfirm git wget zip unzip net-tools

# Install and configure TLP for power management
echo -e "\n${COLOR}Installing and configuring TLP...${RESET}\n"
sleep 1
pacman -S --noconfirm tlp
systemctl enable tlp
systemctl start tlp

# Install and configure tp_smapi and smartmontools for ThinkPad power management
echo -e "\n${COLOR}Installing tp_smapi and smartmontools...${RESET}\n"
sleep 1
pacman -S --noconfirm tp_smapi smartmontools
modprobe tp_smapi
echo "tp_smapi" > /etc/modules-load.d/tp_smapi.conf
systemctl enable smartd
systemctl start smartd

# Install and configure UFW firewall
echo -e "\n${COLOR}Installing and configuring UFW...${RESET}\n"
sleep 1
pacman -S --noconfirm ufw
systemctl enable ufw
systemctl start ufw
ufw enable

# Install Glances for system monitoring
echo -e "\n${COLOR}Installing Glances...${RESET}\n"
sleep 1
pacman -S --noconfirm glances

# List enabled services
echo -e "\n${COLOR}Listing enabled services...${RESET}\n"
sleep 1
systemctl list-unit-files --state=enabled

# Prompt the user for services to disable
echo -e "\n${COLOR}Please enter the names of the services you wish to disable, separated by spaces (or press Enter to skip):${RESET}\n"
sleep 1
read -a services_to_disable

# Disable the services entered by the user
if [ -n "${services_to_disable[*]}" ]; then
    for service in "${services_to_disable[@]}"; do
        echo -e "\n${COLOR}Disabling $service...${RESET}\n"
        systemctl disable "$service"
    done
else
    echo -e "\n${COLOR}No services were disabled.${RESET}\n"
fi

# Update the system
echo -e "\n${COLOR}Updating the system...${RESET}\n"
sleep 1
pacman -Syu --noconfirm

# Prompt to clean up the script files
echo -e "\n${COLOR}Do you want to delete the installation scripts (install.sh, post-install.sh, and chroot-install.sh)? [y/N]${RESET}\n"
sleep 1
read -r delete_choice

# If the user chooses 'y' or 'Y', delete the scripts
if [[ "$delete_choice" == "y" || "$delete_choice" == "Y" ]]; then
    echo -e "\n${COLOR}Deleting install.sh, post-install.sh, and chroot-install.sh...${RESET}\n"
    rm -f /root/install.sh /root/post-install.sh /root/chroot-install.sh
    echo -e "\n${COLOR}Scripts deleted.${RESET}\n"
else
    echo -e "\n${COLOR}Scripts were not deleted.${RESET}\n"
fi


echo -e "\n${COLOR}Post-installation setup complete!${RESET}\n"