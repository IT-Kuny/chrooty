# chrooty

**chrooty** is a rescue and chroot utility that automates chroot-based recovery tasks, including LVM, ZFS, Btrfs subvolume handling, EFI mounts, extensive logging, and plugin-driven extensibility.

## Features

- Dynamic detection of LVM, ZFS, Btrfs, ext4, xfs, exfat volumes
- Btrfs subvolume enumeration and selection (`@` or ID 5)
- EFI partition auto-detection and mounting
- Robust error handling (`set -euo pipefail`, cleanup traps)
- Timestamped audit logs in `/var/log/chrooty.log` with optional `--verbose`
- Self-provisioned log rotation via `/etc/logrotate.d/chrooty`
- Interactive menu and non-interactive scriptable modes
- Extensible plugin architecture via `hooks/pre_chroot.d` and `hooks/post_chroot.d`
- Comprehensive unit/integration tests (Bats) and containerized test harness
- Packaging support for Debian (`.deb`), RPM (`.rpm`), and Homebrew tap

## Installation

### Debian/Ubuntu (Planned...)

```bash
sudo apt-get update
sudo apt-get install -y chrooty
```

### Fedora/CentOS/RHEL (Planned...)

```bash
sudo dnf install -y chrooty
```

### Homebrew (macOS/Linux) (Planned...)

```bash
brew tap github.com/0n1cOn3/chrooty
brew install chrooty
```

## Usage

### Interactive Mode (default)

```bash
sudo chrooty
```

Select from the menu:
1. Rescue System (root filesystem only)
2. Rescue UEFI (EFI partition only)
3. Full Rescue (both)
4. Quit

### Non-Interactive Mode

- Rescue root filesystem only:
  ```bash
  sudo chrooty --no-prompt --system
  ```
- Rescue EFI partition only:
  ```bash
  sudo chrooty --no-prompt --uefi
  ```
- Full rescue:
  ```bash
  sudo chrooty --no-prompt
  ```
- Enable verbose logging:
  ```bash
  sudo chrooty --verbose --no-prompt --system
  ```
- Show help:
  ```bash
  chrooty --help
  ```

## Plugin Hooks

- **Pre-chroot hooks**: Drop executable `*.sh` scripts in `hooks/pre_chroot.d/` to run before mounts.
- **Post-chroot hooks**: Drop executable `*.sh` scripts in `hooks/post_chroot.d/` to run after unmount.

See **DEVELOPER_GUIDE.md** for detailed instructions.

## Contributing

Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting issues, running tests, and submitting pull requests.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
