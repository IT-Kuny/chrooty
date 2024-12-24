# Chrooty Setup Script

This script is designed to help you set up a rescue environment in Linux by mounting necessary partitions and creating a chroot environment with just a blink of an eye ;). 

It is intended for recovery operations where you need to repair or troubleshoot a system from a live environment (e.g., live USB).

## Key Points:

- The script is designed for rescue operations where you may need to mount partitions and set up a chroot environment for system repair.
- The root check ensures that the script is executed with the necessary privileges.
- The script allows users to easily mount system and UEFI partitions and bind the necessary directories for recovery tasks.
- The user interaction makes it easy to choose partitions while also providing feedback messages for smooth execution.

## Features

- Root Check: Ensures the script is run as root before proceeding.
- Chroot Folder Setup: Verifies if the /rescue folder exists. If it doesn't, the script will create it.
- Partition Selection: Lets the user select the system partition and UEFI partition (if available). If a UEFI partition is not selected, the system partition will be used for the rescue environment.
- Mounting Partitions: Mounts the system partition and optional UEFI partition to set up the chroot environment.
- Bind Mounts: Binds critical system directories (/dev, /sys, /proc, /run, and /etc/resolv.conf) into the chroot environment for full system access.
- Unmount Cleanup: Safely unmounts all previous bind mounts from the chroot environment when done.

## Requirements

The script must be executed with root privileges.
Available partitions for mounting (system and optionally UEFI) must exist.

## Usage

Open a terminal.
Run the script as root (you can either use sudo or switch to the root user):
    
```bash
sudo ./rescue_setup.sh
```

The script will check if it's running as root. If not, it will exit with an error message.

## Workflow

Root Check: The script first ensures it’s being run as root. If not, it exits immediately.
```bash  
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root. Exiting."
  exit 1
fi
```

## Chroot Folder Check: The script checks if the /rescue folder exists:

If the folder doesn't exist, it will create it (mkdir -p /rescue).
If the folder exists, it will confirm this and proceed.

```bash 
if [[ ! -d "$rsfolder" ]]; then
  mkdir -p /rescue
fi
```

## Partition Selection: The script will display all available disks and partitions using lsblk and ask the user to select:

System Partition: This partition is required.
UEFI Partition: If a UEFI partition exists, it can be selected. If not, you can skip it.

## Example:

```bash 
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
```

#### Mount Partitions:

If a UEFI partition is selected, it will be mounted to /rescue/boot/efi.
The system partition is mounted to /rescue.

The script mounts the partitions using the mount command:

```bash 
mount "$uefi_partition" $rsfolder/boot/efi
mount "$system_partition" $rsfolder
```

#### Bind Mount Filesystems: The script binds critical directories (/dev, /sys, /proc, /run, and /etc/resolv.conf) into the chroot environment:

```bash 
mount --bind /dev $rsfolder/dev
mount --bind /sys $rsfolder/sys
mount --bind /proc $rsfolder/proc
mount --bind /run $rsfolder/run
mount --bind /etc/resolv.conf $rsfolder/etc/resolv.conf
```

#### Unmount Cleanup: Once the operations are completed, the script unmounts all the bind-mounted directories:

```bash
umount $rsfolder/dev/pts || true
umount $rsfolder/dev || true
umount $rsfolder/sys || true
umount $rsfolder/proc || true
umount $rsfolder/run || true
umount $rsfolder/etc/resolv.conf || true
```

#### Completion: After successfully setting up the chroot environment - entered chroot and left, the script prints a success message and exits.

```bash
echo "Chroot environment has been cleaned up successfully."
```

## Troubleshooting

- Error: "System partition is required!"
This message appears if no system partition is selected. Please make sure you select the correct partition when prompted.

- Error: "Failed to mount partition"
This error may occur if the partition is not valid or the mount point is already in use. Ensure that the partitions are not already mounted.

## License

This script is open-source and free to use and under AGPL 3 licensed. Contributions and improvements are welcome!
