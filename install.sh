#!/bin/bash

# Load Portuguese keyboard layout
echo "Loading Portuguese keyboard layout..."
loadkeys pt-latin1

# Enable NTP for accurate time synchronization
echo "Enabling NTP for time synchronization..."
timedatectl set-ntp true

# Set the timezone to Europe/Lisbon
echo "Setting the timezone to Europe/Lisbon..."
timedatectl set-timezone Europe/Lisbon

# Automated partitioning of /dev/sda (BIOS setup without swap)
echo "Starting automatic partitioning of /dev/sda..."

# Create a new MBR partition table and define partitions
(
echo o       # Create a new MBR partition table
echo n       # Add a new partition (1st partition)
echo p       # Primary partition
echo 1       # Partition number 1 (Root partition)
echo         # Default - start at beginning of disk
echo         # Use the rest of the disk for the root partition
echo a       # Make partition 1 bootable
echo w       # Write changes to disk
) | fdisk /dev/sda

# Format the root partition
echo "Formatting /dev/sda1 as EXT4 (root partition)..."
mkfs.ext4 /dev/sda1

# Mount the root partition
echo "Mounting /dev/sda1 to /mnt..."
mount /dev/sda1 /mnt

# Install the base system
echo "Installing base system (base, linux, linux-firmware)..."
pacstrap -K /mnt base linux linux-firmware --noconfirm

# Install essential packages (intel-ucode, e2fsprogs, networkmanager, nano)
echo "Installing essential packages (intel-ucode, e2fsprogs, networkmanager, nano, vim)..."
pacstrap -K /mnt intel-ucode e2fsprogs networkmanager nano vim --noconfirm

echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "Chrooting into the new system..."
arch-chroot /mnt

echo "Setting timezone to Europe/Lisbon..."
ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime

echo "Setting hardware clock..."
hwclock --systohc

echo "Uncommenting en_US.UTF-8 and pt_PT.UTF-8 in /etc/locale.gen..."
sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sed -i '/^#pt_PT.UTF-8 UTF-8/s/^#//' /etc/locale.gen

echo "Generating locales..."
locale-gen

echo "Setting up /etc/locale.conf..."
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

echo "Setting up /etc/vconsole.conf..."
cat <<EOF > /etc/vconsole.conf
KEYMAP=pt-latin1
EOF

echo "Please enter the hostname:"
read hostname
echo "Setting up /etc/hostname..."
echo "$hostname" > /etc/hostname

echo "Setting up /etc/hosts..."
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain $hostname
EOF

echo "Setting root password..."
passwd

echo "Installing GRUB..."
pacman -S --noconfirm grub

echo "Installing GRUB to /dev/sda..."
grub-install --target=i386-pc /dev/sda

echo "Generating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg

echo "Exiting chroot..."
exit

echo "Unmounting all partitions..."
umount -R /mnt

echo "Rebooting the system in 3 seconds..."
sleep 3
reboot