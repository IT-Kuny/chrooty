#!/usr/bin/env bash

set -e

# Check if the script is being run as root
if [[ "$EUID" -ne 0 ]]; then
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  echo "This script must be run as root. Exiting."
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  exit 1
else
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  echo "Running as root. Proceeding with the script."
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  sleep 2
fi

rsfolder="/rescue"

if [[ ! -d "$rsfolder" ]]; then
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  echo -e "chroot Folder is required! Creating chroot Folder."
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  mkdir -p /rescue
else
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  echo -e "Awesome! The chroot folder exists. Continuing with the script."
  echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
  sleep 2
fi



# Function to display available partitions and let the user select
select_partition() {
    while true; do
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        echo -e "Displaying available partitions..."

        # List all available disks and partitions
        lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

        # Prompt user to select partitions
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        echo -e "Please select the UEFI partition and the system partition."
        echo -e "If there is no UEFI partition, select only the system partition."
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        read -p "Enter the UEFI partition (or press Enter if none): " uefi_partition
        read -p "Enter the system partition: " system_partition
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        
        # Check if system partition is provided
        if [[ -z "$system_partition" ]]; then
            echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
            echo -e "System partition is required! Please select the system partition again."
            echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        else
            break
        fi
    done

    # Mount UEFI partition if selected
    if [[ -n "$uefi_partition" ]]; then
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
        echo -e "Mounting UEFI partition: $uefi_partition"
        mount "$uefi_partition" $rsfolder/boot/efi || { echo "Failed to mount UEFI partition"; exit 1; }
        echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    else
        echo -e "No UEFI partition has been selected."
    fi

    # Mount system partition
    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    echo -e "Mounting system partition: $system_partition"
    mount "$system_partition" $rsfolder || { echo "Failed to mount system partition"; exit 1; }
    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
}

    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

# Function to unmount previous bind mounts
umount_filesystems() {
    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
    echo -e "Unmounting previous bind mounts..."
    umount $rsfolder/dev/pts || true
    umount $rsfolder/dev || true
    umount $rsfolder/sys || true
    umount $rsfolder/proc || true
    umount $rsfolder/run || true
    umount $rsfolder/etc/resolv.conf || true
    echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
}

# Main script execution
echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
echo -e "   Setting up rescue environment...  "
echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"

# Step 1: Partition selection
select_partition

# Step 2: Mount bind filesystems after partition selection
mount_filesystems
echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
echo -e "          Chroot environment has been set up successfully.             "
echo -e "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
