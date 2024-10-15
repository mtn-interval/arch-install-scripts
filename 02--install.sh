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
echo -e "${CC_HEADER}────── Install System Core  v0.03 ──────${CC_RESET}"
echo
sleep 1



# Set NTP and Timezone
echo -e "${CC_TEXT}Enabling NTP for time synchronization...${CC_RESET}"
timedatectl set-ntp true

echo -e "${CC_TEXT}Setting the timezone to Europe/Lisbon...${CC_RESET}"
timedatectl set-timezone Europe/Lisbon
separator



# List available disks
echo -e "${CC_TEXT}Available Disks:${CC_RESET}"
echo
lsblk -d -o NAME,SIZE,TYPE | grep disk
echo

# Prompt the user to select a disk
read -p "$(echo -e "${CC_TEXT}Please enter the disk you want to use (e.g., sda): ${CC_RESET}")" disk
echo



# Confirm the choice and warn about data erasure
echo -e "${CC_TEXT}Warning: All data on /dev/$disk will be erased!${CC_RESET}"
read -p "$(echo -e "${CC_TEXT}Are you sure you want to continue? (y/n): ${CC_RESET}")" confirm

if [[ "$confirm" != "y" ]]; then
    echo
    echo -e "${CC_TEXT}Operation aborted by user.${CC_RESET}"
    echo
    exit 1
fi

                                                                    read -p "$(echo -e "${CC_HEADER}-----XXXXXXXX-----${CC_RESET}")"


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
mkfs.ext4 /dev/${disk}1
if [ $? -ne 0 ]; then
    echo
    echo "Failed to format /dev/${disk}1. Exiting."
    echo
    exit 1
fi




# Mounting the first partition to /mnt
echo -e "\nMounting /dev/${disk}1 to /mnt...\n"
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
echo -e "${CC_TEXT}Installing base system (base, linux, linux-firmware)...${CC_RESET}"
pacstrap /mnt base linux linux-firmware --noconfirm



# Install essential packages
echo -e "${CC_TEXT}Installing essential packages (intel-ucode, xf86-video-intel, e2fsprogs, networkmanager, nano, vim)...${CC_RESET}"
pacstrap /mnt intel-ucode xf86-video-intel e2fsprogs networkmanager nano vim --noconfirm



# Generate fstab
echo -e "${CC_TEXT}Generating fstab...${CC_RESET}"
genfstab -U /mnt >> /mnt/etc/fstab



# Copy necessary install scripts to the new system
echo -e "${CC_TEXT}Copying installation scripts to /mnt/root...${CC_RESET}"
cp install.sh /mnt/root/
cp post-install.sh /mnt/root/
cp chroot-install.sh /mnt/root/
cp windowmanager.sh /mnt/root/



# Chroot into the new system and run the second script
echo -e "${CC_TEXT}Chrooting into the new system...${CC_RESET}"
arch-chroot /mnt /root/chroot-install.sh



# Ensure all changes are written to disk and unmount partitions
echo -e "${CC_TEXT}Unmounting all partitions...${CC_RESET}"
sync  # Ensure changes are written to disk
umount -R /mnt



# Reboot the system
echo -e "${CC_TEXT}Rebooting the system in 3 seconds...${CC_RESET}"
sleep 3
reboot