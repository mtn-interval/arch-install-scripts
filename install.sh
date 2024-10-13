#!/bin/bash

# Define a color variable for echo messages
COLOR="\033[1;34m"  # Blue
RESET="\033[0m"      # Reset to default

# Function to pause the script for 2 seconds
pause() {
    sleep 2
}

# Set keyboard layout, NTP, and timezone
echo -e "\n${COLOR}Loading Portuguese keyboard layout...${RESET}\n"
sleep 1
loadkeys pt-latin1

echo -e "\n${COLOR}Enabling NTP for time synchronization...${RESET}\n"
sleep 1
timedatectl set-ntp true

echo -e "\n${COLOR}Setting the timezone to Europe/Lisbon...${RESET}\n"
sleep 1
timedatectl set-timezone Europe/Lisbon

# List available disks
echo -e "\n=== Available Disks ===\n"
lsblk -d -o NAME,SIZE,TYPE | grep disk
echo

# Prompt the user to select a disk
read -p "Please enter the disk you want to use (e.g., sda): " disk

# Confirm the choice and warn about data erasure
echo
echo "Warning: All data on /dev/$disk will be erased!"
read -p "Are you sure you want to continue? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
    echo
    echo "Operation aborted by user."
    echo
    exit 1
fi

# Wipe the partition table using sgdisk
echo
echo "Wiping the partition table on /dev/$disk..."
sgdisk --zap-all /dev/$disk
if [ $? -ne 0 ]; then
    echo
    echo "Failed to wipe partition table on /dev/$disk. Exiting."
    echo
    exit 1
fi
pause

# Detect and wipe all existing partitions using wipefs
echo
echo "Wiping filesystem signatures from all partitions on /dev/$disk..."
for partition in $(lsblk -ln -o NAME /dev/$disk | grep "^${disk}[0-9]"); do
    echo "Wiping /dev/$partition"
    wipefs -a /dev/$partition
    if [ $? -ne 0 ]; then
        echo
        echo "Failed to wipe /dev/$partition. Exiting."
        echo
        exit 1
    fi
done
pause

# Partition the disk using fdisk
echo
echo "Starting automatic partitioning of /dev/$disk..."
sleep 1

(
echo o      # Create a new empty DOS partition table
echo n      # Add a new partition
echo p      # Primary partition
echo 1      # Partition number 1
echo        # Default - first sector
echo        # Default - last sector (use full disk)
echo a      # Make partition bootable
echo w      # Write changes
) | fdisk /dev/$disk

if [ $? -ne 0 ]; then
    echo
    echo "Partitioning failed on /dev/$disk. Exiting."
    echo
    exit 1
fi

echo
echo "Partitioning complete on /dev/$disk."
pause

# Formatting the first partition as EXT4
echo -e "\nFormatting /dev/${disk}1 as EXT4 (root partition)...\n"
sleep 1
mkfs.ext4 /dev/${disk}1
if [ $? -ne 0 ]; then
    echo
    echo "Failed to format /dev/${disk}1. Exiting."
    echo
    exit 1
fi

# Mounting the first partition to /mnt
echo -e "\nMounting /dev/${disk}1 to /mnt...\n"
sleep 1
mount /dev/${disk}1 /mnt
if [ $? -ne 0 ]; then
    echo
    echo "Failed to mount /dev/${disk}1 to /mnt. Exiting."
    echo
    exit 1
fi

echo -e "\nPartitioning and mounting complete.\n"
pause

# Install base system
echo -e "\n${COLOR}Installing base system (base, linux, linux-firmware)...${RESET}\n"
sleep 1
pacstrap /mnt base linux linux-firmware --noconfirm

# Install essential packages
echo -e "\n${COLOR}Installing essential packages (intel-ucode, xf86-video-intel, e2fsprogs, networkmanager, nano, vim)...${RESET}\n"
sleep 1
pacstrap /mnt intel-ucode xf86-video-intel e2fsprogs networkmanager nano vim --noconfirm

# Generate fstab
echo -e "\n${COLOR}Generating fstab...${RESET}\n"
sleep 1
genfstab -U /mnt >> /mnt/etc/fstab

# Copy necessary install scripts to the new system
echo -e "\n${COLOR}Copying installation scripts to /mnt/root...${RESET}\n"
sleep 1
cp install.sh /mnt/root/
cp post-install.sh /mnt/root/
cp chroot-install.sh /mnt/root/
cp windowmanager.sh /mnt/root/

# Chroot into the new system and run the second script
echo -e "\n${COLOR}Chrooting into the new system...${RESET}\n"
sleep 1
arch-chroot /mnt /root/chroot-install.sh

# Ensure all changes are written to disk and unmount partitions
echo -e "\n${COLOR}Unmounting all partitions...${RESET}\n"
sleep 1
sync  # Ensure changes are written to disk
umount -R /mnt

# Reboot the system
echo -e "\n${COLOR}Rebooting the system in 3 seconds...${RESET}\n"
sleep 3
reboot
