#!/bin/bash

echo "Starting post-installation setup..."

# Enable and start NetworkManager service
echo "Enabling and starting NetworkManager service..."
systemctl enable NetworkManager
systemctl start NetworkManager

# Prompt the user for Wi-Fi SSID and password
echo "Please enter your Wi-Fi SSID:"
read ssid

echo "Please enter your Wi-Fi password:"
read -s password  # '-s' hides input for security

# Connect to the Wi-Fi network using the provided SSID and password
echo "Connecting to Wi-Fi network..."
nmcli device wifi connect "$ssid" password "$password"

# Prompt the user for a new username
echo "Please enter the username for the new user:"
read username

# Create the new user and prompt for password
echo "Creating user $username..."
useradd -m -G wheel -s /bin/bash "$username"

echo "Setting password for $username..."
passwd "$username"

# Install sudo
echo "Installing sudo..."
pacman -S --noconfirm sudo

# Grant sudo privileges to the wheel group
echo "Configuring sudoers file to allow wheel group..."
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Install networking and utility tools
echo "Installing git, wget, zip, unzip, net-tools..."
pacman -S --noconfirm git wget zip unzip net-tools

# Install and configure TLP for power management
echo "Installing and configuring TLP..."
pacman -S --noconfirm tlp
systemctl enable tlp
systemctl start tlp

# Install and configure tp_smapi and smartmontools for ThinkPad power management
echo "Installing tp_smapi and smartmontools..."
pacman -S --noconfirm tp_smapi smartmontools
modprobe tp_smapi
echo "tp_smapi" > /etc/modules-load.d/tp_smapi.conf
systemctl enable smartd
systemctl start smartd

# Install and configure UFW firewall
echo "Installing and configuring UFW..."
pacman -S --noconfirm ufw
systemctl enable ufw
systemctl start ufw
ufw enable

# Install Glances for system monitoring
echo "Installing Glances..."
pacman -S --noconfirm glances

# List enabled services
echo "Listing enabled services..."
systemctl list-unit-files --state=enabled

# Prompt the user for services to disable
echo "Please enter the names of the services you wish to disable, separated by spaces (or press Enter to skip):"
read -a services_to_disable

# Disable the services entered by the user
if [ -n "${services_to_disable[*]}" ]; then
    for service in "${services_to_disable[@]}"; do
        echo "Disabling $service..."
        systemctl disable "$service"
    done
else
    echo "No services were disabled."
fi

echo "Updating the system..."
pacman -Syu --noconfirm