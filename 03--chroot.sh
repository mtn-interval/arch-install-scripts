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
echo -e "${CC_HEADER}────── Configure new system  v0.01 ──────${CC_RESET}"
echo
sleep 1




# Set the timezone to Europe/Lisbon
echo -e "${CC_TEXT}Setting timezone to Europe/Lisbon...${CC_RESET}"
ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime

# Set hardware clock
echo -e "${CC_TEXT}Setting hardware clock...${CC_RESET}"
hwclock --systohc
separator




# Uncomment locales
echo -e "${CC_TEXT}Uncommenting en_US.UTF-8 and pt_PT.UTF-8 in /etc/locale.gen...${CC_RESET}"
sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sed -i '/^#pt_PT.UTF-8 UTF-8/s/^#//' /etc/locale.gen

# Generate locales
echo -e "${CC_TEXT}Generating locales...${CC_RESET}"
locale-gen

# Set locale configuration
echo -e "${CC_TEXT}Setting up /etc/locale.conf...${CC_RESET}"
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
echo -e "${CC_TEXT}Setting up /etc/vconsole.conf...${CC_RESET}"
cat <<EOF > /etc/vconsole.conf
KEYMAP=pt-latin1
EOF
separator




# Set hostname
echo -e "${CC_TEXT}Please enter the hostname:${CC_RESET}"
read hostname
echo
echo -e "${CC_TEXT}Setting up /etc/hostname...${CC_RESET}"
echo "$hostname" > /etc/hostname

# Set up /etc/hosts
echo -e "${CC_TEXT}Setting up /etc/hosts...${CC_RESET}"
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
EOF
separator




# Set root password
echo -e "${CC_TEXT}Setting root password...${CC_RESET}"
passwd
separator




# Install GRUB
echo -e "${CC_TEXT}Installing GRUB...${CC_RESET}"
pacman -S --noconfirm grub

# Install GRUB to /dev/sda
echo -e "${CC_TEXT}Installing GRUB to /dev/sda...${CC_RESET}"
grub-install --target=i386-pc /dev/sda

# Generate GRUB configuration
echo -e "${CC_TEXT}Generating GRUB configuration...${CC_RESET}"
grub-mkconfig -o /boot/grub/grub.cfg
separator

# Exit chroot
echo -e "${CC_TEXT}Exiting chroot...${CC_RESET}"
exit