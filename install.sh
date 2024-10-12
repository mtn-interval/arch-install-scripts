#!/bin/bash

# Define a color variable for echo messages
COLOR="\033[1;34m"  # Blue
RESET="\033[0m"      # Reset to default

echo -e "\n${COLOR}Loading Portuguese keyboard layout...${RESET}\n"
sleep 1
loadkeys pt-latin1

echo -e "\n${COLOR}Enabling NTP for time synchronization...${RESET}\n"
sleep 1
timedatectl set-ntp true

echo -e "\n${COLOR}Setting the timezone to Europe/Lisbon...${RESET}\n"
sleep 1
timedatectl set-timezone Europe/Lisbon

echo -e "\n${COLOR}Starting automatic partitioning of /dev/sda...${RESET}\n"
sleep 1
(
echo o
echo n
echo p
echo 1
echo
echo
echo a
echo w
) | fdisk /dev/sda

echo -e "\n${COLOR}Formatting /dev/sda1 as EXT4 (root partition)...${RESET}\n"
sleep 1
mkfs.ext4 /dev/sda1

echo -e "\n${COLOR}Mounting /dev/sda1 to /mnt...${RESET}\n"
sleep 1
mount /dev/sda1 /mnt

echo -e "\n${COLOR}Installing base system (base, linux, linux-firmware)...${RESET}\n"
sleep 1
pacstrap -K /mnt base linux linux-firmware --noconfirm

echo -e "\n${COLOR}Installing essential packages (intel-ucode, e2fsprogs, networkmanager, nano, vim)...${RESET}\n"
sleep 1
pacstrap -K /mnt intel-ucode e2fsprogs networkmanager nano vim --noconfirm

echo -e "\n${COLOR}Generating fstab...${RESET}\n"
sleep 1
genfstab -U /mnt >> /mnt/etc/fstab

# Copy install.sh, post-install.sh, and chroot-install.sh to the new system before chrooting
echo -e "\n${COLOR}Copying installation scripts to /mnt/root...${RESET}\n"
sleep 1
cp install.sh /mnt/root/
cp post-install.sh /mnt/root/
cp chroot-install.sh /mnt/root/

# Chroot into the new system and run the second script
echo -e "\n${COLOR}Chrooting into the new system...${RESET}\n"
sleep 1
arch-chroot /mnt /root/chroot-install.sh

# After chroot is complete, clean up and reboot
echo -e "\n${COLOR}Unmounting all partitions...${RESET}\n"
sleep 1
umount -R /mnt

echo -e "\n${COLOR}Rebooting the system in 3 seconds...${RESET}\n"
sleep 3
reboot
