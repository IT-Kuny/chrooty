#!/usr/bin/env bash

set -e
# Register the cleanup function to be called on EXIT
trap umount_filesystems EXIT

# Check if the script is being run as root
if [[ "$EUID" -ne 0 ]]; then
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  echo -e "This script must be run as root. Exiting."
  exit 1
else
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  echo -e "Running as root. Proceeding with the script."
  sleep 2
  clear
fi

rsfolder="/rescue"
rsboot="/rescue/boot"

if [[ ! -d "$rsfolder" ]] ||  [[ ! -d "$rsboot" ]]; then
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  echo -e "chroot Folder is required! Creating chroot Folder."

  mkdir -p /rescue
  mkdir -p /rescue/boot
else
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  echo -e "Awesome! The chroot folder exists. Continuing with the script.    "
  sleep 2
fi

# Function to display available partitions and let the user select
select_partition() {
    while true; do
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        echo -e "Displaying available partitions:"

        # List all available disks and partitions
        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT

        # Prompt user to select partitions
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        echo -e "Please select the UEFI partition and the system partition.       "
        echo -e " If there is no UEFI partition, select only the system partition.    "

        read -p "Enter the UEFI partition (or press Enter if none): " uefi_partition
        read -p "Enter the system partition: " system_partition

        # Check if system partition is provided
        if [[ -z "$system_partition" ]]; then
            echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
            echo -e "System partition is required! Please select the system partition again."
        else
            break
        fi
    done

    # Mount UEFI partition if selected
    if [[ -n "$uefi_partition" ]]; then
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        echo -e "Mounting UEFI partition: $uefi_partition"
        mount "$uefi_partition" $rsfolder/boot/ || { echo "Failed to mount UEFI partition"; exit 1; }
        systemctl daemon-reload
    else
        echo -e "No UEFI partition has been selected."
    fi

    # Mount system partition
    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    echo -e "Mounting system partition: $system_partition"
    mount "$system_partition" $rsfolder || { echo "Failed to mount system partition"; exit 1; }
    systemctl daemon-reload
    sleep 2
    clear
}

# Function to bind mount necessary filesystems for chroot
mount_filesystems() {
    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    echo -e "            Bind mounting critical directories for chroot...           "
    mount --bind /dev $rsfolder/dev
    mount --bind /sys $rsfolder/sys
    mount --bind /proc $rsfolder/proc
    mount --bind /run $rsfolder/run
    mount --bind /etc/resolv.conf $rsfolder/etc/resolv.conf
    systemctl daemon-reload
    clear
}

# Function to unmount previous bind mounts
umount_filesystems() {
    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    echo -e "Unmounting previous bind mounts..."
    umount $rsfolder/dev || true
    umount $rsfolder/sys || true
    umount $rsfolder/proc || true
    umount $rsfolder/run || true
    umount $rsfolder/etc/resolv.conf || true
    umount -l $uefi_partition || true
    umount -l $system_partition || true
}

# Main script execution
echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
echo -e "Setting up rescue environment..."

# Step 1: Partition selection
select_partition

# Step 2: Mount bind filesystems after partition selection
mount_filesystems

# Step 3: Enter the chroot environment
echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
echo -e "Entering the chroot environment. You can now perform rescue tasks."
sleep 3

# Execute the chroot command
chroot $rsfolder /bin/bash || chroot $rsfolder /bin/sh

# After exiting the chroot environment
echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
echo -e "You have exited the chroot environment. Cleaning up chroot environment..."

# Step 4: Cleanup - Unmount bind filesystems
umount_filesystems

# Final success message
echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
echo -e "Chroot environment has been cleaned up successfully."
exit 0
