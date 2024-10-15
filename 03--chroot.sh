#!/bin/bash

# Define a color variable for echo messages
COLOR="\033[1;34m"  # Blue
RESET="\033[0m"      # Reset to default

# Set the timezone to Europe/Lisbon
echo -e "\n${COLOR}Setting timezone to Europe/Lisbon...${RESET}\n"
sleep 1
ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime

# Set hardware clock
echo -e "\n${COLOR}Setting hardware clock...${RESET}\n"
sleep 1
hwclock --systohc

# Uncomment locales
echo -e "\n${COLOR}Uncommenting en_US.UTF-8 and pt_PT.UTF-8 in /etc/locale.gen...${RESET}\n"
sleep 1
sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sed -i '/^#pt_PT.UTF-8 UTF-8/s/^#//' /etc/locale.gen

# Generate locales
echo -e "\n${COLOR}Generating locales...${RESET}\n"
sleep 1
locale-gen

# Set locale configuration
echo -e "\n${COLOR}Setting up /etc/locale.conf...${RESET}\n"
sleep 1
cat <<EOF > /etc/locale.conf
LANG=en_US.UTF-8
LC_COLLATE=pt_PT.UTF-8
LC_CTYPE=pt_PT.UTF-8
LC_TIME=pt_PT.UTF-8
LC_NUMERIC=pt_PT.UTF-8
LC_MONETARY=pt_PT.UTF-8
LC_PAPER=pt_PT.UTF-8
LC_NAME=pt_PT.UTF-8
LC_ADDRESS=pt_PT.UTF-8
LC_TELEPHONE=pt_PT.UTF-8
LC_MEASUREMENT=pt_PT.UTF-8
LC_IDENTIFICATION=pt_PT.UTF-8
EOF

# Set vconsole configuration
echo -e "\n${COLOR}Setting up /etc/vconsole.conf...${RESET}\n"
sleep 1
cat <<EOF > /etc/vconsole.conf
KEYMAP=pt-latin1
EOF

# Set hostname
echo -e "\n${COLOR}Please enter the hostname:${RESET}\n"
sleep 1
read hostname
echo -e "\n${COLOR}Setting up /etc/hostname...${RESET}\n"
sleep 1
echo "$hostname" > /etc/hostname

# Set up /etc/hosts
echo -e "\n${COLOR}Setting up /etc/hosts...${RESET}\n"
sleep 1
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
EOF

# Set root password
echo -e "\n${COLOR}Setting root password...${RESET}\n"
sleep 1
passwd

# Install GRUB
echo -e "\n${COLOR}Installing GRUB...${RESET}\n"
sleep 1
pacman -S --noconfirm grub

# Install GRUB to /dev/sda
echo -e "\n${COLOR}Installing GRUB to /dev/sda...${RESET}\n"
sleep 1
grub-install --target=i386-pc /dev/sda

# Generate GRUB configuration
echo -e "\n${COLOR}Generating GRUB configuration...${RESET}\n"
sleep 1
grub-mkconfig -o /boot/grub/grub.cfg

# Exit chroot
echo -e "\n${COLOR}Exiting chroot...${RESET}\n"
sleep 1
exit

# Ensure the script exits the chroot session completely
exit 0
